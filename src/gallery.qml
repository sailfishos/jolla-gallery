import QtQuick 1.1
import com.jolla.components 1.0
import com.jolla.gallery 1.0
import "pages"
import "pages/scripts/AlbumManager.js" as AlbumManager

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

    // Ensure the Wallpapers album exists and has the correct translated name.
    Component.onCompleted: {
        //% "Ambience"
        AlbumManager.createAlbum("<urn:jolla-gallery:albums:wallpapers>", qsTrId("gallery-bt-ambience"))
    }

    cover: undefined
    initialPage: GalleryStartPage {}
}

