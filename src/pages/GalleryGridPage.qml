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
        property bool itemSelected
        flickDeceleration: 1400

        function setContentItemOpacity()
        {
            if (!flicking ){
                contentItem.opacity = 1
            }else{
                contentItem.opacity = Math.max(0.6, 1.0 - (Math.abs(verticalVelocity) / 6000.0))
            }
        }

        function showFullscreenImage(index)
        {
            clickTimer.index = index
            clickTimer.start()
        }

        onVerticalVelocityChanged: setContentItemOpacity()

        cellWidth: parent.width/3.0
        cellHeight: parent.width/3.0
        boundsBehavior: Flickable.StopAtBounds
        height: parent.height
        width: parent.width
        cacheBuffer: cellHeight * 5

        // TODO: For better performance, we could have here dedicated thumbnails for images and videos
        //       currently only images are supported.
        delegate: GridImageThumbnail { onClicked: grid.showFullscreenImage(index)}

        ScrollBar {}
        ScrollDecorator {}

        Timer {
            id: clickTimer
            property int index
            interval: 200
            onTriggered: { console.log("Switch: " ); window.pageStack.push(Qt.resolvedUrl("GalleryFullscreenPage.qml"), {currentIndex: index, model: grid.model} ) }
        }
    }
}
