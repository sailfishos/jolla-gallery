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
    property string type: mimeType
    sourceSize.width: width
    sourceSize.height: height
    asynchronous: true

    scale: mouse.pressed & mouse.containsMouse ? 0.95 : 1

    function secondRowItem()
    {
        return index <= 5 && 3 <= index
    }

    function initThumbnail()
    {
        // The second row should be invisible first and
        // after a few seconds it will be animated to
        // a full opacity
        if (secondRowItem()){
            opacity = 0
            opacityBehavior.enabled = true
        }

        if ( mimeType.substring(0,5) === "video" ){
            var rect = Qt.createQmlObject('import QtQuick 1.1; Rectangle { }', thumbnail, "thumbnail")
            rect.width = width
            rect.height= height
            rect.color = "black"
            rect.border.color = "white"
        } else {
            source = "image://nemoThumbnail/" + url
        }
    }

    // Do earlier init
    onTypeChanged: initThumbnail()

    // We can't start opacity the animation before everything is set up
    Component.onCompleted: if (secondRowItem()) opacity = 1

    Behavior on opacity { id: opacityBehavior; animation:  NumberAnimation { duration: 2500 } enabled: false}
    Behavior on scale { NumberAnimation { duration: 150 }}

    MouseArea {
        id: mouse
        anchors.fill: parent
        onClicked: parent.clicked()        
    }

}
