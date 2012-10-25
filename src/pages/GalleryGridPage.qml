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
    property alias model: grid.model
    property alias title: titleText.text

    // Title for the grid
    Label {
        id: titleText
        y: grid.contentItem.y + grid.pullDownMenu.height + grid.cellHeight + (grid.cellHeight - titleText.paintedHeight) / 2
        anchors { right: grid.right; rightMargin: 10 }
        color: theme.highlightColor
        font.pixelSize: theme.fontSizeExtraLarge
        onTextChanged: grid.showTitle = true
        opacity: grid.showTitle ? 1 : 0
    }

    GridView {
        id: grid
        property variant pullDownMenu
        property bool itemSelected
        property bool showTitle

        onShowTitleChanged: console.log("Item selection changed " + showTitle)
        cellWidth: parent.width/3.0
        cellHeight: parent.width/3.0
        boundsBehavior: Flickable.StopAtBounds
        height: parent.height
        width: parent.width
        cacheBuffer: cellHeight * 5


        header: PullDownMenu {
            id: __pullDownMenu
            // TODO: Localization for the string
            MenuItem {
                text: "Back"
                onClicked:  window.pageStack.pop()
            }
            Component.onCompleted: grid.pullDownMenu = __pullDownMenu
         }

        footer: Item {
            width: parent.width
            height: Math.max(0, parent.parent.height - parent.parent.contentHeight)
        }

        // TODO: For better performance, we could have here dedicated thumbnails for images and videos
        //       currently only images are supported.
        delegate: GridImageThumbnail { onClicked: window.pageStack.push(Qt.resolvedUrl("GalleryFullscreenPage.qml"), {currentIndex: index, model: grid.model} ) }

        ScrollBar {}
        ScrollDecorator {}
    }
}
