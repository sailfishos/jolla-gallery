import QtQuick 1.1
import QtMobility.gallery 1.1
import Sailfish.Silica 1.0

CoverBackground {

    GridView{
        id: grid
        anchors.fill: parent
        interactive: false
        cellWidth: Math.floor(width / 2.0)
        cellHeight: Math.ceil(height / 3.0)

        model: DocumentGalleryModel {
            id: galleryModel
            rootType: DocumentGallery.Image
            properties: [ "url", "mimeType", "dateTaken" ]
            filter: GalleryStartsWithFilter { property: "filePath"; value: "/home/nemo/Pictures/" }
            limit: 6
            sortProperties: ["-dateTaken"]
            autoUpdate: true
        }

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

    // We don't have a design for empty content so let's
    // just define a placeholder for it.
    // TODO: Remove this when the design exists.
    Label {
        //% "Take some photos"
        text: qsTrId("gallery-la-take_some_photos")
        y: 28
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width - theme.paddingLarge
        visible: galleryModel.count == 0
        color: theme.secondaryColor
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.Wrap
    }
}
