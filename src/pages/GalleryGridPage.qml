import QtQuick 1.1
import Sailfish.Silica 1.0
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

    objectName: "gridPage"

    function deleteMedia(index) {
        pageStack.pop()
        grid.currentIndex = index
        grid.currentItem.remove()
        grid.positionViewAtIndex(index, GridView.Visible)
    }

    // Title for the grid
    Label {
        id: titleText
        y: grid.contentItem.y + grid.cellHeight + (grid.cellHeight - titleText.paintedHeight) / 2
        anchors { right: grid.right; rightMargin: theme.paddingMedium }
        color: theme.highlightColor
        font { pixelSize: theme.fontSizeExtraLarge; family: theme.fontFamilyHeading }
        onTextChanged: grid.showTitle = true
        opacity: grid.showTitle ? 1 : 0
    }

    SilicaGridView {
        id: grid
        property bool showTitle

        property int firstVisible: Math.max(0, grid.indexAt(0, grid.contentY))
        property int columnCount: isPortrait ? 3 : 5

        property Item contextMenu
        property Item remorseItem
        property Item expandItem: remorseItem !== null ? remorseItem.parent : (contextMenu !== null ? contextMenu.parent : null)
        property real expandHeight: remorseItem !== null ? remorseItem.height : (contextMenu !== null ? contextMenu.height : 0.0)
        property int minimumOffsetIndex: expandItem != null
                ? expandItem.modelIndex + columnCount - (expandItem.modelIndex % columnCount)
                : 0

        property real unfocusedOpacity: (currentItem != null && currentItem.pressed)
                || (contextMenu != null && contextMenu.active) || remorseItem ? 0.2 : 1.0
        Behavior on unfocusedOpacity { NumberAnimation { duration: 200 }}

        objectName: "gridView"

        flickDeceleration: 1400
        cellWidth: Math.floor(width / columnCount)
        cellHeight: cellWidth
        height: parent.height
        width: parent.width
        cacheBuffer: cellHeight * 5
        pressDelay: 75

        onContentYChanged: {
            if (remorseItem) {
                // Make sure that the closing menu doesn't hide the RemorseItem at the
                // end of the view
                contentY = Math.max(remorseItem.mapToItem(contentItem, 0, remorseItem.height).y - height, contentY)
            }
        }

        // TODO: For better performance, we could have here dedicated thumbnails for images and videos
        //       currently only images are supported.
        delegate: GridImageThumbnail {
            id: thumbnail

            property bool isItemExpanded: grid.expandItem == thumbnail
            property int modelIndex: index
            property url mediaUrl: url

            function remove() {
                grid.remorseItem = removalComponent.createObject(thumbnail)
                grid.remorseItem.remorse.execute(grid.remorseItem, "Deleting",
                                                 function() { AlbumManager.deleteMedia(thumbnail.mediaUrl) })
            }

            z: isItemExpanded ? 1000 : 1
            width: grid.cellWidth
            height: isItemExpanded ? grid.cellHeight + grid.expandHeight : grid.cellHeight
            opacity: GridView.isCurrentItem ? 1.0 : grid.unfocusedOpacity
            menuOffset: index >= grid.minimumOffsetIndex ? grid.expandHeight : 0.0
            enabled: isItemExpanded || grid.contextMenu === null || !grid.contextMenu.active
            onClicked: {
                pageStack.push(Qt.resolvedUrl("GalleryFullscreenPage.qml"), { currentIndex: index, model: grid.model } )
                pageStack.currentPage.deleteMedia.connect(gridPage.deleteMedia)
            }
            onPressAndHold: {
                if (grid.contextMenu === null)
                    grid.contextMenu = contextMenuComponent.createObject(grid)
                grid.contextMenu.show(thumbnail)
            }
            onPressed: grid.currentIndex = index;
        }

        VerticalScrollDecorator {}

        // Padding so there is space for the menu and displaced items at the
        // bottom of the contentItem.
        footer: Item {
            height: grid.expandHeight
        }
    }

    Component {
        id: removalComponent
        Item {
            id: remorseContainer
            property alias remorse: remorseItem
            y: parent.height - height
            x: -parent.x
            width: grid.width
            height: theme.itemSizeSmall

            SequentialAnimation {
                id: destroyAnim
                NumberAnimation { target: remorseContainer; property: "height"; to: 0; duration: 200 }
                ScriptAction {
                    script: {
                        grid.remorseItem = null
                        remorseContainer.destroy()
                        grid.returnToBounds()
                    }
                }
            }
            RemorseItem {
                id: remorseItem
                onTriggered: destroyAnim.start()
                onCanceled: destroyAnim.start()
            }
            InverseMouseArea {
                anchors.fill: parent
                stealPress: true
            }
        }
    }

    Component {
        id: contextMenuComponent

        ContextMenu {
            parent: null
            x: parent !== null ? -parent.x : 0.0

            MenuItem {
                objectName: "deleteItem"
                //% "Delete"
                text: qsTrId("gallery-me-delete")
                onClicked: grid.expandItem.remove()
            }
        }
    }
}
