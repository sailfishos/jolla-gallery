import QtQuick 2.0
import QtDocGallery 5.0
import Sailfish.Silica 1.0
import com.jolla.gallery 1.0
import org.nemomobile.thumbnailer 1.0

CoverBackground {
    id: cover
    property bool contentAvailable: galleryModel && galleryModel.count > 0
    property var galleryModel: photosModel
    property int animationDuration: 2000
    property bool fullscreen: window.activeObject && window.activeObject.url != ""

    property var baseLayout: [
        // x, y, rot, z (scale will be increased for higher z)
        0.2, 0.16, -5, 2,   0.79, 0.1, 5, 5,  0.25, 0.48, 1, 2,    0.72, 0.5, -3, 4,     0.08, 0.86, -5, 3.8,   0.86, 0.74, 4, 5
    ]

    property var layouts: [
        // x, y, rot, z (scale will be increased for higher z)
        [ 0.55, 0.32, -4, 6,  0.45, 0.65, 5, 9 ],
        [ 0.42, 0.32, -3, 6,  0.55, 0.65, 2, 9 ],
        [ 0.32, 0.62,  4, 6,  0.60, 0.4, -8, 9 ]
    ]
    property var indexMap: [ 0, 1, 2, 3, 4, 5, 6, 7 ]
    property int layoutIdx: 2

    function shuffleArray(array) {
        // Just swap a hero for a backgound photo
        var j = Math.floor(2 + Math.random() * 6)
        var k = Math.floor(Math.random() * 2)
        var temp = array[k]
        array[k] = array[j]
        array[j] = temp

        return array
    }

    function layout(index, layoutIdx) {
        for (var mappedIdx = 0; mappedIdx < indexMap.length; ++mappedIdx) {
            if (indexMap[mappedIdx] == index) {
                break
            }
        }

        var startIdx
        if (mappedIdx < 2) {
            startIdx = mappedIdx * 4
            return layouts[layoutIdx].slice(startIdx, startIdx+4)
        } else {
            startIdx = (mappedIdx-2) * 4
            return baseLayout.slice(startIdx, startIdx+4)
        }
    }

    function calcRand() {
        if (grid.count > 2) {
            // place images in random layout position
            indexMap = shuffleArray(indexMap)
        }
        // cycle between hero layouts
        layoutIdx = (layoutIdx + 1) % 3
    }

    Timer {
        id: animTimer
        running: true
        repeat: true
        interval: 2 * 3600 * 1000 // 2 hours
        onTriggered: calcRand()
    }


    ListView{
        id: grid
        width: 1
        height: 7.1 // will create 8 one pixel high delegates
        interactive: false
        cacheBuffer: 0
        property real cellWidth: Math.floor(parent.width / 1.8)
        property real cellHeight: Math.ceil(parent.height / 2.5)
        model: galleryModel
        opacity: fullscreen ? 0.0 : 1.0
        Behavior on opacity { FadeAnimation {}}

        delegate: Item {
            id: wrapper
            property real zLayout: layout(index, layoutIdx)[3]
            onZLayoutChanged: { if (cover.status === Cover.Active) opacityAnim.start() }

            width: 1
            height: 1

            Component.onCompleted: z = zLayout

            property real photoOpacity: 1.0
            SequentialAnimation {
                id: opacityAnim
                PauseAnimation { duration: (index+1) * animationDuration/10 }
                FadeAnimation { easing.type: Easing.InOutQuad; target: wrapper; property: "photoOpacity"; to: 0.1; duration: animationDuration/6 }
                ScriptAction { script: wrapper.z = zLayout }
                FadeAnimation { easing.type: Easing.InOutQuad; target: wrapper; property: "photoOpacity"; to: 1.0; duration: animationDuration/6 }
            }

            CoverPhoto {
                id: photo
                source: url
                mimeType: model.mimeType
                anchors.centerIn: parent
                width: grid.cellWidth
                height: grid.cellHeight
                opacity: photoOpacity

                offsetX: layout(index, layoutIdx)[0] * cover.width + (Theme.paddingSmall - Math.random() * Theme.paddingMedium)
                offsetY: layout(index, layoutIdx)[1] * cover.height + (Theme.paddingSmall - Math.random() * Theme.paddingMedium)

                Behavior on offsetX {
                    NumberAnimation { easing.type: Easing.InOutQuad; duration: animationDuration }
                }
                Behavior on offsetY {
                    NumberAnimation { easing.type: Easing.InOutQuad; duration: animationDuration }
                }

                photoScale: 1.0 + zLayout/20
                Behavior on photoScale {
                    NumberAnimation { easing.type: Easing.InOutQuad; duration: animationDuration }
                }

                rotation: layout(index, layoutIdx)[2] + 5 - Math.random() * 10
                Behavior on rotation {
                    RotationAnimation { easing.type: Easing.InOutQuad; duration: animationDuration }
                }
            }
        }
    }

    Image {
        source: "image://theme/icon-launcher-gallery"
        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: takePhotosLabel.top
            bottomMargin: Theme.paddingLarge
        }
        opacity: 0.2
        visible: !contentAvailable
    }

    // Show the "Active object" e.g. fullscreen image or video
    Thumbnail {
        // NOTE: MimeType needs to be updated first if it's changed.
        // It might otherwise cause problems because changing url
        // first e.g. from image to video url without changing the
        // mimeType, makes the behavior a bit unpredictable
        mimeType: window.activeObject.mimeType
        source: window.activeObject.url
        priority: Thumbnail.HighPriority
        anchors.fill: parent
        smooth: true
        sourceSize.width: parent.width
        sourceSize.height: parent.height
        opacity: fullscreen ? 1 : 0
        Behavior on opacity { FadeAnimation {}}
    }
    CoverPhoto {
        // NOTE: MimeType needs to be updated first if it's changed.
        // It might otherwise cause problems because changing url
        // first e.g. from image to video url without changing the
        // mimeType, makes the behavior a bit unpredictable
        mimeType: window.activeObject.mimeType
        source: window.activeObject.url
        priority: Thumbnail.HighPriority
        anchors {
            fill: parent
            leftMargin: Theme.paddingMedium + Theme.paddingSmall
            rightMargin: Theme.paddingMedium + Theme.paddingSmall
            topMargin: -Theme.paddingLarge*3
        }
        smooth: true
        opacity: fullscreen ? 1 : 0
        Behavior on opacity { FadeAnimation {}}
    }

    // We don't have a design for empty content so let's
    // just define a placeholder for it.
    // TODO: Remove this when the design exists.
    Label {
        id: takePhotosLabel
        //% "Take some photos"
        text: qsTrId("gallery-la-take_some_photos")
        anchors {
            centerIn: parent
        }
        width: parent.width - Theme.paddingLarge
        visible: !contentAvailable
        color: Theme.secondaryColor
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.Wrap
    }

    CoverActionList {
       enabled: !contentAvailable
       CoverAction {
           iconSource: "image://theme/icon-cover-camera"
           onTriggered: {
               CameraLauncher.exec()
           }
       }
   }
}
