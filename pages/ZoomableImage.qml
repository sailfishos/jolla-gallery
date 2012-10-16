import QtQuick 1.1



Flickable {
    id: flickable

    property bool itemScaled: photo.scale > 1
    property bool alignTop: parent.alignTop
    property alias source: photo.source

    flickableDirection: Flickable.HorizontalAndVerticalFlick
    contentWidth: parent.width
    contentHeight: parent.height
    clip: itemScaled
    boundsBehavior: Flickable.StopAtBounds
    onItemScaledChanged: parent.itemScaled = itemScaled


    function scaleToMax(centerX, centerY)
    {
        if ( photo.scale <= 1){
            photo.scale = 4.0
            flickable.resizeContent(photo.width * photo.scale, photo.height * photo.scale, Qt.point(centerX, centerY))
            flickable.returnToBounds()
        } else {
            photo.scale = 0.98
            flickable.resizeContent(photo.width * photo.scale, photo.height * photo.scale, Qt.point(width/2, height/2))
        }


    }
    /*
    Rectangle{
        color: "green"
        width: Math.max(photo.width * photo.scale, flickable.width)
        height:Math.max(photo.height * photo.scale, flickable.height)
        transformOrigin: Item.TopLeft
    */
        Image {
            id: photo
            smooth: !(flickable.movingVertically || flickable.movingHorizontally)
            sourceSize.width: flickable.width*2
            width: flickable.width
            fillMode: Image.PreserveAspectFit
            transformOrigin: Item.TopLeft
            asynchronous: true
            //y: Math.max(0, (parent.height - height) / 2)

        }
    //}

     PinchArea {
         id: pinchArea
         enabled: !flickable.alignTop
         anchors.fill: parent
         pinch.target: photo
         pinch.minimumScale: 0.98
         pinch.maximumScale: 4.5
         property real prevCenterX: -1
         property real prevCenterY: -1

         onPinchStarted: {
             prevCenterX = pinch.startCenter.x
             prevCenterY = pinch.startCenter.y
         }

         onPinchUpdated: {
             flickable.contentX += prevCenterX - pinch.center.x
             flickable.contentY += prevCenterY - pinch.center.y

             console.log("PrevX " + prevCenterX + ", new " + pinch.center.x + " prev cente x " + pinch.previousCenter.x + " start x " + pinch.startCenter.x)
             // resize content

             var scale = 1.0 + pinch.scale - pinch.lastScale

             flickable.resizeContent(flickable.contentWidth * scale, flickable.contentHeight * scale, pinch.center)
             //flickable.resizeContent(photo.width * photo.scale, photo.height*photo.scale, pinch.center)
             prevCenterX = pinch.center.x
             prevCenterY = pinch.center.y
         }

         onPinchFinished: flickable.returnToBounds()
     }



     states: State {
         when: alignTop
         PropertyChanges {
             target: photo
             y: Math.max(0, (parent.height/2 - height) / 2)
         }
     }

     transitions: Transition {
            AnchorAnimation { duration: 300; easing.type: Easing.OutCubic }
            PropertyAnimation { property: "anchors.topMargin"; duration: 250; easing.type: Easing.OutCubic }
     }

}
