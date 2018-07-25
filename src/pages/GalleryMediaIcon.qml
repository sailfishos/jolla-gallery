import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.thumbnailer 1.0
import com.jolla.gallery 1.0

MediaSourceIcon {
    id: root

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

        model: root.model

        delegate: Thumbnail {
            source: url
            mimeType: model.mimeType
            width: slideShow.width
            height: slideShow.height
            sourceSize.width: slideShow.width
            sourceSize.height: slideShow.width
        }
    }

    Loader {
        anchors.centerIn: parent
        active: galleryCount == 0
        sourceComponent: Rectangle {
            width: root.height
            height: root.height
            gradient: Gradient {
                GradientStop { position: 0.0; color: Theme.rgba(Theme.primaryColor, 0.1) }
                GradientStop { position: 1.0; color: "transparent" }
            }

            Image {
                anchors.centerIn: parent
                source: "image://theme/icon-l-image"
            }
        }
    }
}
