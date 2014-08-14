import QtQuick 2.0
import org.nemomobile.thumbnailer 1.0
import com.jolla.gallery 1.0

MediaSourceIcon {
    id: photoIcon

    property int galleryCount: model ? model.count : 0

    onTimerTriggered: slideShow.currentIndex = (slideShow.currentIndex + 1) % galleryCount
    timerEnabled: galleryCount > 1
    timerInterval: 8000

    ListView {
        id: slideShow
        interactive: false
        currentIndex: 0
        clip: true
        orientation: ListView.Horizontal
        cacheBuffer: width * 2
        anchors.fill: parent

        model: photoIcon.model

        delegate: Thumbnail {
            source: url
            mimeType: model.mimeType
            width: slideShow.width
            height: slideShow.height
            sourceSize.width: slideShow.width
            sourceSize.height: slideShow.width
        }
    }
}
