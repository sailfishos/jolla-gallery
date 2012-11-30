import QtQuick 1.1
import QtMobility.gallery 1.1
import org.nemomobile.thumbnailer 1.0
import com.jolla.components 1.0

Item {

    // Workaround for a rounding problem:
    // - cover width is 197px, but cellWidth is integer 197/2.0== 98.5 -> 98
    // - without this there will be 1px vertical line on the right edge of the cover.
    // - solution make width 1px wider that the view.
    width: 198
    height: parent.height

    GridView{
        id: grid
        anchors.fill: parent
        interactive: false
        cellWidth: width / 2.0
        cellHeight: Math.floor(height / 3.0)

        model: DocumentGalleryModel {
            id: galleryModel
            rootType: DocumentGallery.Image
            properties: [ "url", "mimeType" ]
            filter: GalleryStartsWithFilter { property: "filePath"; value: "/home/nemo/Pictures/" }
            limit: 6
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
    Rectangle {
        color: "black"
        anchors.fill: parent
        visible: galleryModel.count == 0
        Label {
            anchors.centerIn: parent
            text: "Gallery"
        }
    }


}
