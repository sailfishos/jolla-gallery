import QtQuickTest 1.0
import QtQuick 1.1
import com.jolla.components 1.0
import com.jolla.gallery 1.0
import com.jolla.gallery.test 1.0
import "scripts/Util.js" as Util

ApplicationWindow {
    id: window
    isPortrait: true
    lockOrientation: true

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
    }

    TestCase {
        name: "FullscreenPage"
        when: windowShown

        function test_title() {

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
            window.isPortrait = false

            imageView.currentIndex = 2
            compare(imageTitle.text, "Photo 2 With Long Name")
            verify(imageTitle.implicitWidth > imageTitle.width)
            verify(imageTitle.width >= imageTitle.paintedWidth)

            imageView.currentIndex = 3
            compare(imageTitle.text, "Photo 3")
            verify(imageTitle.implicitWidth < imageTitle.width)
            verify(imageTitle.width > imageTitle.paintedWidth)
        }
    }

    ListModel {
        id: albumModel

        ListElement { itemId: "photo0"; url: "file:///home/nemo/Pictures/photo0.jpg"; mimeType: "image/jpeg"; title: "Photo 0 With Long Name"  }
        ListElement { itemId: "photo1"; url: "file:///home/nemo/Pictures/photo1.jpg"; mimeType: "image/jpeg"; title: "Photo 1"  }
        ListElement { itemId: "photo2"; url: "file:///home/nemo/Pictures/photo2.jpg"; mimeType: "image/jpeg"; title: "Photo 2 With Long Name" }
        ListElement { itemId: "photo3"; url: "file:///home/nemo/Pictures/photo3.jpg"; mimeType: "image/jpeg"; title: "Photo 3" }
    }

}
