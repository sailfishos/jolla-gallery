import QtTest 1.0
import QtQuick 2.0
import Sailfish.Silica 1.0
import com.jolla.gallery 1.0
import com.jolla.gallery.test 1.0
import "scripts/Util.js" as Util

ApplicationWindow {
    id: window


    // For GalleryFullscreenPage we need to have something on a page stack first
    // or otherwise we will get warnings.
    initialPage: Page {
        id: dummyPage
        property int currentIndex
    }

    GalleryFullscreenPage {
        id: fullscreenPage
        model: albumModel
        currentIndex: 0
        orientation: Orientation.Portrait
        allowedOrientations: Orientation.Portrait | Orientation.Landscape
    }

    TestCase {
        name: "FullscreenPage"
        when: windowShown

        function test_title() {
            // Can't test long title anymore because now it uses opacity ramp effect,
            // which doesn't really change the width of the painted text. For now
            // Let's just skip this test.
            skip()
            pageStack.push(fullscreenPage)

            var imageView = Util.findItemByName(fullscreenPage, "flickableView")
            verify(imageView !== undefined)

            // I'd like to use QML Text Element's truncated property to indicate
            // if the text has been truncated, but it doesn't seem to work properly.
            var imageTitle = Util.findItemByName(fullscreenPage, "imageTitle")
            compare(imageTitle.text, "Photo 0 With Long Name")
            verify(imageTitle.implicitWidth > imageTitle.paintedWidth)
            verify(imageTitle.width >= imageTitle.paintedWidth)

            imageView.currentIndex = 1
            compare(imageTitle.text, "Photo 1")
            verify(imageTitle.implicitWidth < imageTitle.width)
            verify(imageTitle.width > imageTitle.paintedWidth)

            // change orientation
            fullscreenPage.orientation = Orientation.Landscape

            imageView.currentIndex = 2
            compare(imageTitle.text, "Photo 2 With Long Name")
            verify(imageTitle.implicitWidth > imageTitle.width)
            verify(imageTitle.width >= imageTitle.paintedWidth)

            imageView.currentIndex = 3
            compare(imageTitle.text, "Photo 3")
            verify(imageTitle.implicitWidth < imageTitle.width)
            verify(imageTitle.width > imageTitle.paintedWidth)
        }

        function test_accented_file_name_loading()
        {
            pageStack.push(fullscreenPage)

            var imageView = Util.findItemByName(fullscreenPage, "flickableView")
            verify(imageView !== undefined)

            // Load normal image
            imageView.currentIndex = 3

            // Get zoomable image
            var zoomableImage = Util.findItemByName(imageView, "zoomableImage")
            verify(zoomableImage !== undefined)

            tryCompare(zoomableImage.reloadTried, false)

            // Next test loading of "non-standard" filenames
            // First load image, we know that should be loaded
            // after that load another image that needs reloading
            // with modified url.
            imageView.currentIndex = 2
            imageView.currentIndex = 4
            tryCompare(zoomableImage.reloadTried, true)

            imageView.currentIndex = 1
            imageView.currentIndex = 5
            tryCompare(zoomableImage.reloadTried, true)

            imageView.currentIndex = 0
            imageView.currentIndex = 5
            tryCompare(zoomableImage.reloadTried, true)

        }
    }

    ListModel {
        id: albumModel

        ListElement { itemId: "photo0"; url: "file:///home/nemo/Pictures/photo0.jpg"; mimeType: "image/jpeg"; title: "Photo 0 With Long Name"  }
        ListElement { itemId: "photo1"; url: "file:///home/nemo/Pictures/photo1.jpg"; mimeType: "image/jpeg"; title: "Photo 1"  }
        ListElement { itemId: "photo2"; url: "file:///home/nemo/Pictures/photo2.jpg"; mimeType: "image/jpeg"; title: "Photo 2 With Long Name" }
        ListElement { itemId: "photo3"; url: "file:///home/nemo/Pictures/photo3.jpg"; mimeType: "image/jpeg"; title: "Photo 3" }
        ListElement { itemId: "photo4"; url: "file:///home/nemo/Pictures/photo_ä_ö_å_é.jpg";      mimeType: "image/jpeg"; title: "Photo 4" }
        ListElement { itemId: "photo5"; url: "file:///home/nemo/Pictures/photo_%101%_%E4.jpg";    mimeType: "image/jpeg"; title: "Photo 5" }
        ListElement { itemId: "photo6"; url: "file:///home/nemo/Pictures/photo_йггруузхц_%1.jpg"; mimeType: "image/jpeg"; title: "Photo 6" }

    }

}
