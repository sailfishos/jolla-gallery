import QtTest 1.0
import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Gallery 1.0
import com.jolla.gallery 1.0
import "scripts/Util.js" as Util
import "/usr/share/jolla-gallery/pages/scripts/AlbumManager.js" as AlbumManager

ApplicationWindow {
    id: window

    property Item gridView: null
    property Page gridPage
    property string currentPageName: pageStack.currentPage != null
            ? pageStack.currentPage.objectName
            : ""

    allowedOrientations: Orientation.Portrait | Orientation.Landscape

    FileInfo {
        id: thumbnailHelper
    }

    initialPage: Page {
        id: dummyPage
    }
    Component {
        id: gridPageComponent

        GalleryGridPage {
            model: albumModel
            title: "Test"
            userData: "photos"
            orientation: Orientation.Portrait
            allowedOrientations: Orientation.Portrait | Orientation.Landscape
            _animationDuration: 0
        }
    }

    TestEvent { id: testEvent }

    TestCase {
        name: "GridPage"
        when: windowShown

        function init()
        {
            gridPage = pageStack.push(gridPageComponent, {}, PageStackAction.Immediate)

            wait()
            verify(gridPage !== null)
            verify(pageStack.currentPage === gridPage)


            gridPage.orientation = Orientation.Portrait
            gridPage.allowedOrientations = Orientation.Portrait

            gridView = Util.findItemByName(gridPage, "gridView")
            verify(gridView !== null)
            verify(gridView.contentItem !== null)

            gridPage.orientation = Orientation.Portrait
            gridView.contextMenu.hide()

            //testService.trackerInfoDeleted = false
        }

        function cleanup()
        {
            pageStack.pop(null, PageStackAction.Immediate)
            gridPage = null
            gridView = null
        }


        function test_initial_setup()
        {
            verify(gridPage !== 0)
            compare(gridPage.title, "Test")
            compare(gridView.count, 10)
        }

        function test_orientation() {
            verify(gridPage !== null)
            verify(gridView !== null)
            verify(gridView.contentItem !== null)

            gridPage.allowedOrientations = Orientation.Portrait | Orientation.Landscape

            // Verify that in portrait mode the grid wraps after portraitItemsPerRow items.
            gridPage.orientation = Orientation.Portrait
            wait(1000)

            var portraitItemsPerRow = Math.floor(window.width / gridView.cellSize)

            var item2 = Util.findItem(gridView.contentItem, function(item) {
                return item.source == "file:///opt/tests/jolla-gallery/auto/images/photo_2.jpg"
            })
            var item3 = Util.findItem(gridView.contentItem, function(item) {
                return item.source == "file:///opt/tests/jolla-gallery/auto/images/photo_" + portraitItemsPerRow + ".jpg"
            })
            tryCompare(item3, "y", item2.y + gridView.cellSize)

            // Verify that in landscape mode the grid wraps after landscapeItemsPerRow items.
            gridPage.orientation = Orientation.Landscape
            wait(1000)
            var landscapeItemsPerRow = Math.floor(window.height / gridView.cellSize)

            var item4 = Util.findItem(gridView.contentItem, function(item) {
                return item.source == "file:///opt/tests/jolla-gallery/auto/images/photo_" + (landscapeItemsPerRow-1) + ".jpg"
            })
            var item5 = Util.findItem(gridView.contentItem, function(item) {
                return item.source == "file:///opt/tests/jolla-gallery/auto/images/photo_" + landscapeItemsPerRow + ".jpg"
            })

            compare(item3.y, item2.y)
            compare(item5.y, item4.y + gridView.cellHeight)

            gridPage.orientation = Orientation.Portrait
            wait(2000)
            compare(item3.y, item2.y + gridView.cellHeight)
            compare(item5.y, item4.y)

        }

        function test_context_menu() {
            verify(gridPage !== null)
            verify(gridView !== null)
            verify(gridView.contentItem !== null)
            gridPage.orientation = Orientation.Portrait
            wait(1000)

            var item2 = Util.findItem(gridView.contentItem, function(item) {
                return item.source == "file:///opt/tests/jolla-gallery/auto/images/photo_2.jpg"
            })
            verify(item2 !== null)

            var portraitItemsPerRow = Math.floor(window.width / gridView.cellSize)
            var item3 = Util.findItem(gridView.contentItem, function(item) {
                return item.source == "file:///opt/tests/jolla-gallery/auto/images/photo_" + portraitItemsPerRow + ".jpg"
            })
            verify(item3 !== null)

            // Open the context menu.
            testEvent.mousePress(item2, gridView.cellWidth / 2, gridView.cellHeight / 2,  Qt.LeftButton, 0, 0)
            wait(1000)
            testEvent.mouseRelease(item2, gridView.cellWidth / 2, gridView.cellHeight / 2, Qt.LeftButton, 0, 0)
            tryCompare(gridView.contextMenu, 'active', true)
            compare(item2.contentYOffset, 0)
            compare(item3.contentYOffset, gridView.contextMenu.height)
            compare(item2.opacity, 1)

            // Hide contextMenu by clicking outside the area
            testEvent.mouseClick(gridView, gridView.width / 2, gridView.height / 2, Qt.LeftButton, 0, 0)
            tryCompare(gridView.contextMenu, 'active', false)

            // Change the orientation. Now item3 should be above the
            // context menu, so y=0, but item5 should be below it.
            gridPage.orientation = Orientation.Landscape
            wait()
            var landscapeItemsPerRow = Math.floor(window.height / gridView.cellSize)
            var item5 = Util.findItem(gridView.contentItem, function(item) {
                return item.source == "file:///opt/tests/jolla-gallery/auto/images/photo_" + landscapeItemsPerRow + ".jpg"
            })
            verify(item5 !== null)

            testEvent.mousePress(item2, gridView.cellWidth / 2, gridView.cellHeight / 2,  Qt.LeftButton, 0, 0)
            wait(1000)
            testEvent.mouseRelease(item2, gridView.cellWidth / 2, gridView.cellHeight / 2, Qt.LeftButton, 0, 0)

            tryCompare(item2, 'contentYOffset', 0)
            tryCompare(item3, 'contentYOffset', 0)
            tryCompare(item5, 'contentYOffset', gridView.contextMenu.height)
            tryCompare(item2, 'opacity', 1)

            // Hide by clicking the same thumbnail again
            testEvent.mouseClick(item2, gridView.cellWidth / 2, gridView.cellHeight / 2, Qt.LeftButton, 0, 0)
            tryCompare(gridView.contextMenu, 'active', false)

            tryCompare(item2, 'contentYOffset', 0)
            tryCompare(item3, 'contentYOffset', 0)
            tryCompare(item5, 'contentYOffset', 0)
            tryCompare(item2, 'opacity', 1)
            tryCompare(item3, 'opacity', 1)
            tryCompare(item5, 'opacity', 1)
        }


        function test_delete() {
            verify(gridPage !== null)
            verify(gridView !== null)
            verify(gridView.contextMenu, "active", false)
            gridPage.orientation = Orientation.Portrait
            wait(1000)

            var item = Util.findItem(gridView.contentItem, function(item) {
                return item.source == "file:///opt/tests/jolla-gallery/auto/images/photo_2.jpg"
            })
            verify(item !== null)

            // Open the context menu.
            testEvent.mousePress(item, gridView.cellWidth / 2, gridView.cellHeight / 2, Qt.LeftButton, 0, 0)
            wait(1000)
            testEvent.mouseRelease(item, gridView.cellWidth / 2, gridView.cellHeight / 2, Qt.LeftButton, 0, 0)
            tryCompare(gridView.contextMenu, 'active', true)

            var deleteMenu = Util.findItemByName(gridView.contextMenu, "deleteItem")
            verify(deleteMenu !== null)

            deleteMenu.clicked(null)
            var remorseItem = Util.findItemByName(item, "remorseItem")
            compare(remorseItem.state, "active")
            wait(5500)
            tryCompare(remorseItem, 'state', "activePending")
        }


        function test_delete_cancel() {
            verify(gridPage !== null)
            verify(gridView !== null)
            verify(gridView.contextMenu, "active", false)
            gridPage.orientation = Orientation.Portrait
            wait(1000)

            var item6 = Util.findItem(gridView.contentItem, function(item) {
                return item.source == "file:///opt/tests/jolla-gallery/auto/images/photo_6.jpg"
            })
            verify(item6 !== null)

            // Open the context menu.
            testEvent.mousePress(item6, gridView.cellWidth / 2, gridView.cellHeight / 2, Qt.LeftButton, 0, 0)
            wait(1000)
            testEvent.mouseRelease(item6, gridView.cellWidth / 2, gridView.cellHeight / 2, Qt.LeftButton, 0, 0)
            tryCompare(gridView.contextMenu, 'active', true)

            var deleteMenu = Util.findItemByName(gridView.contextMenu, "deleteItem")
            verify(deleteMenu !== null)

            // active remorse item
            deleteMenu.clicked(null)

            var remorseItem = Util.findItemByName(item6, "remorseItem")
            verify(remorseItem !== null)

            // Let timer run and cancel it after 1s
            wait(1000)
            remorseItem.clicked(null)
            compare(remorseItem.state, "")
        }
    }

    ListModel {
        id: albumModel
        ListElement { itemId: "photo0"; mimeType: "image/jpeg"; title: "Photo 0"; width: 453; height: 708; orientation: 0; url: "file:///opt/tests/jolla-gallery/auto/images/photo_0.jpg"; lastModified: "2010-11-05T08:15:30-05:0" }
        ListElement { itemId: "photo1"; mimeType: "image/jpeg"; title: "Photo 1"; width: 453; height: 708; orientation: 0; url: "file:///opt/tests/jolla-gallery/auto/images/photo_1.jpg"; lastModified: "2010-11-05T08:15:31-05:0" }
        ListElement { itemId: "photo2"; mimeType: "image/jpeg"; title: "Photo 2"; width: 453; height: 708; orientation: 0; url: "file:///opt/tests/jolla-gallery/auto/images/photo_2.jpg"; lastModified: "2010-11-05T08:15:32-05:0" }
        ListElement { itemId: "photo3"; mimeType: "image/jpeg"; title: "Photo 3"; width: 453; height: 708; orientation: 0; url: "file:///opt/tests/jolla-gallery/auto/images/photo_3.jpg"; lastModified: "2010-11-05T08:15:33-05:0" }
        ListElement { itemId: "photo4"; mimeType: "image/jpeg"; title: "Photo 4"; width: 453; height: 708; orientation: 0; url: "file:///opt/tests/jolla-gallery/auto/images/photo_4.jpg"; lastModified: "2010-11-05T08:15:34-05:0" }
        ListElement { itemId: "photo5"; mimeType: "image/jpeg"; title: "Photo 5"; width: 453; height: 708; orientation: 0; url: "file:///opt/tests/jolla-gallery/auto/images/photo_5.jpg"; lastModified: "2010-11-05T08:15:35-05:0" }
        ListElement { itemId: "photo6"; mimeType: "image/jpeg"; title: "Photo 6"; width: 453; height: 708; orientation: 0; url: "file:///opt/tests/jolla-gallery/auto/images/photo_6.jpg"; lastModified: "2010-11-05T08:15:36-05:0" }
        ListElement { itemId: "photo7"; mimeType: "image/jpeg"; title: "Photo 7"; width: 453; height: 708; orientation: 0; url: "file:///opt/tests/jolla-gallery/auto/images/photo_7.jpg"; lastModified: "2010-11-05T08:15:37-05:0" }
        ListElement { itemId: "photo8"; mimeType: "image/jpeg"; title: "Photo 8"; width: 453; height: 708; orientation: 0; url: "file:///opt/tests/jolla-gallery/auto/images/photo_8.jpg"; lastModified: "2010-11-05T08:15:38-05:0" }
        ListElement { itemId: "photo9"; mimeType: "image/jpeg"; title: "Photo 9"; width: 453; height: 708; orientation: 0; url: "file:///opt/tests/jolla-gallery/auto/images/photo_9.jpg"; lastModified: "2010-11-05T08:15:39-05:0" }
    }
}
