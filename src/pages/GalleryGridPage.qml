import QtQuick 1.1
import com.jolla.components 1.0
import QtMobility.gallery 1.1


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
        y: grid.contentItem.y + grid.cellHeight + (grid.cellHeight - titleText.paintedHeight) / 2
        anchors { right: grid.right; rightMargin: 10 }
        color: theme.highlightColor
        font.pixelSize: theme.fontSizeExtraLarge
        onTextChanged: grid.showTitle = true
        opacity: grid.showTitle ? 1 : 0
    }

    GridView {
        id: grid
        property bool showTitle

        // Add little transparency when flicking
        function setContentItemOpacity()
        {
            var velocity = Math.abs(verticalVelocity)
            if (!flicking){
                contentItem.opacity = 1
                return
            }

            if (1000 < velocity && velocity <= 1500){
                contentItem.opacity = 0.8
                return
            }

            if (1500 < velocity && velocity <= 2200){
                contentItem.opacity = 0.5
                return
            }

            if (2200 < velocity){
                contentItem.opacity = 0.3
                return
            }
        }

        onVerticalVelocityChanged: setContentItemOpacity()
        Behavior on contentItem.opacity { NumberAnimation { duration: 200 }}
        cellWidth: parent.width/3.0
        cellHeight: parent.width/3.0
        boundsBehavior: Flickable.StopAtBounds
        height: parent.height
        width: parent.width
        cacheBuffer: cellHeight * 5

        PullDownMenu {
            // TODO: Localization for the string
            MenuItem {
                text: "Back"
                onClicked:  window.pageStack.pop()
            }
         }

        // TODO: For better performance, we could have here dedicated thumbnails for images and videos
        //       currently only images are supported.
        delegate: GridImageThumbnail { onClicked: window.pageStack.push(Qt.resolvedUrl("GalleryFullscreenPage.qml"), {currentIndex: index, model: grid.model} ) }

        ScrollBar {}
        ScrollDecorator {}
    }
}
