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
    source: "image://nemoThumbnail/" + url
    scale: !GridView.view.moving && mouse.pressed && mouse.containsMouse ? 1.1 : 1
    opacity: GridView.view.showTitle && secondRow ? 0 : GridView.view.itemSelected && scale === 1 ? 0.1 : 1
    onScaleChanged: GridView.view.itemSelected = scale > 1

    // Animation for displaying a title
    NumberAnimation on opacity {
        id: opacityAnimation
        duration: 2500
        to: 1
        onCompleted: thumbnail.GridView.view.showTitle = false
        running: thumbnail.GridView.view.showTitle
    }

    Behavior on opacity { id: highlightOpacity; animation:  NumberAnimation { duration: 200 } enabled: !thumbnail.GridView.showTitle}
    Behavior on scale { NumberAnimation { duration: 200 }}


    MouseArea {
        id: mouse
        anchors.fill: parent
        onClicked: delayedClick.start()
    }

    Timer {
        id: delayedClick
        interval: 200
        onTriggered: parent.clicked()
    }

    /*
    states: State {
        name: "peakState"
        when: mouse.released
        PropertyChanges {
            target: thumbnail
            opacity: 0.3
        }
    }

    transitions: Transition { PropertyAnimation { properties: "opacity"; duration: 250 }}
    */
}
