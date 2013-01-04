import QtQuickTest 1.0
import QtQuick 1.0
import com.jolla.components 1.0
import com.jolla.gallery 1.0
import com.jolla.gallery.test 1.0
import "scripts/Util.js" as Util
import "/usr/share/jolla-gallery/pages/scripts/AlbumManager.js" as AlbumManager

ApplicationWindow {
    id: window

    isPortrait: true
    lockOrientation: true

    property string currentPageName: pageStack.currentPage != null
            ? pageStack.currentPage.objectName
            : ""

    initialPage: GalleryGridPage {
        id: gridPage;
        model: albumModel
        title: "Test"
    }

    TestCase {
        name: "GridPage"
        when: windowShown

        function test_orientation() {
            var gridView = Util.findItemByName(gridPage, "gridView")
            verify(gridView !== undefined)

            // Verify that in portrait mode the grid wraps after 3 items.
            window.isPortrait = true
            var item2 = Util.findItem(gridView.contentItem, function(item) {
                return item.source == "file:///home/nemo/Pictures/photo2.jpg"
            }).parent
            var item3 = Util.findItem(gridView.contentItem, function(item) {
                return item.source == "file:///home/nemo/Pictures/photo3.jpg"
            }).parent
            compare(item3.y, item2.y + gridView.cellHeight)

            // Verify that in landscape mode the grid wraps after 5 items.
            window.isPortrait = false
            var item4 = Util.findItem(gridView.contentItem, function(item) {
                return item.source == "file:///home/nemo/Pictures/photo4.jpg"
            }).parent
            var item5 = Util.findItem(gridView.contentItem, function(item) {
                return item.source == "file:///home/nemo/Pictures/photo5.jpg"
            }).parent
            compare(item3.y, item2.y)
            compare(item5.y, item4.y + gridView.cellHeight)

            window.isPortrait = true
            compare(item3.y, item2.y + gridView.cellHeight)
            compare(item5.y, item4.y)
        }

        function test_menu() {
            var gridView = Util.findItemByName(gridPage, "gridView")
            verify(gridView !== undefined)

            window.isPortrait = true
            var thumbnail0 = Util.findItem(gridView.contentItem, function(item) {
                return item.source == "file:///home/nemo/Pictures/photo0.jpg"
            })
            var item0 = thumbnail0.parent

            var thumbnail1 = Util.findItem(gridView.contentItem, function(item) {
                return item.source == "file:///home/nemo/Pictures/photo1.jpg"
            })
            var item1 = thumbnail1.parent

            var thumbnail3 = Util.findItem(gridView.contentItem, function(item) {
                return item.source == "file:///home/nemo/Pictures/photo3.jpg"
            })
            var item3 = thumbnail3.parent

            var thumbnail5 = Util.findItem(gridView.contentItem, function(item) {
                return item.source == "file:///home/nemo/Pictures/photo5.jpg"
            })
            var item5 = thumbnail5.parent

            // Menu is closed, no thumbnail positions are offset, and all items are fully opaque.
            compare(thumbnail0.y, 0)
            compare(thumbnail1.y, 0)
            compare(thumbnail3.y, 0)
            compare(thumbnail5.y, 0)

            compare(item0.opacity, 1.0)
            compare(item1.opacity, 1.0)
            compare(item3.opacity, 1.0)
            compare(item5.opacity, 1.0)

            mousePress(item1, gridView.cellWidth / 2, gridView.cellHeight / 2)
            wait(1000)
            mouseRelease(item1, gridView.cellWidth / 2, gridView.cellHeight / 2)

            // Wait for the context menu to fully open.
            verify(gridView.contextMenu !== undefined)
            tryCompare(gridView.contextMenu, "height", gridView.contextMenu.childrenRect.height)

            // Verify items on the line below the menu are offset by the height of the menu.
            compare(thumbnail0.y, 0)
            compare(thumbnail1.y, 0)
            compare(thumbnail3.y, gridView.contextMenu.height)
            compare(thumbnail5.y, gridView.contextMenu.height)

            // Just check that there is some transparency as even when the animation has completed
            //  it may not settle on a exact value.
            verify(gridView.unfocusedOpacity < 1.0)
            // All items except the one with the open menu are faded.
            compare(item0.opacity, gridView.unfocusedOpacity)
            compare(item1.opacity, 1.0)
            compare(item3.opacity, gridView.unfocusedOpacity)
            compare(item5.opacity, gridView.unfocusedOpacity)

            // Rotate, and verify items that have moved to the same line as the menu are no longer offset.
            window.isPortrait = false
            compare(thumbnail0.y, 0)
            compare(thumbnail1.y, 0)
            tryCompare(thumbnail3, "y", 0)
            compare(thumbnail5.y, gridView.contextMenu.height)

            // Rotate back.
            window.isPortrait = true
            compare(thumbnail0.y, 0)
            compare(thumbnail1.y, 0)
            tryCompare(thumbnail3, "y", gridView.contextMenu.height)
            compare(thumbnail5.y, gridView.contextMenu.height)

            // Close the menu.
            mouseClick(item1, gridView.cellWidth / 2, gridView.cellHeight / 2)
            tryCompare(gridView.contextMenu, "height", 0)

            // Thumbnails states are all restored.
            compare(thumbnail0.y, 0)
            compare(thumbnail1.y, 0)
            compare(thumbnail3.y, 0)
            compare(thumbnail5.y, 0)

            tryCompare(item0, "opacity", 1.0)
            compare(item1.opacity, 1.0)
            tryCompare(item3, "opacity", 1.0)
            tryCompare(item5, "opacity", 1.0)
        }

        function test_delete() {

            var gridView = Util.findItemByName(gridPage, "gridView")
            verify(gridView !== undefined)

            var item2 = Util.findItem(gridView.contentItem, function(item) {
                return item.source == "file:///home/nemo/Pictures/photo2.jpg"
            })

            // Open the context menu.
            mousePress(item2, gridView.cellWidth / 2, gridView.cellHeight / 2)
            wait(1000)
            mouseRelease(item2, gridView.cellWidth / 2, gridView.cellHeight / 2)
            verify(gridView.contextMenu !== undefined)

            var deleteMenu = Util.findItemByName(gridView.contextMenu, "deleteItem")
            verify(deleteMenu !== undefined)

            deleteMenu.clicked(null)

            compare(AlbumManager.albumManager().removedFile, "file:///home/nemo/Pictures/photo2.jpg")
            tryCompare(testService, "trackerInfoDeleted", true)

            // We can't rely here the implementation of the ContextMenu, instead make sure
            // that the context menu is hidden by hiding it.
            gridView.contextMenu.hide()

            // Don't return until the menu has closed, and opacity has been returned to all items.
            tryCompare(gridView, "menuHeight", 0)
            tryCompare(gridView, "unfocusedOpacity", 1)
        }
    }

    ListModel {
        id: albumModel

        ListElement { itemId: "photo0"; url: "file:///home/nemo/Pictures/photo0.jpg"; mimeType: "image/jpeg"; title: "Photo 0"  }
        ListElement { itemId: "photo1"; url: "file:///home/nemo/Pictures/photo1.jpg"; mimeType: "image/jpeg"; title: "Photo 1"  }
        ListElement { itemId: "photo2"; url: "file:///home/nemo/Pictures/photo2.jpg"; mimeType: "image/jpeg"; title: "Photo 2" }
        ListElement { itemId: "photo3"; url: "file:///home/nemo/Pictures/photo3.jpg"; mimeType: "image/jpeg"; title: "Photo 3" }
        ListElement { itemId: "photo4"; url: "file:///home/nemo/Pictures/photo4.jpg"; mimeType: "image/jpeg"; title: "Photo 4" }
        ListElement { itemId: "photo5"; url: "file:///home/nemo/Pictures/photo5.jpg"; mimeType: "image/jpeg"; title: "Photo 5" }
        ListElement { itemId: "photo6"; url: "file:///home/nemo/Pictures/photo6.jpg"; mimeType: "image/jpeg"; title: "Photo 6" }
        ListElement { itemId: "photo7"; url: "file:///home/nemo/Pictures/photo7.jpg"; mimeType: "image/jpeg"; title: "Photo 7" }
        ListElement { itemId: "photo8"; url: "file:///home/nemo/Pictures/photo8.jpg"; mimeType: "image/jpeg"; title: "Photo 8" }
        ListElement { itemId: "photo9"; url: "file:///home/nemo/Pictures/photo9.jpg"; mimeType: "image/jpeg"; title: "Photo 9" }
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
