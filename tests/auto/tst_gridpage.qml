import QtTest 1.0
import QtQuick 2.0
import QtDocGallery 5.0
import Sailfish.Silica 1.0
import Sailfish.Gallery 1.0
import com.jolla.gallery 1.0
import "scripts/Util.js" as Util

ApplicationWindow {
    id: window

    property Item gridView: null
    property Page gridPage
    property string currentPageName: pageStack.currentPage != null
            ? pageStack.currentPage.objectName
            : ""

    allowedOrientations: Orientation.Portrait | Orientation.Landscape

    initialPage: Page {
        id: dummyPage
    }
    Component {
        id: gridPageComponent

        GalleryGridPage {
            model: albumModel
            title: "Test"
            userData: MediaSource.Photos
            orientation: Orientation.Portrait
            allowedOrientations: Orientation.Portrait | Orientation.Landscape
            _animationDuration: 0
        }
    }

    TestEvent { id: testEvent }

    TestCase {
        name: "GridPage"
        when: windowShown

        function initTestCase() {
            albumModel.append({ itemId: "photo0", mimeType: "image/jpeg", title: "Photo 0", width: 453, height: 708, orientation: 0, url: "file:///opt/tests/jolla-gallery/auto/images/photo_0.jpg", dateTaken: new Date("2010-11-05T08:15:30-05:00") })
            albumModel.append({ itemId: "photo1", mimeType: "image/jpeg", title: "Photo 1", width: 453, height: 708, orientation: 0, url: "file:///opt/tests/jolla-gallery/auto/images/photo_1.jpg", dateTaken: new Date("2010-11-05T08:15:31-05:00") })
            albumModel.append({ itemId: "photo2", mimeType: "image/jpeg", title: "Photo 2", width: 453, height: 708, orientation: 0, url: "file:///opt/tests/jolla-gallery/auto/images/photo_2.jpg", dateTaken: new Date("2010-11-05T08:15:32-05:00") })
            albumModel.append({ itemId: "photo3", mimeType: "image/jpeg", title: "Photo 3", width: 453, height: 708, orientation: 0, url: "file:///opt/tests/jolla-gallery/auto/images/photo_3.jpg", dateTaken: new Date("2010-11-05T08:15:33-05:00") })
            albumModel.append({ itemId: "photo4", mimeType: "image/jpeg", title: "Photo 4", width: 453, height: 708, orientation: 0, url: "file:///opt/tests/jolla-gallery/auto/images/photo_4.jpg", dateTaken: new Date("2010-11-05T08:15:34-05:00") })
            albumModel.append({ itemId: "photo5", mimeType: "image/jpeg", title: "Photo 5", width: 453, height: 708, orientation: 0, url: "file:///opt/tests/jolla-gallery/auto/images/photo_5.jpg", dateTaken: new Date("2010-11-05T08:15:35-05:00") })
            albumModel.append({ itemId: "photo6", mimeType: "image/jpeg", title: "Photo 6", width: 453, height: 708, orientation: 0, url: "file:///opt/tests/jolla-gallery/auto/images/photo_6.jpg", dateTaken: new Date("2010-11-05T08:15:36-05:00") })
            albumModel.append({ itemId: "photo7", mimeType: "image/jpeg", title: "Photo 7", width: 453, height: 708, orientation: 0, url: "file:///opt/tests/jolla-gallery/auto/images/photo_7.jpg", dateTaken: new Date("2010-11-05T08:15:37-05:00") })
            albumModel.append({ itemId: "photo8", mimeType: "image/jpeg", title: "Photo 8", width: 453, height: 708, orientation: 0, url: "file:///opt/tests/jolla-gallery/auto/images/photo_8.jpg", dateTaken: new Date("2010-11-05T08:15:38-05:00") })
            albumModel.append({ itemId: "photo9", mimeType: "image/jpeg", title: "Photo 9", width: 453, height: 708, orientation: 0, url: "file:///opt/tests/jolla-gallery/auto/images/photo_9.jpg", dateTaken: new Date("2010-11-05T08:15:39-05:00") })
        }

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
            gridPage.allowedOrientations = Orientation.Landscape
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

            gridPage.allowedOrientations = Orientation.Portrait
            wait(2000)
            compare(item3.y, item2.y + gridView.cellHeight)
            compare(item5.y, item4.y)

        }
    }

    ListModel {
        id: albumModel
        property int rootType: DocumentGallery.Image
    }
}
