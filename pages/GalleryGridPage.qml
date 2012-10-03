import QtQuick 1.1
import com.jolla.components 1.0
import QtMobility.gallery 1.1
import "models"

/**
  * GalleryGridPage displays image and video thumbnails on a grid. By
  * tapping a thumbnail GalleryFullscreenPage will be opened.
  */
Page {

    GridView {
        cellWidth: parent.width/4
        cellHeight: parent.width/4
        boundsBehavior: Flickable.StopAtBounds
        height: parent.height
        width: parent.width
        cacheBuffer: cellHeight * 2
        model: MediaModel { id: mediaModel }

        // We don't have yet a cool start view, so let's just query images
        Component.onCompleted: mediaModel.queryImages()

        header: PullDownMenu {
            id: pullDownMenu
            // TODO: Localization for the string
            MenuItem {
                text: "All"
                onClicked: mediaModel.queryAll()
            }
            MenuItem {
                text: "Photos"
                onClicked: mediaModel.queryImages()
            }

            MenuItem {
                text: "Videos"
                onClicked: mediaModel.queryVideos()
            }
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
