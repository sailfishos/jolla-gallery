import QtQuick 2.0
import Sailfish.Silica 1.0
import com.jolla.gallery 1.0
import "pages"
import "pages/scripts/AlbumManager.js" as AlbumManager

ApplicationWindow {
    id: window

    FileInfo { id: thumbnailHelper }

    cover: GalleryCover {}
    initialPage: Component { GalleryStartPage {} }
}

