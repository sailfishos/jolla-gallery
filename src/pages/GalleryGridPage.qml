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
    property string title
    property alias currentIndex: grid.currentIndex
    property url thumbnailDelegate

    objectName: "gridPage"

    function deleteMedia(index) {
        pageStack.pop()
        grid.currentIndex = index
        grid.currentItem.remove()
        grid.positionViewAtIndex(index, GridView.Visible)
    }

    SilicaGridView {
        id: grid
        property int firstVisible: Math.max(0, grid.indexAt(0, grid.contentY))
        property int columnCount: gridPage.isPortrait ? 3 : 5
        property alias contextMenu: contextMenuItem
        property Item remorseItem
        property Item expandItem: remorseItem !== null ? remorseItem.parent : (contextMenu.active ? contextMenu.parent : null)
        property real expandHeight: remorseItem !== null ? remorseItem.height : (contextMenu.active ? contextMenu.height : 0.0)
        property int minimumOffsetIndex: expandItem != null
                ? expandItem.modelIndex + columnCount - (expandItem.modelIndex % columnCount)
                : 0

        property real unfocusedOpacity: (currentItem != null && currentItem.pressed)
                || contextMenu.active || remorseItem ? 0.2 : 1.0
        Behavior on unfocusedOpacity { NumberAnimation { duration: 200 }}

        objectName: "gridView"

        flickDeceleration: 1400
        cellWidth: Math.floor(width / columnCount)
        cellHeight: cellWidth
        anchors.fill: parent
        cacheBuffer: cellHeight * 5
        pressDelay: 75

        // Make sure that header is visible when Grid is shown for the first time
        Component.onCompleted: grid.positionViewAtBeginning()

        onContentYChanged: {
            if (remorseItem) {
                // Make sure that the closing menu doesn't hide the RemorseItem at the
                // end of the view
                contentY = Math.max(remorseItem.mapToItem(contentItem, 0, remorseItem.height).y - height, contentY)
            }
        }

        ContextMenu {
            id: contextMenuItem
            parent: null
            x: parent !== null ? -parent.x : 0.0

            MenuItem {
                objectName: "deleteItem"
                //% "Delete"
                text: qsTrId("gallery-me-delete")
                onClicked: grid.expandItem.remove()
            }
        }

        header: PageHeader { title: gridPage.title }

        delegate: MouseArea {
            id: thumbnail

            property bool itemDeleted
            property bool isItemExpanded: grid.expandItem == thumbnail
            property int modelIndex: index
            property url mediaUrl: url

            function remove() {
                grid.remorseItem = removalComponent.createObject(thumbnail)
                //: Deleting image in 5 seconds
                //% "Deleting"
                grid.remorseItem.remorse.execute(grid.remorseItem, qsTrId("gallery-la-deleting"),
                                                 function() {
                                                     itemDeleted = true
                                                     opacity = 0
                                                     AlbumManager.deleteMedia(thumbnail.mediaUrl)
                                                 })
            }

            z: isItemExpanded ? 1000 : 1
            width: grid.cellWidth
            height: isItemExpanded ? grid.cellHeight + grid.expandHeight : grid.cellHeight
            opacity: GridView.isCurrentItem && (grid.remorseItem !== null || grid.contextMenu.active) ? 1.0 : grid.unfocusedOpacity
            enabled: isItemExpanded || !grid.contextMenu.active
            Behavior on opacity { enabled: itemDeleted; NumberAnimation { duration: 1600 }}

            onPressAndHold: {
                grid.contextMenu.show(thumbnail)
            }

            onPressed: {
                grid.currentIndex = index
            }

            onReleased: {
               if (grid.contextMenu.active) {
                   return
               }
               pageStack.push(Qt.resolvedUrl("GalleryFullscreenPage.qml"), {currentIndex: index, model: grid.model} )
               pageStack.currentPage.deleteMedia.connect(gridPage.deleteMedia)
            }

            Loader {
                y: index >= grid.minimumOffsetIndex ? grid.expandHeight : 0.0
                z: 1    // The context menu should be below the thumbnail if it is scaled.
                width: grid.cellWidth
                height: grid.cellHeight
                source: thumbnailDelegate
            }
        }

        VerticalScrollDecorator {}
    }

    // We have one highlight item, which will be positioned on tapped thumbnail
    Rectangle {
        id: highlightItem
        color: theme.highlightBackgroundColor
        width: grid.cellWidth
        height: grid.cellHeight
        opacity: 0.5
        objectName: "highlightItem"
        visible: grid.currentItem.pressed && grid.currentItem.containsMouse &&
                 !grid.contextMenu.active && grid.remorseItem === null
        x: grid.currentItem.x
        y: grid.currentItem.y - grid.contentY
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
}
