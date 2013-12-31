import QtTest 1.0
import QtQuick 2.0
import Sailfish.Silica 1.0
import com.jolla.gallery 1.0
import "scripts/Util.js" as Util

ApplicationWindow {
    id: window

    property Page fullscreenPage

    // For GalleryFullscreenPage we need to have something on a page stack first
    // or otherwise we will get warnings.
    initialPage: Page {
        id: dummyPage
        property int currentIndex
    }

    Component {
        id: fullscreenPageComponent

        GalleryFullscreenPage {
            id: fullscreenPage
            currentIndex: 0
            orientation: Orientation.Portrait
            allowedOrientations: Orientation.Portrait | Orientation.Landscape
        }
    }

    Component.onCompleted: fullscreenPage = pageStack.push(fullscreenPageComponent)

    TestEvent { id: testEvent }

    TestCase {
        name: "FullscreenPage"
        when: windowShown

        function cleanupTestCase() {
            pageStack.pop(null, PageStackAction.Immediate)
        }

        function test_title() {
            // Can't test long title anymore because now it uses opacity ramp effect,
            // which doesn't really change the width of the painted text.
            fullscreenPage.model = albumModel
            wait(500)
            var imageView = Util.findItemByName(fullscreenPage, "flickableView")
            verify(imageView !== null)

            var imageTitle = Util.findItemByName(fullscreenPage, "imageTitle")
            compare(imageTitle.text, "Photo 0")

            imageView.currentIndex = 1
            tryCompare(imageTitle, 'text', "Photo 1")

            imageView.currentIndex = 2
            tryCompare(imageTitle, 'text', "Photo 2")

            imageView.currentIndex = 3
            tryCompare(imageTitle, 'text', "Photo 3")
        }

        function test_accented_file_name_loading()
        {
            fullscreenPage.model = accentedFileNameModel
            var imageView = Util.findItemByName(fullscreenPage, "flickableView")
            verify(imageView !== null)

            // Get zoomable image
            var zoomableImage = Util.findItemByName(imageView, "zoomableImage")
            verify(zoomableImage !== null)

            wait(500)
            // First we have a photo with "" as url which should give a NULL status
            tryCompare(zoomableImage, 'status', Image.Null)
            // Next test loading of "non-standard" filenames

            accentedFileNameModel.setProperty(0, "url", "file:///opt/tests/jolla-gallery/auto/images/photo_ä_ö_å_é.jpg")
            imageView.currentIndex = 0
            tryCompare(zoomableImage, 'status', Image.Ready)

            // QImage can't handle percent encoded values, but oth we should never even get these from the QtDocGalleryModel
            accentedFileNameModel.setProperty(0, "url", "file:///opt/tests/jolla-gallery/auto/images/photo_%101%_%E4jpg")
            tryCompare(zoomableImage, 'status', Image.Error)

            accentedFileNameModel.setProperty(0, "url", "file:///opt/tests/jolla-gallery/auto/images/photo_йггруузхц_%1.jpg")
            tryCompare(zoomableImage, 'status', Image.Ready)

            accentedFileNameModel.setProperty(0, "url", "file:///opt/tests/jolla-gallery/auto/images/photo_我_有_你_.jpg")
            tryCompare(zoomableImage, 'status', Image.Ready)
        }

    ListModel {
        id: albumModel
        ListElement { itemId: "photo0"; mimeType: "image/jpeg"; title: "Photo 0"; width: 453; height: 708; orientation: 0; url: "file:///opt/tests/jolla-gallery/auto/images/photo_0.jpg" }
        ListElement { itemId: "photo1"; mimeType: "image/jpeg"; title: "Photo 1"; width: 453; height: 708; orientation: 0; url: "file:///opt/tests/jolla-gallery/auto/images/photo_1.jpg" }
        ListElement { itemId: "photo2"; mimeType: "image/jpeg"; title: "Photo 2"; width: 453; height: 708; orientation: 0; url: "file:///opt/tests/jolla-gallery/auto/images/photo_2.jpg" }
        ListElement { itemId: "photo3"; mimeType: "image/jpeg"; title: "Photo 3"; width: 453; height: 708; orientation: 0; url: "file:///opt/tests/jolla-gallery/auto/images/photo_3.jpg" }
    }

    ListModel {
        id: accentedFileNameModel
        ListElement { itemId: "photo4"; mimeType: "image/jpeg"; title: "Photo 4"; width: 453; height: 708; orientation: 0; url: "" }
    }

    ListModel {
        id: singleImageModel
        ListElement { itemId: "photo0"; mimeType: "image/jpeg"; title: "Photo 0"; width: 453; height: 708; orientation: 0; url: "file:///opt/tests/jolla-gallery/auto/images/photo_0.jpg" }
    }
}
}
