import QtQuick 2.0
import org.nemomobile.thumbnailer 1.0
import com.jolla.gallery 1.0

MediaSourceIcon {
    id: videoIcon

    property int galleryCount: model ? model.count : 0

    timerEnabled: galleryCount > 1
    timerInterval: 12000
    onTimerTriggered: slideShow.currentIndex = (slideShow.currentIndex + 1) % galleryCount

    ListView {
        id: slideShow
        interactive: false
        currentIndex: 0
        clip: true
        orientation: ListView.Horizontal
        cacheBuffer: width * 2
        anchors.fill: parent

        model: videoIcon.model

        delegate: Thumbnail {
            source: url
            mimeType: model.mimeType
            sourceSize.width: slideShow.width
            sourceSize.height: slideShow.width
        }
    }
}
