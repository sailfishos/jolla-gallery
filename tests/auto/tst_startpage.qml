import QtQuickTest 1.0
import QtQuick 1.0
import Sailfish.Silica 1.0
import com.jolla.gallery 1.0
import com.jolla.gallery.test 1.0
import "scripts/Util.js" as Util

ApplicationWindow {
    id: window

    property string currentPageName: pageStack.currentPage != null
            ? pageStack.currentPage.objectName
            : ""

    initialPage: GalleryStartPage {
        id: startPage
        objectName: "startPage"
    }

    TestCase {
        name: "StartPage"
        when: windowShown

        function cleanup() {
            // Clear all items.
            albumsModel.clear()
            testService.updateGraph("http://www.tracker-project.org/temp/nmm#ImageList")

            // Return to the start page
            window.pageStack.pop(null, true)
        }

        function test_staticAlbums() {
            var albumView = Util.findItemByName(startPage, "albumsView")
            verify(albumView !== undefined)
            tryCompare(albumView, "count", 2)

            var delegate = Util.findItem(albumView, function(item) {
                return item.objectName == "titleLabel" && item.text == qsTrId("gallery-bt-photos")
            }).parent
            verify(delegate !== undefined)

            var countLabel = Util.findItemByName(delegate, "countLabel")
            tryCompare(countLabel, "text", "2")    // queries are asynchronous and the results may not be available immediately.

            delegate = Util.findItem(albumView, function(item) {
                return item.objectName == "titleLabel" && item.text == qsTrId("gallery-bt-videos")
            }).parent
            verify(delegate !== undefined)
            countLabel = Util.findItemByName(delegate, "countLabel")
            tryCompare(countLabel, "text", "1")
        }

        function test_dynamicAlbums() {
            var albumView = Util.findItemByName(startPage, "albumsView")
            verify(albumView !== undefined)
            compare(albumView.count, 2)

            albumsModel.append({ "identifier": "album1", "title": "Album 1", "count": "3" })
            albumsModel.append({ "identifier": "album2", "title": "Album 2", "count": "4" })

            testService.updateGraph("http://www.tracker-project.org/temp/nmm#ImageList")
            tryCompare(albumView, "count", 4)

            var delegate = Util.findItem(albumView, function(item) {
                return item.objectName == "titleLabel" && item.text == "Album 1"
            }).parent
            verify(delegate !== undefined)

            var countLabel = Util.findItemByName(delegate, "countLabel")
            tryCompare(countLabel, "text", "3")

            delegate = Util.findItem(albumView, function(item) {
                return item.objectName == "titleLabel" && item.text == "Album 2"
            }).parent
            verify(delegate !== undefined)
            countLabel = Util.findItemByName(delegate, "countLabel")
            tryCompare(countLabel, "text", "4")

            // Remove an item.
            albumsModel.remove(0)
            testService.updateGraph("http://www.tracker-project.org/temp/nmm#ImageList")
            tryCompare(albumView, "count", 3)

            delegate = Util.findItem(albumView, function(item) {
                return item.objectName == "titleLabel" && item.text == "Album 1"
            })
            verify(delegate === undefined)

            delegate = Util.findItem(albumView, function(item) {
                return item.objectName == "titleLabel" && item.text == "Album 2"
            }).parent
            verify(delegate !== undefined)

            // Restore an item
            albumsModel.append({ "identifier": "album1", "title": "Album 1", "count": "3" })
            testService.updateGraph("http://www.tracker-project.org/temp/nmm#ImageList")
            tryCompare(albumView, "count", 4)
            delegate = Util.findItem(albumView, function(item) {
                return item.objectName == "titleLabel" && item.text == "Album 1"
            }).parent
            verify(delegate !== undefined)
        }

        function test_openAlbum() {
            var delegate = Util.findItem(startPage, function(item) {
                return item.objectName == "titleLabel" && item.text == qsTrId("gallery-bt-photos")
            }).parent
            verify(delegate !== undefined)

            mouseClick(delegate, delegate.width / 2, delegate.height / 2)

            tryCompare(window, "currentPageName", "gridPage")

            // Use the view count to verify the correct page has been loaded.
            var gridView = Util.findItemByName(window.pageStack.currentPage, "gridView")
            verify(gridView !== undefined)
            compare(gridView.count, 2)
        }
    }

    ListModel {
        id: albumsModel
    }

    ListModel {
        id: photoModel
        ListElement { identifier: "photo1"; url: "/home/nemo/Pictures/photo1.jpg"; mimeType: "image/jpeg"; title: "Photo 1"  }
        ListElement { identifier: "photo2"; url: "/home/nemo/Pictures/photo2.jpg"; mimeType: "image/jpeg"; title: "Photo 2" }
    }

    ListModel {
        id: videoModel
        ListElement { identifier: "video1"; url: "/home/nemo/Videos1.ogv"; mimeType: "video/ogg"; title: "Video 1" }
    }

    ListModel {
        id: albumModel1

        ListElement { identifier: "photo1"; url: "file:///home/nemo/Pictures/photo1.jpg"; mimeType: "image/jpeg"; title: "Photo 1"  }
        ListElement { identifier: "photo2"; url: "file:///home/nemo/Pictures/photo2.jpg"; mimeType: "image/jpeg"; title: "Photo 2" }
        ListElement { identifier: "photo3"; url: "file:///home/nemo/Pictures/photo3.jpg"; mimeType: "image/jpeg"; title: "Photo 3" }
    }

    ListModel {
        id: albumModel2

        ListElement { identifier: "photo1"; url: "file:///home/nemo/Pictures/photo1.jpg"; mimeType: "image/jpeg"; title: "Photo 1" }
        ListElement { identifier: "photo2"; url: "file:///home/nemo/Pictures/photo2.jpg"; mimeType: "image/jpeg"; title: "Photo 2" }
        ListElement { identifier: "photo3"; url: "file:///home/nemo/Pictures/photo3.jpg"; mimeType: "image/jpeg"; title: "Photo 3" }
        ListElement { identifier: "photo4"; url: "file:///home/nemo/Pictures/photo4.jpg"; mimeType: "image/jpeg"; title: "Photo 4" }
    }

    TestDBusService {
        id: testService

        onQuery: {
            var model
            var printRow
            var printPhotoRow = function(row) { returnRow([row.identifier, "http://www.tracker-project.org/temp/nmm#Photo", row.url, row.mimeType, row.title]) }
            if (argument == "SELECT ?x nie:title(?x) nfo:entryCounter(?x) WHERE {{?x rdf:type nmm:ImageList}} GROUP BY ?x ORDER BY ASC(nie:title(?x))") {
                model = albumsModel
                printRow  = function(row) { returnRow([row.identifier, row.title, row.count]) }
            } else if (argument == "SELECT ?x nie:url(?x) rdf:type(?x) nie:url(?x) nie:mimeType(?x) nie:title(?x) WHERE {{?x rdf:type nmm:Photo}} GROUP BY ?x") {
                model = photoModel
                printRow  = printPhotoRow
            } else if (argument == "SELECT ?x nie:url(?x) rdf:type(?x) nie:url(?x) nie:mimeType(?x) nie:title(?x) WHERE {{?x rdf:type nfo:Video}} GROUP BY ?x") {
                model = videoModel
                printRow  = function(row) { returnRow([row.identifier, "http://www.tracker-project.org/temp/nfo#Video", row.url, row.mimeType, row.title]) }
            } else if (argument == "SELECT ?x nie:url(?x) rdf:type(?x) nie:url(?x) nie:mimeType(?x) nie:title(?x) WHERE {{?x rdf:type nmm:Photo}{<album1> nfo:hasMediaFileListEntry ?entry}FILTER(nie:url(?x) = nfo:entryUrl(?entry))} GROUP BY ?x") {
                model = albumModel1
                printRow  = printPhotoRow
            } else if (argument == "SELECT ?x nie:url(?x) rdf:type(?x) nie:url(?x) nie:mimeType(?x) nie:title(?x) WHERE {{?x rdf:type nmm:Photo}{<album2> nfo:hasMediaFileListEntry ?entry}FILTER(nie:url(?x) = nfo:entryUrl(?entry))} GROUP BY ?x") {
                model = albumModel2
                printRow  = printPhotoRow
            } else {
                console.log("unhandled query", argument)
                return
            }

            for (var i = 0; i < model.count; ++i)
                printRow(model.get(i))
        }
    }
}
