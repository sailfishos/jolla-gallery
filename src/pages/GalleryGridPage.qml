import QtQuick 1.1
import com.jolla.components 1.0
import QtMobility.gallery 1.1
import "scripts/AlbumManager.js" as AlbumManager

/**
  * GalleryGridPage displays image and video thumbnails on a grid. By
  * tapping a thumbnail GalleryFullscreenPage will be opened.
  */
Page {
    id: gridPage
    property alias model: grid.model
    property alias title: titleText.text
    property alias currentIndex: grid.currentIndex

    // Title for the grid
    Label {
        id: titleText
        y: grid.contentItem.y + grid.cellHeight + (grid.cellHeight - titleText.paintedHeight) / 2
        anchors { right: grid.right; rightMargin: 10 }
        color: theme.highlightColor
        font { pixelSize: theme.fontSizeExtraLarge; family: theme.fontFamilyHeading }
        onTextChanged: grid.showTitle = true
        opacity: grid.showTitle ? 1 : 0
    }

    JollaGridView {
        id: grid
        property bool showTitle

        property int firstVisible: Math.max(0, grid.indexAt(0, grid.contentY))
        property int columnCount: window.isPortrait ? 3 : 5

        property Item contextMenu
        property Item menuItem: contextMenu !== null ? contextMenu.parent : null
        property real menuHeight: contextMenu !== null ? contextMenu.height : 0.0
        property int minimumOffsetIndex: menuItem != null
                ? menuItem.modelIndex + columnCount - (menuItem.modelIndex % columnCount)
                : 0

        property real unfocusedOpacity: (currentItem != null && currentItem.pressed)
                || (contextMenu != null && contextMenu.active) ? 0.2 : 1.0
        Behavior on unfocusedOpacity { NumberAnimation { duration: 200 }}

        flickDeceleration: 1400
        cellWidth: Math.floor(width / columnCount)
        cellHeight: cellWidth
        height: parent.height
        width: parent.width
        cacheBuffer: cellHeight * 5
        pressDelay: 75

        // TODO: For better performance, we could have here dedicated thumbnails for images and videos
        //       currently only images are supported.
        delegate: GridImageThumbnail {
            id: thumbnail

            property bool isMenuItem: grid.menuItem == thumbnail
            property int modelIndex: index
            property url mediaUrl: url

            width: grid.cellWidth
            height: isMenuItem ? grid.cellHeight + grid.menuHeight : grid.cellHeight
            opacity: GridView.isCurrentItem ? 1.0 : grid.unfocusedOpacity
            menuOffset: index >= grid.minimumOffsetIndex ? grid.menuHeight : 0.0
            enabled: isMenuItem || grid.contextMenu === null || !grid.contextMenu.active
            onClicked: pageStack.push(Qt.resolvedUrl("GalleryFullscreenPage.qml"), {currentIndex: index, model: grid.model} )
            onPressAndHold: {
                if (grid.contextMenu === null)
                    grid.contextMenu = contextMenuComponent.createObject(grid)
                grid.contextMenu.show(thumbnail)
            }
            onPressed: grid.currentIndex = index;
        }

        ScrollBar {}
        ScrollDecorator {}

        // Padding so there is space for the menu and displaced items at the
        // bottom of the contentItem.
        footer: Item {
            height: menuHeight
        }
    }

    Component {
        id: contextMenuComponent

        ContextMenu {
            parent: null
            x: parent !== null ? -parent.x : 0.0

            MenuItem {
                //% "Delete"
                text: qsTrId("gallery-me-delete")
                onClicked: AlbumManager.deleteMedia(grid.menuItem.mediaUrl)
            }
        }
    }

}
