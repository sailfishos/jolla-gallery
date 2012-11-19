import QtQuick 1.1
import com.jolla.components 1.0
import "pages"

ApplicationWindow {
    id: window

    // Force the orientation to portrait in cover view.  Only set the orientation after
    // lockOrientation becomes true to avoid possible fighting and races with the automatic
    // orientation.
    lockOrientation: !applicationActive
    onLockOrientationChanged: {
        if (lockOrientation)
            isPortrait = true
    }

    cover: undefined
    initialPage: GalleryStartPage {}
}

