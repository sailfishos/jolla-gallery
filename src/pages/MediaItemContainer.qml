import QtQuick 2.0
import Sailfish.Silica 1.0


Item {
    id: fsMediaItem
    property url source
    property string mimeType
    property bool itemScaled: mediaItem !== null && mediaItem.itemScaled
    property bool enableZoom
    property bool imageItem: mimeType.substring(0,5) !== "video"
    property bool isCurrentItem
    property bool isPortrait
    property bool menuOpen
    property QtObject mediaItem: null

    signal clicked
    clip: true

    Component {
        id: imageComponent

        ZoomableImage {
            objectName: "imageDelegate"

            anchors.fill: parent
            source: fsMediaItem.source
            menuOpen: fsMediaItem.menuOpen
            isPortrait: fsMediaItem.isPortrait

            onClicked: fsMediaItem.clicked()
        }
    }

    Component {
        id: videoComponent

        VideoPlayer {
            property bool itemScaled

            objectName: "videoDelegate"

            anchors.fill: parent
            source: fsMediaItem.source
            mimeType: fsMediaItem.mimeType
            menuOpen: fsMediaItem.menuOpen

            onClicked: fsMediaItem.clicked()
        }
    }

    function loadMediaContent(source, mimeType)
    {
        fsMediaItem.source = source
        fsMediaItem.mimeType = mimeType

        delayedComponentCreator.restart()
    }

    Timer {
        id: delayedComponentCreator
        interval: 1
        onTriggered: {
            // Destroy the old media item if the type is different, otherwise
            // the old media item is reused.
            if (mediaItem !== null && mediaItem.mimeType != fsMediaItem.mimeType) {
                mediaItem.destroy()
                mediaItem = null
            }
            if (mediaItem == null) {
                mediaItem = imageItem
                        ? imageComponent.createObject(fsMediaItem)
                        : videoComponent.createObject(fsMediaItem)
            }
        }
    }
 }
