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
        property Item overlay: __overlay

        flickDeceleration: 1400
        cellWidth: parent.width/3.0
        cellHeight: parent.width/3.0
        boundsBehavior: Flickable.StopAtBounds
        height: parent.height
        width: parent.width
        cacheBuffer: cellHeight * 5

        onItemSelectedChanged: contentItem.opacity = itemSelected ? 0.2 : 1

        // TODO: For better performance, we could have here dedicated thumbnails for images and videos
        //       currently only images are supported.
        delegate: GridImageThumbnail { onClicked: window.pageStack.push(Qt.resolvedUrl("GalleryFullscreenPage.qml"), {currentIndex: index, model: grid.model} )}

        ScrollBar {}
        ScrollDecorator {}

        Behavior on contentItem.opacity { NumberAnimation { duration: 200 }}

        // This is an overlay layer which is used when a thumbnail has been selected.
        // The thumbnail's parent is changed to this overlay and all the other thumbs in the
        // overlay are still children of the contentItem and little transparent.
        Item { id: __overlay; anchors.fill: parent}
    }
}
