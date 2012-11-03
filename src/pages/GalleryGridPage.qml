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
        cellWidth: window.isPortrait ? width / 3 : Math.floor(width / 5.0)
        cellHeight: cellWidth
        boundsBehavior: Flickable.StopAtBounds
        height: parent.height
        width: parent.width
        cacheBuffer: cellHeight * 5

        // TODO: For better performance, we could have here dedicated thumbnails for images and videos
        //       currently only images are supported.
        delegate: GridImageThumbnail {
            width: grid.cellWidth
            height: grid.cellHeight
            onClicked: window.pageStack.push(Qt.resolvedUrl("GalleryFullscreenPage.qml"), {currentIndex: index, model: grid.model} )
        }

        ScrollBar {}
        ScrollDecorator {}
    }
}
