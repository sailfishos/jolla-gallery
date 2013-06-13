import QtQuick 2.0
import org.nemomobile.thumbnailer 1.0
import com.jolla.gallery 1.0

MediaSourceIcon {
    id: thumbnail

    property int iconIndex: 1
    timerInterval: 10000
    timerEnabled: media.count > 1

    GalleryThumbnail {
        id: icon1
        sourceSize.width: thumbnail.width
        sourceSize.height: thumbnail.height
        anchors.fill: parent
        priority: Thumbnail.HighPriority
        Behavior on opacity { NumberAnimation { duration: 1500 }}
    }

    GalleryThumbnail {
        id: icon2
        // Just show the first item from the model in the beginning.
        // after everything's loaded, we use timer to make a slideshow
        // effect.
        source: media.count > 0 ? media.model.get(0).url : ""
        mimeType: media.count > 0 ? media.model.get(0).mimeType : ""
        sourceSize.width: thumbnail.width
        sourceSize.height: thumbnail.height
        anchors.fill: parent
        priority: Thumbnail.HighPriority
        Behavior on opacity { NumberAnimation { duration: 1500 }}
    }

    onTimerTriggered: {
        var modelIndex = Math.floor((Math.random()*media.model.count));

        if (iconIndex % 2 == 0) {
            var modelData = media.model.get(modelIndex)
            icon2.source = modelData.url
            icon2.mimeType = modelData.mimeType
            icon1.opacity = 0
            icon2.opacity = 1
        } else {
            var modelData = media.model.get(modelIndex)
            icon1.source = modelData.url
            icon1.mimeType = modelData.mimeType
            icon2.opacity = 0
            icon1.opacity = 1
        }
        ++iconIndex;
    }
}
