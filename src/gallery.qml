import QtQuick 1.1
import Sailfish.Silica 1.0
import com.jolla.gallery 1.0
import "pages"
import "pages/scripts/AlbumManager.js" as AlbumManager

ApplicationWindow {
    id: window

    property bool isPortrait: orientation === Orientation.Portrait || orientation === Orientation.PortraitInverted

    // All pages support portrait and landscape orientations
    allowedOrientations: Orientation.All

    // Ensure the Wallpapers album exists and has the correct translated name.
    Component.onCompleted: {
        //% "Ambience"
        AlbumManager.createAlbum("<urn:jolla-gallery:albums:wallpapers>", qsTrId("gallery-bt-ambience"))
    }

    FileInfo { id: thumbnailHelper }

    cover: GalleryCover {}
    initialPage: Component { GalleryStartPage {} }
}

