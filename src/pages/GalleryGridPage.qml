import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Silica.theme 1.0
import QtDocGallery 5.0
import com.jolla.gallery 1.0
import Sailfish.Gallery 1.0
import "scripts/AlbumManager.js" as AlbumManager

MediaSourcePage {
    id: gridPage
    property alias currentIndex: grid.currentIndex
    property int _animationDuration: 150
    property variant _selectedItems: null
    property int fullscreenOrientations: allowedOrientations
    property int _requestedIndex: -1

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

    function requestIndex(index) {
        _requestedIndex = index
    }

    function jumpToIndex(index) {
        if (index < grid.columnCount)
            grid.positionViewAtBeginning()
        else
            grid.positionViewAtIndex(index, GridView.Visible)
        grid.currentIndex = index
    }

    onStatusChanged: {
        if (status == PageStatus.Activating && _requestedIndex != -1) {
            jumpToIndex(_requestedIndex)
        }
    }

    // File remover is a threaded object which can be used for file deletion in the background.
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
        property Item expandItem
        property real expandHeight: contextMenu.height
        property int minOffsetIndex: expandItem != null
                                     ? expandItem.modelIndex + columnCount - (expandItem.modelIndex % columnCount)
                                     : 0

        objectName: "gridView"
        anchors.fill: parent
        unfocusHighlightEnabled: true
        forceUnfocusHighlight: expandHeight > 0
        header: PageHeader { title: gridPage.title }
        model: gridPage.model

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

        delegate: ThumbnailImage {
            id: thumbnail

            property bool isItemExpanded: grid.expandItem === thumbnail
            property url mediaUrl: url
            property int modelIndex: index

            source: mediaUrl
            size: grid.cellSize
            height: isItemExpanded ? grid.contextMenu.height + grid.cellSize : grid.cellSize
            contentYOffset: index >= grid.minOffsetIndex ? grid.expandHeight : 0.0
            z: isItemExpanded ? 1000 : 1
            enabled: isItemExpanded || !grid.contextMenu.active

            function remove() {                
                var remorse = removalComponent.createObject(null)
                remorse.z = thumbnail.z + 1
                remorse.wrapMode = Text.Wrap
                remorse.horizontalAlignment = Text.AlignHCenter

                //: Deleting image in 5 seconds
                //% "Deleting"
                remorse.execute(thumbnail,
                                qsTrId("gallery-la-deleting"),
                                function() {
                                    AlbumManager.deleteMedia(thumbnail.mediaUrl)
                                })
            }


            onReleased: {
                if (grid.contextMenu.active) {
                    return
                }

                pageStack.push(Qt.resolvedUrl("GalleryFullscreenPage.qml"), {currentIndex: index, model: grid.model, allowedOrientations: gridPage.fullscreenOrientations} )
                pageStack.currentPage.deleteMedia.connect(gridPage.deleteItem)
                _requestedIndex = -1
                pageStack.currentPage.requestIndex.connect(gridPage.requestIndex)
            }

            onPressAndHold: {
                grid.expandItem = thumbnail
                grid.contextMenu.show(thumbnail)
            }

            GridView.onAdd: AddAnimation { target: thumbnail; duration: _animationDuration }
            GridView.onRemove: SequentialAnimation {
                PropertyAction { target: thumbnail; property: "GridView.delayRemove"; value: true }
                NumberAnimation { target: thumbnail; properties: "opacity,scale"; to: 0; duration: 250; easing.type: Easing.InOutQuad }
                PropertyAction { target: thumbnail; property: "GridView.delayRemove"; value: false }
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
        RemorseItem { }
    }
}
