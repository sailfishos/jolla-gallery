import QtQuickTest 1.0
import QtQuick 1.0
import Sailfish.Silica 1.0
import com.jolla.gallery 1.0
import com.jolla.gallery.test 1.0
import "scripts/Util.js" as Util
import "/usr/share/jolla-gallery/pages/scripts/AlbumManager.js" as AlbumManager

ApplicationWindow {
    id: window

    property string currentPageName: pageStack.currentPage != null
            ? pageStack.currentPage.objectName
            : ""

    FileInfo {
        id: thumbnailHelper
    }

    initialPage: GalleryGridPage {
        id: gridPage;
        width: 480
        height: 854
        model: albumModel
        title: "Test"
        orientation: Orientation.Portrait
        allowedOrientations: Orientation.Portrait | Orientation.Landscape
        thumbnailDelegate: "file:///usr/share/jolla-gallery/pages/GridImageThumbnail.qml"
    }

    TestCase {
        name: "GridPage"
        when: windowShown

        function init() {
            gridPage.orientation = Orientation.Portrait
            gridPage.allowedOrientations = Orientation.Portrait
            gridPage.width = 480
            gridPage.height = 854

            var gridView = Util.findItemByName(gridPage, "gridView")
            verify(gridView !== undefined)
            gridView.remorseItem = null
            gridView.contextMenu.hide()
        }

        function test_orientation() {
            var gridView = Util.findItemByName(gridPage, "gridView")
            verify(gridView !== undefined)

            gridPage.allowedOrientations = Orientation.Portrait | Orientation.Landscape

            // Verify that in portrait mode the grid wraps after 3 items.
            gridPage.orientation = Orientation.Portrait

            var item2 = Util.findItem(gridView.contentItem, function(item) {
                return item.source == "file:///home/nemo/Pictures/photo2.jpg"
            }).parent.parent
            var item3 = Util.findItem(gridView.contentItem, function(item) {
                return item.source == "file:///home/nemo/Pictures/photo3.jpg"
            }).parent.parent
            tryCompare(item3, "y", item2.y + gridView.cellHeight)

            // Verify that in landscape mode the grid wraps after 5 items.
            gridPage.orientation = Orientation.Landscape
            var item4 = Util.findItem(gridView.contentItem, function(item) {
                return item.source == "file:///home/nemo/Pictures/photo4.jpg"
            }).parent.parent
            var item5 = Util.findItem(gridView.contentItem, function(item) {
                return item.source == "file:///home/nemo/Pictures/photo5.jpg"
            }).parent.parent
            compare(item3.y, item2.y)
            compare(item5.y, item4.y + gridView.cellHeight)

            gridPage.orientation = Orientation.Portrait
            compare(item3.y, item2.y + gridView.cellHeight)
            compare(item5.y, item4.y)
        }

        function test_highlightItem()
        {
            gridPage.orientation = Orientation.Portrait

            var gridView = Util.findItemByName(gridPage, "gridView")
            verify(gridView !== undefined)

            // Click the item at index 4 (2nd row, 2nd column)
            var item4 = Util.findItem(gridView.contentItem, function(item) {
                return item.source == "file:///home/nemo/Pictures/photo4.jpg"
            }).parent
            verify(item4 !== undefined)

            var hlItem = Util.findItemByName(gridPage, "highlightItem")
            verify(hlItem !== undefined)

            // First make sure that highlight item is not visible
            compare(hlItem.visible, false)

            // Test the mouse press and make sure it's positioned to the second item
            // and it should also be visible
            mousePress(item4, gridView.cellWidth / 2, gridView.cellHeight / 2)
            tryCompare(hlItem.x, gridView.currentItem.x)
            tryCompare(hlItem.y, gridView.currentItem.y)

            // highlight item can be visible only if context menu and remorse item are not visible
            compare(gridView.contextMenu.active, false)
            verify(gridView.remorseItem === null)
            tryCompare(hlItem.visible, true)

            // Release the mouse i.e. highlight item should be hidden
            mouseRelease(item4, gridView.cellWidth / 2, gridView.cellHeight / 2)
            tryCompare(hlItem.visible, false)
        }


        function test_context_menu() {

            var gridView = Util.findItemByName(gridPage, "gridView")
            verify(gridView !== undefined)

            var item2 = Util.findItem(gridView.contentItem, function(item) {
                return item.source == "file:///home/nemo/Pictures/photo2.jpg"
            }).parent
            verify(item2 !== undefined)

            var item3 = Util.findItem(gridView.contentItem, function(item) {
                return item.source == "file:///home/nemo/Pictures/photo3.jpg"
            }).parent
            verify(item3 !== undefined)


            var item5 = Util.findItem(gridView.contentItem, function(item) {
                return item.source == "file:///home/nemo/Pictures/photo5.jpg"
            }).parent
            verify(item5 !== undefined)


            // Open the context menu.
            mousePress(item2, gridView.cellWidth / 2, gridView.cellHeight / 2)
            wait(1000)
            mouseRelease(item2, gridView.cellWidth / 2, gridView.cellHeight / 2)
            tryCompare(gridView.contextMenu.active, true)

            compare(item2.y, 0)
            compare(item3.y, gridView.contextMenu.height)
            compare(item2.opacity, 1)
            tryCompare(item3.opacity, gridView.unfocusedOpacity)


            // Change the orientation. Now item3 should be above the
            // context menu, so y=0, but item 5 should be below it.
            gridPage.orientation = Orientation.Portrait
            gridPage.width = 854
            gridPage.height= 480

            tryCompare(item2.y, 0)
            tryCompare(item3.y, 0)
            tryCompare(item5.y, gridView.contextMenu.height)
            tryCompare(item2.opacity, 1)
            tryCompare(item3.opacity, gridView.unfocusedOpacity)
            tryCompare(item5.opacity, gridView.unfocusedOpacity)


            // hide the menu by clicking outside the context menu
            mouseClick(item5, gridView.cellWidth / 2, gridView.cellHeight / 2)
            tryCompare(gridView.contextMenu.active, false)

            compare(item2.y, 0)
            compare(item3.y, 0)
            compare(item5.y, 0)
            compare(item2.opacity, 1)
            compare(item3.opacity, 1)
            compare(item5.opacity, 1)
        }

        function test_delete() {

            gridPage.orientation = Orientation.Portrait
            var gridView = Util.findItemByName(gridPage, "gridView")
            verify(gridView !== undefined)

            var item2 = Util.findItem(gridView.contentItem, function(item) {
                return item.source == "file:///home/nemo/Pictures/photo2.jpg"
            }).parent
            verify(item2 !== undefined)

            // Open the context menu.
            mousePress(item2, gridView.cellWidth / 2, gridView.cellHeight / 2)
            wait(1000)
            mouseRelease(item2, gridView.cellWidth / 2, gridView.cellHeight / 2)
            verify(gridView.contextMenu !== undefined)

            var deleteMenu = Util.findItemByName(gridView.contextMenu, "deleteItem")
            verify(deleteMenu !== undefined)

            // Test remorse item and canceling the delete operation
            deleteMenu.clicked(null)
            verify(gridView.remorseItem !== undefined)

            verify(gridView.remorseItem.remorse !== undefined)
            gridView.remorseItem.remorse.clicked(null)
            tryCompare(testService, "trackerInfoDeleted", false)


            // Next test deletion
            deleteMenu.clicked(null)
            // Wait that remorse timeout has exceeded
            wait(6000)
            compare(AlbumManager.albumManager().removedFile, "file:///home/nemo/Pictures/photo2.jpg")
            tryCompare(testService, "trackerInfoDeleted", true)

            // We can't rely here the implementation of the ContextMenu, instead make sure
            // that the context menu is hidden by hiding it.
            gridView.contextMenu.hide()

            // Don't return until the menu has closed, and opacity has been returned to all items.
            tryCompare(gridView, "expandHeight", 0)
            tryCompare(gridView, "unfocusedOpacity", 1)
        }

    }

    ListModel {
        id: albumModel

        ListElement { itemId: "photo0"; url: "file:///home/nemo/Pictures/photo0.jpg"; mimeType: "image/jpeg"; title: "Photo 0"; dateTaken: "2010-11-05T08:15:30-05:0" }
        ListElement { itemId: "photo1"; url: "file:///home/nemo/Pictures/photo1.jpg"; mimeType: "image/jpeg"; title: "Photo 1"; dateTaken: "2010-10-05T08:15:30-05:0" }
        ListElement { itemId: "photo2"; url: "file:///home/nemo/Pictures/photo2.jpg"; mimeType: "image/jpeg"; title: "Photo 2"; dateTaken: "2010-09-05T08:15:30-05:0" }
        ListElement { itemId: "photo3"; url: "file:///home/nemo/Pictures/photo3.jpg"; mimeType: "image/jpeg"; title: "Photo 3"; dateTaken: "2010-08-05T08:15:30-05:0" }
        ListElement { itemId: "photo4"; url: "file:///home/nemo/Pictures/photo4.jpg"; mimeType: "image/jpeg"; title: "Photo 4"; dateTaken: "2010-07-05T08:15:30-05:0" }
        ListElement { itemId: "photo5"; url: "file:///home/nemo/Pictures/photo5.jpg"; mimeType: "image/jpeg"; title: "Photo 5"; dateTaken: "2010-06-05T08:15:30-05:0" }
        ListElement { itemId: "photo6"; url: "file:///home/nemo/Pictures/photo6.jpg"; mimeType: "image/jpeg"; title: "Photo 6"; dateTaken: "2010-05-05T08:15:30-05:0" }
        ListElement { itemId: "photo7"; url: "file:///home/nemo/Pictures/photo7.jpg"; mimeType: "image/jpeg"; title: "Photo 7"; dateTaken: "2010-04-05T08:15:30-05:0" }
        ListElement { itemId: "photo8"; url: "file:///home/nemo/Pictures/photo8.jpg"; mimeType: "image/jpeg"; title: "Photo 8"; dateTaken: "2010-03-05T08:15:30-05:0" }
        ListElement { itemId: "photo9"; url: "file:///home/nemo/Pictures/photo9.jpg"; mimeType: "image/jpeg"; title: "Photo 9"; dateTaken: "2010-02-05T08:15:30-05:0" }
    }

    TestDBusService {
        id: testService

        property bool trackerInfoDeleted: false

        property string removeQuery:
"DELETE {
   ?y nfo:hasMediaFileListEntry ?x
   ?x a nfo:MediaFileListEntry
} WHERE {
   {?y nfo:hasMediaFileListEntry ?x}
   {?x nfo:entryUrl 'file:///home/nemo/Pictures/photo2.jpg'}
} DELETE {
   ?x a nfo:Media
} WHERE {
   {?x nie:url 'file:///home/nemo/Pictures/photo2.jpg'}
}"

        onUpdate: {
            if (argument == removeQuery) {
                trackerInfoDeleted = true
            } else {
                console.log("unhandled update  query")
                console.log(argument)
            }
        }
    }
}
