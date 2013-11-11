import QtQuick 2.0
import QtDocGallery 5.0
import Sailfish.Silica 1.0
import Sailfish.Silica.theme 1.0
import com.jolla.gallery 1.0

CoverBackground {

    property bool contentAvailable: galleryModel && galleryModel.count > 0
    property DocumentGalleryModel galleryModel: photosModel

    GridView{
        id: grid
        anchors.fill: parent
        interactive: false
        cellWidth: Math.floor(width / 2.0)
        cellHeight: Math.ceil(height / 3.0)

        model: galleryModel

        delegate: GalleryThumbnail {
            source: url
            mimeType: model.mimeType
            width: grid.cellWidth
            height: grid.cellHeight
            smooth: true
            sourceSize.width: width
            sourceSize.height: height
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
