import QtQuick 1.1
import Sailfish.Silica 1.0
import QtMobility.gallery 1.1
import com.jolla.gallery 1.0
import com.jolla.components.gallery 1.0
import "scripts/AlbumManager.js" as AlbumManager

Page {
    id: gridPage
    property alias model: grid.model
    property string title
    property alias currentIndex: grid.currentIndex
    property url thumbnailDelegate

    objectName: "gridPage"
    allowedOrientations: window.allowedOrientations

    function deleteMedia(index) {
        pageStack.pop()
        grid.currentIndex = index
        grid.currentItem.remove()
        grid.positionViewAtIndex(index, GridView.Visible)
    }

    ImageGridView {
        id: grid

        property alias contextMenu: contextMenuItem
        property Item remorseItem
        property Item expandItem
        property real expandHeight: remorseItem != null ? remorseItem.height : contextMenu.height
        property int minOffsetIndex: expandItem != null
                                     ? expandItem.modelIndex + columnCount - (expandItem.modelIndex % columnCount)
                                     : 0

        anchors.fill: parent
        unfocusHighlightEnabled: true
        forceUnfocusHighlight: expandHeight > 0
        header: PageHeader { title: gridPage.title }

        delegate:  ThumbnailCustom {
            id: thumbnail

            property bool itemDeleted
            property bool isItemExpanded: grid.expandItem === thumbnail
            property url mediaUrl: url
            property int modelIndex: index

            source: mediaUrl
            thumbnailSource: thumbnailDelegate
            size: grid.cellSize
            height: isItemExpanded ? grid.contextMenu.height + size : size
            contentYOffset: index >= grid.minOffsetIndex ? grid.expandHeight : 0.0
            z: isItemExpanded ? 1000 : 1
            enabled: isItemExpanded || !grid.contextMenu.active
            Behavior on opacity { enabled: itemDeleted; NumberAnimation { duration: 1600 }}

            function remove() {
                grid.expandItem = thumbnail
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


            onReleased: {
                if (grid.contextMenu.active) {
                    return
                }

                pageStack.push(Qt.resolvedUrl("GalleryFullscreenPage.qml"), {currentIndex: index, model: grid.model} )
                pageStack.currentPage.deleteMedia.connect(gridPage.deleteMedia)
            }

            onPressAndHold: {
                grid.contextMenu.show(thumbnail)
                grid.expandItem = thumbnail
            }
        }

        ContextMenu {
            id: contextMenuItem
            x: parent !== null ? -parent.x : 0.0

            MenuItem {
                objectName: "deleteItem"
                //% "Delete"
                text: qsTrId("gallery-me-delete")
                onClicked: grid.expandItem.remove()
            }
        }
    }


    Component {
        id: removalComponent
        Item {
            id: remorseContainer
            property alias remorse: remorseItem
            y: parent.height// - height
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
