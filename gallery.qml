import QtQuick 1.1
import com.jolla.components 1.0
import "pages"

ApplicationWindow {
    id: window

    cover: Image {
        source: "dummydata/images/cover-gallery.png"
        anchors.fill: parent
        Rectangle {
            z: -1
            anchors.fill: parent
        }
    }
    initialPage: GalleryGridPage {}
}

