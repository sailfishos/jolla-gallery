import QtQuick 1.1
import org.nemomobile.thumbnailer 1.0

/**
  * GridThumbnail is for displaying either photo or video thumbnail.
  * NOTE: At the moment it only supports photothumbnails.
  */
Image{
    id: thumbnail
    signal clicked
    width: GridView.view.cellWidth
    height: GridView.view.cellHeight
    sourceSize.width: width
    sourceSize.height: height
    asynchronous: true

    function isVideo()
    {
        return (mimeType.substring(0,5) === "video")
    }

    function loadImageThumbnail()
    {
        source = "image://nemoThumbnail/" + url
    }

    function loadVideoThumbnail()
    {
        // TODO: show video thumbnails when available
        // Just show a black rectangle because we can't get video thumbs atm.
        var rect = Qt.createQmlObject('import QtQuick 1.1; Rectangle { }', thumbnail, "thumbnail")
        rect.width = width
        rect.height= height
        rect.color = "black"
        rect.border.color = "white"
    }

    Component.onCompleted: isVideo() ? loadVideoThumbnail() : loadImageThumbnail()

    Behavior on scale { NumberAnimation{ duration: 150 }}

    MouseArea {
        anchors.fill: parent
        onClicked: parent.clicked()
        onPressed: thumbnail.scale = 0.95
        onReleased: thumbnail.scale = 1
    }
}
