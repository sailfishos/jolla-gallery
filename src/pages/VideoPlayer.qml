import QtQuick 1.1
import com.jolla.components 1.0
import QtMultimediaKit 1.1
import org.nemomobile.thumbnailer 1.0

Item {
    id: player
    property alias source: poster.source
    property alias mimeType: poster.mimeType
    property alias video: videoLoader.item
    property bool alignTop
    property bool playing

    property real windowWidth: window.isPortrait
            ? Math.min(window.width, window.height)
            : Math.max(window.width, window.height)
    property real windowHeight: window.isPortrait
            ? Math.max(window.width, window.height)
            : Math.min(window.width, window.height)

    property real minimumDimension: Math.min(window.width, window.height)
    property real maximumDimension: Math.max(window.width, window.height)

    property real scale: minimumDimension / implicitHeight

    implicitWidth: video === null || video.implicitWidth === 0
            ? poster.implicitWidth !== 0 ? poster.implicitWidth : windowWidth
            : video.implicitWidth
    implicitHeight: video === null || video.implicitHeight === 0
            ? poster.implicitHeight !== 0 ? poster.implicitHeight : windowHeight
            : video.implicitHeight

    clip: alignTop

    onSourceChanged: videoLoader.sourceComponent = null

    onPlayingChanged: {
        if (playing) {
            videoLoader.sourceComponent = videoComponent
            video.playing = true
        }
    }

    Component {
        id: videoComponent

        Video {
            id: video

            // Hide the Video item when the application isn't active or it doesn't have
            // anything meaningful to display otherwise the overlay may draw over the
            // homescreen, other applications, or other videos.
            visible:  window.applicationActive
                    && fsMediaItem.isCurrentItem
                    && video.status >= Video.Loaded
                    && video.status <= Video.EndOfMedia

            source: player.source
            playing: true
            paused: !window.applicationActive
                    || !fsMediaItem.isCurrentItem
                    || alignTop
                    || !player.playing

            onPlayingChanged: {
                if (!playing)
                    player.playing = false
            }
        }
    }

    Item {
        // Lock the orientation to landscape as the current configuration on QtMultimediaKit
        // uses an X overlay which refuses to render in anything but landscape.
        width: maximumDimension
        height: minimumDimension

        anchors.centerIn: parent

        rotation: window.isPortrait ? 90 : 0

        Loader {
            id: videoLoader

            width: video !== null ? video.implicitWidth * player.scale : maximumDimension
            height: video !== null ? video.implicitHeight * player.scale : minimumDimension

            anchors.centerIn: parent
        }

        Thumbnail {
            id: poster

            anchors.centerIn: parent

            width: poster.implicitWidth * player.scale
            height: poster.implicitHeight * player.scale

            sourceSize.width: maximumDimension
            sourceSize.height: maximumDimension

            priority: Thumbnail.HighPriority
            fillMode: Thumbnail.PreserveAspectFit
            visible: video === null || !video.visible
        }

        Row {  // Rectangle
            id: controls

            opacity: player.alignTop || !player.playing ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: 150 } }
            visible: opacity !== 0.0

            anchors {
                horizontalCenter: parent.horizontalCenter
                bottom: parent.bottom
            }

            ToolIcon {
                iconSource: player.playing ? "images/icon-m-pause.png" : "images/icon-m-play.png"
                onClicked: player.playing = !player.playing
            }
        }
    }
}
