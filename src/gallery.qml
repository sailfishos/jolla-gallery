import QtQuick 2.0
import Sailfish.Silica 1.0
import com.jolla.gallery 1.0
import "pages"
import "pages/scripts/AlbumManager.js" as AlbumManager

ApplicationWindow {
    id: window

    FileInfo { id: thumbnailHelper }

    // For some reason if the gallery is launched via invoker, it sets codecForLocale to
    // be ISO8859-1 instead of UTF-8 which causes the loading failure of the images using
    // Chinese characters. This can be used as a workaround for a bug: JB#11179.
    // NOTE: Setting codec in main.cpp doesn't seem to have any effect at all
    TextCodec { codecForLocale: "UTF-8" }

    cover: GalleryCover {}
    initialPage: Component { GalleryStartPage {} }
}

