import QtQuick 1.1
import com.jolla.components 1.0
// Use a namespace to avoid any ambiguity between component VideoPlayer and this.
import com.jolla.components.media 1.0 as Media

Item {
    id: player
    property alias source: video.source
    property alias mimeType: video.mimeType
    property bool alignTop
    property bool showControls: player.alignTop || !video.playing

    property real windowWidth: isPortrait
            ? Math.min(window.width, window.height)
            : Math.max(window.width, window.height)
    property real windowHeight: isPortrait
            ? Math.max(window.width, window.height)
            : Math.min(window.width, window.height)

    property real minimumDimension: Math.min(window.width, window.height)
    property real maximumDimension: Math.max(window.width, window.height)

    signal clicked

    clip: alignTop

    // Container item to lock the orientation to landscape as the current configuration of
    // QtMultimediaKit uses an X overlay which refuses to render in anything but landscape.
    Item {
        width: maximumDimension
        height: minimumDimension

        anchors.centerIn: parent
        rotation: isPortrait ? 90 : 0

        MouseArea {
            anchors.fill: parent

            onClicked: {
                player.clicked()
            }
        }  
        
        // Locate the controls behind the video and clip it when they should be visible.  This
        // is because the video is an overlay and any thing not fully opaque will produce ugly
        // artifacts when drawn over the video.
        Media.PlayerControls {
            id: controls

            width: isPortrait ? player.height : player.width
            anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.bottom }

            opacity: player.showControls  ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: 150 } }
            visible: opacity !== 0.0

            position: video.position
            duration: video.duration

            onSeek: video.seek(position)

            IconButton {
                icon.source: video.playing ? "images/icon-m-pause.png" : "images/icon-m-play.png"
                onClicked: video.playing = !video.playing
            }
        }

        Item {
            anchors { fill: parent; bottomMargin: player.showControls ? controls.height : 0.0 }
            Behavior on anchors.bottomMargin { NumberAnimation { duration: 150 } }

            // Use the baseline to center the video vertically so its position doesn't change
            // when the height of the clip rect changes.
            baselineOffset: parent.height / 2

            clip: anchors.bottomMargin != 0.0

            Media.VideoPlayer {
                id: video

                width: maximumDimension
                height: minimumDimension

                anchors { horizontalCenter: parent.horizontalCenter; verticalCenter: parent.baseline }

                suspend: !window.applicationActive || !fsMediaItem.isCurrentItem || alignTop
                active: window.applicationActive && fsMediaItem.isCurrentItem
            }
        }      
    }
}
