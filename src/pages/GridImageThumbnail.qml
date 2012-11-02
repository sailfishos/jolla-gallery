import QtQuick 1.1
import org.nemomobile.thumbnailer 1.0

/**
  * GridThumbnail is for displaying either photo or video thumbnail.
  * NOTE: At the moment it only supports photothumbnails.
  */
Image {
    id: thumbnail
    signal clicked    
    property bool secondRow: index <= 5 && 3 <= index

    sourceSize.width: 160
    sourceSize.height: 160
    asynchronous: true
    source: model.thumbnailUrl === undefined ? "image://nemoThumbnail/" + model.url : model.thumbnailUrl
    opacity: GridView.view.showTitle && secondRow ? 0 : 1
    z: scale > 1 ? 100 : 0
    smooth: scale != 1.0

    // Animation for displaying a title. Used only once for the
    // second row items.
    NumberAnimation on opacity {
        id: opacityAnimation
        duration: 1500
        to: 1
        onCompleted: thumbnail.GridView.view.showTitle = false
        running: thumbnail.GridView.view.showTitle
    }

    Behavior on scale { NumberAnimation { duration: 150 }}

    MouseArea {
        anchors.fill: parent
        onClicked: parent.clicked()

        // Indicate selection by scaling the thumbnail, but it's allowed to do
        // when grid is not moving and contains mouse
        onPressed: {
            if (!thumbnail.GridView.view.movingVertically && !thumbnail.GridView.view.flicking && containsMouse){
                thumbnail.scale = 1.1
                thumbnail.GridView.view.itemSelected = true
                thumbnail.state = "highlight"
            }
        }

        // Cancel selection on release or on cancel
        onReleased: {
            thumbnail.scale = 1.0
            thumbnail.GridView.view.itemSelected = false
            thumbnail.state = ""
        }

        onCanceled: {
            thumbnail.scale = 1.0
            thumbnail.GridView.view.itemSelected = false
            thumbnail.state = ""
        }
    }

    states: State {
        name: "highlight"
        ParentChange { target:thumbnail; parent: thumbnail.GridView.view.overlay;  }
    }
}
