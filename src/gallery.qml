import QtQuick 1.1
import com.jolla.components 1.0
import "pages"

ApplicationWindow {
    id: window

    // Only portrait is supported atm.
    lockOrientation: true

    cover: undefined
    initialPage: GalleryStartPage {}
}

