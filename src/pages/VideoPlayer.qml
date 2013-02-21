import QtQuick 1.1
import Sailfish.Silica 1.0
// Use a namespace to avoid any ambiguity between component VideoPlayer and this.
import com.jolla.components.media 1.0 as Media

Item {
    id: player
    property alias source: video.source
    property alias mimeType: video.mimeType
    property Item menu

    property real windowWidth: isPortrait
            ? Math.min(window.width, window.height)
            : Math.max(window.width, window.height)
    property real windowHeight: isPortrait
            ? Math.max(window.width, window.height)
            : Math.min(window.width, window.height)

    property real minimumDimension: Math.min(window.width, window.height)
    property real maximumDimension: Math.max(window.width, window.height)

    signal clicked

    clip: menu.visible

    // Container item to lock the orientation to landscape as the current configuration of
    // QtMultimediaKit uses an X overlay which refuses to render in anything but landscape.
    Rectangle {
        width: maximumDimension
        height: minimumDimension

        anchors.centerIn: parent
        rotation: isPortrait ? 90 : 0

        color: "black"

        Media.VideoPlayer {
            id: video

            anchors.fill: parent

            suspend: !window.applicationActive || !fsMediaItem.isCurrentItem || player.menu.visible
            active: window.applicationActive && fsMediaItem.isCurrentItem && fullscreenPage.status === PageStatus.Active
        }

        MouseArea {
            anchors.fill: parent

            onClicked: {
                player.clicked()
            }
        }

        Item {
            anchors.fill: parent
            opacity: !video.playing ? 1.0 : menu.progress
            Behavior on opacity { SmoothedAnimation { duration: -1; velocity: 200 } }

            Rectangle {
                anchors.fill: parent
                color: "black"
                opacity: 0.3
            }

            Image {
                anchors.centerIn: parent
                source: "image://theme/icon-cover-play"

                MouseArea {
                    anchors.fill: parent
                    enabled: !video.playing
                    onClicked: video.playing = true
                }
            }

            Media.PlayerControls {
                id: controls

                width: isPortrait ? player.height : player.width
                anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.bottom }

                visible: opacity !== 0.0

                position: video.position
                duration: video.duration

                onSeek: video.seek(position)
            }
        }
    }
}
