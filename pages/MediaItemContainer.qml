import QtQuick 1.1
import com.jolla.components 1.0


Rectangle{
    id: fsMediaItem
    property url source
    property string mimeType
    property bool itemScaled
    property bool  alignTop: parent.alignMiddle
    property bool imageItem: mimeType.substring(0,5) !== "video"
    property QtObject mediaItem: null
    color: "black"

    function loadMediaContent()
    {
        // Destroy the old media item if the type is different, otherwise
        // the old media item is reused.
        if (mediaItem !== null && mediaItem.mimeType !== mimeType){
            mediaItem.destroy()
            mediaItem = null
        }

        if (mediaItem == null){
            var component;
            if (imageItem)
                component = Qt.createComponent("ZoomableImage.qml");
            else
                component = Qt.createComponent("VideoPlayer.qml")

            if (component.status === Component.Ready) {
                mediaItem = component.createObject(fsMediaItem);
                mediaItem.width  = fsMediaItem.width
                mediaItem.height = fsMediaItem.height
            }
        }

        // Finally set the source
        mediaItem.source = fsMediaItem.source
    }

 }
