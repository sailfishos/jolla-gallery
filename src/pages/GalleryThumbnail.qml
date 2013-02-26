import QtQuick 1.1
import org.nemomobile.thumbnailer 1.0

// This is a workaround for a Tracker/DocumentGalleryModel bug where
// urls might be percent encoded. The real fix needs to go to Mobility side.
// Fixes JB#4823
Thumbnail {
    property bool reloadTried

    onStatusChanged: {
        if (reloadTried === false && status === Thumbnail.Error) {
            reloadTried = true
            source = thumbnailHelper.fromPercentEncoding(source)
        }
    }
}
