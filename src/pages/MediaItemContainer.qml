import QtQuick 1.1
import com.jolla.components 1.0


Rectangle {
    id: fsMediaItem
    property url source
    property string mimeType
    property bool itemScaled: mediaItem !== null && mediaItem.itemScaled
    property QtObject mediaItem: null
    color: "black"

    Component {
        id: imageComponent

        ZoomableImage {
            anchors.fill: parent
            source: fsMediaItem.source
            alignTop: fsMediaItem.parent.alignMiddle
        }
    }

    Component {
        id: videoComponent

        VideoPlayer {
            property bool itemScaled: false

            anchors.fill: parent
            source: fsMediaItem.source

        }
    }

    function loadMediaContent(source, mimeType)
    {
        // Destroy the old media item if the type is different, otherwise
        // the old media item is reused.
        if (mediaItem !== null && mediaItem.mimeType !== mimeType){
            mediaItem.destroy()
            mediaItem = null
        }

        fsMediaItem.source = source
        fsMediaItem.mimeType = mimeType

        if (mediaItem == null){
            mediaItem = mimeType.substring(0,5) !== "video"
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
