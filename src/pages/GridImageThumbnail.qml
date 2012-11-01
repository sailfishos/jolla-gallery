import QtQuick 1.1
import org.nemomobile.thumbnailer 1.0

/**
  * GridThumbnail is for displaying either photo or video thumbnail.
  * NOTE: At the moment it only supports photothumbnails.
  */
Image{
    id: thumbnail
    signal clicked    
    property bool secondRow: index <= 5 && 3 <= index

    sourceSize.width: 160
    sourceSize.height: 160
    asynchronous: true
    source: model.thumbnailUrl == undefined ? "image://nemoThumbnail/" + model.url : model.thumbnailUrl
    scale: !GridView.view.movingVertically && mouse.pressed && mouse.containsMouse ? 1.1 : 1
    opacity: GridView.view.showTitle && secondRow ? 0 : 1
    z: scale > 1 ? 10 : 0

    // Animation for displaying a title
    NumberAnimation on opacity {
        id: opacityAnimation
        duration: 1500
        to: 1
        onCompleted: thumbnail.GridView.view.showTitle = false
        running: thumbnail.GridView.view.showTitle
    }

    Behavior on scale { NumberAnimation { duration: 200 }}

    MouseArea {
        id: mouse
        anchors.fill: parent
        onClicked: parent.clicked()
    }
}
