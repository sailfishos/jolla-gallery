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

    signal updateZ()

    property var layouts: [
        // x, y, rot, z (scale will be increased for higher z)
        [ 0.2, 0.12, 12, 1,   0.75, 0.3, -9, 6,  0.3, 0.4, 1, 2,    0.8, 0.5, 8, 5,     0.2, 0.8, -7, 7,   0.9, 0.8, 6, 3   ],
        [ 0.25, 0.15, -6, 2,  0.8, 0.1, 13, 4,   0.2, 0.4, 9, 3,    0.7, 0.5, 3, 6,     0.3, 0.75, 5, 5,   0.7, 0.85, -3, 3 ],
        [ 0.3, 0.2, 4, 6,     0.7, 0.2, -18, 3,  0.2, 0.45, -8, 1,  0.72, 0.45, -8, 4,  0.35, 0.8,  9, 5,  0.5, 0.9, -12, 6 ]
    ]
    property var indexMap: [ 0, 1, 2, 3, 4, 5 ]
    property int layoutIdx: 0

    function shuffleArray(array) {
        for (var i = array.length - 1; i > 0; i--) {
            var j = Math.floor(Math.random() * (i + 1))
            var temp = array[i]
            array[i] = array[j]
            array[j] = temp
        }
        return array
    }

    function calcRand() {
        // place images in random layout position
        indexMap = shuffleArray(indexMap)
        // cycle between layouts
        layoutIdx = (layoutIdx + 1) % 3
        opacityAnim.start()
    }

    Timer {
        id: animTimer
        repeat: true
        interval: 15000
        running: cover.status === Cover.Active
        onTriggered: calcRand()
    }

    property real photoOpacity: 1.2
    SequentialAnimation {
        id: opacityAnim
        PauseAnimation { duration: animationDuration/4 }
        FadeAnimation { easing.type: Easing.InOutQuad; target: cover; property: "photoOpacity"; to: 0.05; duration: animationDuration/4 }
        ScriptAction { script: cover.updateZ() }
        FadeAnimation { easing.type: Easing.InOutQuad; target: cover; property: "photoOpacity"; to: 1.2; duration: animationDuration/4 }
    }

    ListView{
        id: grid
        width: 1
        height: 5.1 // will create 6 one pixel high delegates
        interactive: false
        cacheBuffer: 0
        property real cellWidth: Math.floor(parent.width / 1.8)
        property real cellHeight: Math.ceil(parent.height / 2.5)
        model: galleryModel
        opacity: fullscreen ? 0.0 : 1.0
        Behavior on opacity { FadeAnimation {}}

        delegate: Item {
            id: wrapper
            property real rz: layouts[layoutIdx][indexMap[index]*4+3]

            width: 1
            height: 1

            Component.onCompleted: {
                z = rz
                cover.updateZ.connect(function() { z = rz })
            }

            CoverPhoto {
                id: photo
                source: url
                mimeType: model.mimeType
                anchors.centerIn: parent
                width: grid.cellWidth
                height: grid.cellHeight
                opacity: photoOpacity

                offsetX: layouts[layoutIdx][indexMap[index]*4] * cover.width
                offsetY: layouts[layoutIdx][indexMap[index]*4+1] * cover.height

                Behavior on offsetX {
                    NumberAnimation { easing.type: Easing.InOutQuad; duration: animationDuration }
                }
                Behavior on offsetY {
                    NumberAnimation { easing.type: Easing.InOutQuad; duration: animationDuration }
                }

                photoScale: 1.0 + rz/20
                Behavior on photoScale {
                    NumberAnimation { easing.type: Easing.InOutQuad; duration: animationDuration }
                }

                rotation: layouts[layoutIdx][indexMap[index]*4+2]
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
        opacity: fullscreen ? 0.5 : 0.0
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
