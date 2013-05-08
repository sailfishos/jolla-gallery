import QtQuick 1.1
import Sailfish.Silica 1.0
import QtMobility.gallery 1.1
import com.jolla.gallery 1.0
import Sailfish.Gallery 1.0
import "scripts/AlbumManager.js" as AlbumManager

Page {
    id: gridPage
    property alias model: grid.model
    property string title
    property alias currentIndex: grid.currentIndex
    property url thumbnailDelegate
    property int _animationDuration: 150
    property variant _selectedItems: null

    objectName: "gridPage"
    allowedOrientations: window.allowedOrientations

    function deleteItem(index) {
        pageStack.pop()
        grid.currentIndex = index
        grid.currentItem.remove()
        grid.positionViewAtIndex(index, GridView.Visible)
    }

    function deleteMultipleItems(list)
    {
        _selectedItems = list
        pageStack.pop()

        //: Remorse popup for multiple image deletion
        //% "Deleting %1 item(s)"
        clearRemorse.execute(qsTrId("gallery-me-deleting-%1-items").arg(_selectedItems.length), function()
        {
            if (!_selectedItems) {
                console.log("deleteMultipleItems: no selected files!")
                return
            }
            fileRemover.deleteFiles(_selectedItems)
        })
    }

    // File remover is a threaded object which can be used for file deletion in the background.
    // TODO: The same approach could be used for editing when those are put in place.
    // TODO: Not sure how we should deal with the error cases e.g. file couldn't be deleted and
    //       we don't even have a design for that yet.
    FileRemover {
        id: fileRemover
        onFinished: _selectedItems = null
    }


    // Remorse popup for multiple item deletion
    RemorsePopup {
        id: clearRemorse
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
        objectName: "gridView"
        anchors.fill: parent
        unfocusHighlightEnabled: true
        forceUnfocusHighlight: expandHeight > 0
        header: PageHeader { title: gridPage.title }

        PullDownMenu {
            MenuItem {
                //: Select multiple items for different operations
                //% "Select "
                text: qsTrId("gallery-me-select-prefix ") + gridPage.title
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("GalleryItemPickerPage.qml"),{
                                       model: grid.model,
                                       title: gridPage.title
                                   })
                    pageStack.currentPage.itemsSelected.connect(gridPage.deleteMultipleItems)
                }
            }
        }

        // Handle the closing the menu at the end of the grid
        onContentYChanged: {
            if (remorseItem) {
                contentY = Math.max(remorseItem.mapToItem(contentItem, 0, remorseItem.height).y - height, contentY)
            }
        }

        delegate: ThumbnailCustom {
            id: thumbnail

            property bool isItemExpanded: grid.expandItem === thumbnail
            property url mediaUrl: url
            property int modelIndex: index

            source: mediaUrl
            size: grid.cellSize
            thumbnailSource: thumbnailDelegate
            height: isItemExpanded ? grid.contextMenu.height + grid.cellSize : grid.cellSize
            contentYOffset: index >= grid.minOffsetIndex ? grid.expandHeight : 0.0
            z: isItemExpanded ? 1000 : 1
            enabled: isItemExpanded || !grid.contextMenu.active
            GridView.onAdd: AddAnimation { target: thumbnail; duration: _animationDuration }

            function remove() {
                grid.expandItem = thumbnail
                grid.remorseItem = removalComponent.createObject(thumbnail)
                //: Deleting image in 5 seconds
                //% "Deleting"
                grid.remorseItem.remorse.execute(grid.remorseItem, qsTrId("gallery-la-deleting"),
                                                 function() {
                                                     removeAnimationComponent.createObject(thumbnail, { "target": thumbnail })
                                                     AlbumManager.deleteMedia(thumbnail.mediaUrl)
                                                 })
            }


            onReleased: {
                if (grid.contextMenu.active) {
                    return
                }

                pageStack.push(Qt.resolvedUrl("GalleryFullscreenPage.qml"), {currentIndex: index, model: grid.model} )
                pageStack.currentPage.deleteMedia.connect(gridPage.deleteItem)
            }

            onPressAndHold: {
                grid.expandItem = thumbnail
                grid.contextMenu.show(thumbnail)
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
        id: removeAnimationComponent

        RemoveAnimation {
            running: true
            duration: 1600
        }
    }

    Component {
        id: removalComponent
        Item {
            id: remorseContainer
            property alias remorse: remorseItem
            y: parent.size
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
