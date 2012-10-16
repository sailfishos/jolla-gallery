import QtQuick 1.1



Flickable {
    id: flickable

    property bool itemScaled: photo.width > flickable.width
    property bool alignTop: parent.alignTop
    property alias source: photo.source

    flickableDirection: Flickable.HorizontalAndVerticalFlick
    contentWidth: 480//photo.width* photo.scale
    contentHeight: 854// photo.height * photo.scale
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
         //enabled: !flickable.alignTop
         anchors.fill: parent
         pinch.minimumScale: 0.98
         pinch.maximumScale: 4.5

         onPinchUpdated: {
             var scale = 1.0 + pinch.scale - pinch.previousScale

             var newWidth  =  flickable.contentWidth * scale
             var newHeight = flickable.contentHeight * scale

             // It's enough to check against width if we have reached min or max scale values
             if (newWidth <= flickable.width * 0.98 || flickable.width * 4.5 <= newWidth)
                 return

             photo.width  = newWidth
             photo.height = newHeight
             flickable.resizeContent(newWidth, newHeight, pinch.center)

             /*
               // WORKS
              flickable.resizeContent(photo.width * photo.scale,
                                      photo.height * photo.scale,
                                      pinch.center)
             */

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
