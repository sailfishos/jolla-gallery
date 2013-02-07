import QtQuick 1.1
import QtMobility.gallery 1.1
import org.nemomobile.thumbnailer 1.0
import Sailfish.Silica 1.0

Item {

    // Workaround for a rounding problem:
    // - cover width is 197px, but cellWidth is integer 197/2.0 == 98.5 -> 98
    // - cover height is 316px but cellHeight is integer 316/3.0 == 105.3 -> 105
    // - without this there will be 1px vertical line on the right edge of the cover
    //   and another line at the bottom
    // - solution make width and height to be dividable with integers and cover will
    //   clip the extra pixels away.
    width: 198
    height: 318

    GridView{
        id: grid
        anchors.fill: parent
        interactive: false
        cellWidth: width / 2
        cellHeight: height / 3

        model: DocumentGalleryModel {
            id: galleryModel
            rootType: DocumentGallery.Image
            properties: [ "url", "mimeType", "dateTaken" ]
            filter: GalleryStartsWithFilter { property: "filePath"; value: "/home/nemo/Pictures/" }
            limit: 6
            sortProperties: ["-dateTaken"]
            autoUpdate: true
        }

        delegate: Thumbnail {
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
