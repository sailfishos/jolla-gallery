import QtQuick 1.1
import com.jolla.components 1.0
import QtMobility.gallery 1.1
import "models"

/**
  * GalleryGridPage displays image and video thumbnails on a grid. By
  * tapping a thumbnail GalleryFullscreenPage will be opened.
  */
Page {
    id: gridPage

    // Title for the grid. Scrolls along the grid, while visible
    Label {
        id: title
        y: grid.contentItem.y + grid.pullDownMenu.height + grid.cellHeight + (grid.cellHeight - title.paintedHeight) / 2
        anchors { right: grid.right; rightMargin: 10 }
        color: theme.highlightColor
        font.pixelSize: theme.fontSizeExtraLarge
        opacity: mediaModel.status === DocumentGalleryModel.Idle
    }


    GridView {
        id: grid
        cellWidth: parent.width/4
        cellHeight: parent.width/4
        boundsBehavior: Flickable.StopAtBounds
        height: parent.height
        width: parent.width
        cacheBuffer: cellHeight * 5
        model: MediaModel { id: mediaModel }
        property variant pullDownMenu

        // We don't have yet a cool start view, so let's just query images
        Component.onCompleted: { title.text = "Photos"; mediaModel.queryImages() }

        header: PullDownMenu {
            id: __pullDownMenu
            // TODO: Localization for the string
            MenuItem {
                text: "All"
                onClicked: { title.text = text; mediaModel.queryAll() }
            }

            MenuItem {
                text: "Photos"
                onClicked: { title.text = text; mediaModel.queryImages() }
            }

            MenuItem {
                text: "Videos"
                onClicked: { title.text = text; mediaModel.queryVideos() }
            }

            Component.onCompleted: grid.pullDownMenu = __pullDownMenu
         }

        footer: Item {
            width: parent.width
            height: Math.max(0, parent.parent.height - parent.parent.contentHeight)
        }

        delegate: GridThumbnail { onClicked: window.pageStack.push(Qt.resolvedUrl("GalleryFullscreenPage.qml"), {currentIndex: index, model: mediaModel} ) }

        ScrollBar {}
        ScrollDecorator {}
    }


}
