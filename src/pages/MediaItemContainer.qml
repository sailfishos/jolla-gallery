import QtQuick 1.1
import com.jolla.components 1.0


Item {
    id: fsMediaItem
    property url source
    property string mimeType
    property bool itemScaled: mediaItem !== null && mediaItem.itemScaled
    property bool enableZoom
    property bool alignTop
    property bool imageItem: mimeType.substring(0,5) !== "video"
    property bool isCurrentItem
    property QtObject mediaItem: null

    signal clicked

    Component {
        id: imageComponent

        ZoomableImage {
            objectName: "imageDelegate"

            anchors.fill: parent
            source: fsMediaItem.source
            alignTop: fsMediaItem.alignTop
            clip: fsMediaItem.alignTop

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
            alignTop: fsMediaItem.alignTop

            onClicked: fsMediaItem.clicked()
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
 }
