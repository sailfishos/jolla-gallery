import QtQuick 1.1
import org.nemomobile.thumbnailer 1.0

Item {
    id: thumbnail

    Thumbnail {
        id: icon1
        sourceSize.width: thumbnail.width
        sourceSize.height: thumbnail.height
        anchors.fill: parent
        priority: Thumbnail.HighPriority
        Behavior on opacity { NumberAnimation { duration: 1500 }}
    }

    Thumbnail {
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

    Timer {
        property int iconIndex: 1
        interval: 10000
        repeat: true
        running: window.applicationActive && media.count > 1
        onTriggered: {
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
}
