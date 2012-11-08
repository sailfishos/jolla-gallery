import QtQuick 1.1
import com.jolla.components 1.0


Item {
    id: fsMediaItem
    property url source
    property string mimeType
    property bool itemScaled: mediaItem !== null && mediaItem.itemScaled
    property bool enableZoom: parent.enableZoom
    property bool imageItem: mimeType.substring(0,5) !== "video"
    property QtObject mediaItem: null

    Component {
        id: imageComponent

        ZoomableImage {
            anchors.fill: parent
            source: fsMediaItem.source
            alignTop: fsMediaItem.parent.alignMiddle
            clip: fsMediaItem.parent.alignMiddle
        }
    }

    Component {
        id: videoComponent

        VideoPlayer {
            anchors.fill: parent
            source: fsMediaItem.source
            mimeType: fsMediaItem.mimeType
            alignTop: fsMediaItem.parent.alignMiddle
        }
    }

    function loadMediaContent(source, mimeType)
    {
        // Destroy the old media item if the type is different, otherwise
        // the old media item is reused.
        if (mediaItem !== null && mediaItem.mimeType != mimeType) {
            mediaItem.destroy()
            mediaItem = null
        }

        fsMediaItem.source = source
        fsMediaItem.mimeType = mimeType

        if (mediaItem == null) {
            mediaItem = imageItem
                    ? imageComponent.createObject(fsMediaItem)
                    : videoComponent.createObject(fsMediaItem)
        }
    }

    function scaleToMax(centerX, centerY)
    {
        if (imageItem)
            mediaItem.scaleToMax(centerX, centerY)
    }
 }
