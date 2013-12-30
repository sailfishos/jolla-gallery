import QtTest 1.0
import QtQuick 2.0
import Sailfish.Silica 1.0
import com.jolla.gallery 1.0
//import com.jolla.gallery.test 1.0
import "scripts/Util.js" as Util

ApplicationWindow {
    id: window
    property string currentPageName: pageStack.currentPage != null
            ? pageStack.currentPage.objectName
            : ""
    property MediaSourceModel model: null
    FileInfo {
        id: thumbnailHelper
    }

    initialPage: GalleryStartPage {
        id: startPage
        objectName: "startPage"
        allowedOrientations: Orientation.Portrait
        orientation: Orientation.Portrait
    }

    TestCase {
        name: "StartPage"
        when: windowShown

        function initTestCase()
        {
            var albumView = Util.findItemByName(startPage, "albumsView")
            verify(albumView !== undefined)
            model = albumView.model
        }

        function cleanup() {
            // Return to the start page
            window.pageStack.pop(null, PageStackAction.Immediate)

            // Init to default model
            var albumView = Util.findItemByName(startPage, "albumsView")
            verify(albumView !== undefined)
             albumView.model = model
        }


        function test_staticAlbums() {
            var albumView = Util.findItemByName(startPage, "albumsView")

            verify(albumView !== undefined)
            tryCompare(albumView, "count", 3)

            var delegate = Util.findItem(albumView, function(item) {
                return item.objectName == "titleLabel" && item.text == qsTrId("gallery-bt-photos")
            }).parent
            verify(delegate !== undefined)

            var countLabel = Util.findItemByName(delegate, "countLabel")
            tryCompare(countLabel, "text", "2")    // queries are asynchronous and the results may not be available immediately.


            delegate = Util.findItem(albumView, function(item) {
                return item.objectName === "titleLabel" && item.text === qsTrId("gallery-bt-videos")
            }).parent

            verify(delegate !== undefined)
            countLabel = Util.findItemByName(delegate, "countLabel")
            tryCompare(countLabel, "text", "1")
        }


        function test_customAlbums() {
            var albumView = Util.findItemByName(startPage, "albumsView")
            verify(albumView !== undefined)
            albumView.model = albumsModel

            tryCompare(albumView, "count", 6)
            tryCompare(albumsModel, "count", 6)

            var delegate = Util.findItem(albumView, function(item) {
                return item.objectName == "titleLabel" && item.text == "Album 1"
            }).parent
            verify(delegate !== null)
            var countLabel = Util.findItemByName(delegate, "countLabel")
            tryCompare(countLabel, "text", "3")

            var delegate = Util.findItem(albumView, function(item) {
                return item.objectName == "titleLabel" && item.text == "Album 2"
            }).parent
            verify(delegate !== null)
            var countLabel = Util.findItemByName(delegate, "countLabel")
            tryCompare(countLabel, "text", "40")

            var delegate = Util.findItem(albumView, function(item) {
                return item.objectName == "titleLabel" && item.text == "Album 3"
            }).parent
            verify(delegate !== null)
            var countLabel = Util.findItemByName(delegate, "countLabel")
            tryCompare(countLabel, "text", "200")

            var delegate = Util.findItem(albumView, function(item) {
                return item.objectName == "titleLabel" && item.text == "Album 4"
            }).parent
            verify(delegate !== null)
            var countLabel = Util.findItemByName(delegate, "countLabel")
            tryCompare(countLabel, "text", "3000")

            delegate = Util.findItem(albumView, function(item) {
                return item.objectName == "titleLabel" && item.text == "Album 5"
            }).parent
            verify(delegate !== null)
            countLabel = Util.findItemByName(delegate, "countLabel")
            tryCompare(countLabel, "text", "50000")
        }

        function test_dynamicAlbum() {
            var albumView = Util.findItemByName(startPage, "albumsView")

            verify(albumView !== undefined)
            tryCompare(albumView, "count", 3)

            var delegate = Util.findItem(albumView, function(item) {
                return item.objectName == "titleLabel" && item.text == "dynamic-gallery-album"
            }).parent
            verify(delegate !== undefined)

            var countLabel = Util.findItemByName(delegate, "countLabel")
            tryCompare(countLabel, "text", "3")
        }

        function test_openAlbum() {
            var delegate = Util.findItem(startPage, function(item) {
                return item.objectName == "titleLabel" && item.text == qsTrId("gallery-bt-photos")
            }).parent
            verify(delegate !== undefined)

            mouseClick(delegate, delegate.width / 2, delegate.height / 2)
            tryCompare(window.pageStack, "busy", false)

            tryCompare(window, "currentPageName", "gridPage")

            // Use the view count to verify the correct page has been loaded.
            var gridView = Util.findItemByName(window.pageStack.currentPage, "gridView")
            verify(gridView !== undefined)
            tryCompare(gridView, "count", 2)
        }

        function test_dbusShowPhotos() {
            galleryService.showPhotos()
            tryCompare(window, "currentPageName", "gridPage")

            // Use the view count to verify the correct page has been loaded.
            var gridView = Util.findItemByName(window.pageStack.currentPage, "gridView")
            verify(gridView !== undefined)
            tryCompare(gridView, "count", 2)
        }

        function test_dbusShowVideos() {
            galleryService.showVideos()
            tryCompare(window, "currentPageName", "gridPage")

            // Use the view count to verify the correct page has been loaded.
            var gridView = Util.findItemByName(window.pageStack.currentPage, "gridView")
            verify(gridView !== undefined)
            tryCompare(gridView, "count", 1)
        }
    }

    MediaSourceModel {
        id: albumsModel
        MediaSource { title: "Album 1"; icon: ""; page: ""; ready: true; count: 3; type: MediaSource.Photos}
        MediaSource { title: "Album 2"; icon: ""; page: ""; ready: true; count: 40; type: MediaSource.Photos}
        MediaSource { title: "Album 3"; icon: ""; page: ""; ready: true; count: 200; type: MediaSource.Photos}
        MediaSource { title: "Album 4"; icon: ""; page: ""; ready: true; count: 3000; type: MediaSource.Photos}
        MediaSource { title: "Album 5"; icon: ""; page: ""; ready: true; count: 50000; type: MediaSource.Photos}
    }

    ListModel {
        id: photosModel
        ListElement { identifier: "photo1"; url: "/home/nemo/Pictures/photo1.jpg"; mimeType: "image/jpeg"; title: "Photo 1"; dateTaken: "2010-11-05T08:15:30-05:0" }
        ListElement { identifier: "photo2"; url: "/home/nemo/Pictures/photo2.jpg"; mimeType: "image/jpeg"; title: "Photo 2"; dateTaken: "2010-10-05T08:15:30-05:0" }
    }

    ListModel {
        id: videosModel
        ListElement { identifier: "video1"; url: "/home/nemo/Videos1.ogv"; mimeType: "video/ogg"; title: "Video 1"}
    }

    ListModel {
        id: albumModel1

        ListElement { identifier: "photo1"; url: "file:///home/nemo/Pictures/photo1.jpg"; mimeType: "image/jpeg"; title: "Photo 1"; dateTaken: "2010-11-05T08:15:30-05:0" }
        ListElement { identifier: "photo2"; url: "file:///home/nemo/Pictures/photo2.jpg"; mimeType: "image/jpeg"; title: "Photo 2"; dateTaken: "2010-10-05T08:15:30-05:0" }
        ListElement { identifier: "photo3"; url: "file:///home/nemo/Pictures/photo3.jpg"; mimeType: "image/jpeg"; title: "Photo 3"; dateTaken: "2010-09-05T08:15:30-05:0" }
    }

    ListModel {
        id: albumModel2

        ListElement { identifier: "photo1"; url: "file:///home/nemo/Pictures/photo1.jpg"; mimeType: "image/jpeg"; title: "Photo 1"; dateTaken: "2010-11-05T08:15:30-05:0" }
        ListElement { identifier: "photo2"; url: "file:///home/nemo/Pictures/photo2.jpg"; mimeType: "image/jpeg"; title: "Photo 2"; dateTaken: "2010-10-05T08:15:30-05:0" }
        ListElement { identifier: "photo3"; url: "file:///home/nemo/Pictures/photo3.jpg"; mimeType: "image/jpeg"; title: "Photo 3"; dateTaken: "2010-09-05T08:15:30-05:0" }
        ListElement { identifier: "photo4"; url: "file:///home/nemo/Pictures/photo4.jpg"; mimeType: "image/jpeg"; title: "Photo 4"; dateTaken: "2010-08-05T08:15:30-05:0" }
    }

    DBusInterface {
        id: galleryService

        destination: "com.jolla.gallery"
        path: "/com/jolla/gallery/ui"
        iface: "com.jolla.gallery.ui"

        function showPhotos() {
            galleryService.call("showPhotos", undefined)
        }

        function showVideos() {
            galleryService.call("showVideos", undefined)
        }
    }
}
