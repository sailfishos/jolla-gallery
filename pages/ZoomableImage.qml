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

    Rectangle{
        color: "black"
        width: Math.max(photo.paintedWidth, flickable.width)
        height:Math.max(photo.paintedHeight, flickable.height)
        transformOrigin: Item.TopLeft
        onHeightChanged: console.log("Item container H: " + height)

        Image {
            id: photo
            smooth: !(flickable.movingVertically || flickable.movingHorizontally)
            sourceSize.width: flickable.width*2
            width: flickable.width

            fillMode: Image.PreserveAspectFit
            transformOrigin: Item.TopLeft
            asynchronous: true
            y: Math.max(0, (parent.height - height) / 2)

            onHeightChanged: console.log("Photo H: " + height + "Photo PH: " + paintedHeight)
        }
    }

     PinchArea {
         id: pinchArea
         //enabled: !flickable.alignTop
         anchors.fill: parent

         onPinchUpdated: {
             var scale = 1.0 + pinch.scale - pinch.previousScale

             var newPhotoWidth  = photo.width * scale
             var newPhotoHeight = photo.height * scale

             var newWidth  =  flickable.contentWidth * scale
             var newHeight =  flickable.contentHeight * scale

             // We need to compare painted size here in order to
             // decided if painted image is larger that the container
             // around it. We can't compare width/height or a sourceSize
             // because they are not related what's visible on a display
             if (photo.paintedHeight * scale < flickable.height)
                 newHeight = flickable.height
             else
                 newHeight = newPhotoHeight

             if (photo.paintedWidth * scale < flickable.width)
                 newWidth = flickable.width
             else
                 newWidth = newPhotoWidth

             // It's enough to check against width if we have reached min or max scale values
             if (newWidth <= flickable.width * 0.98 || flickable.width * 4.5 <= newWidth)
                 return

             // Finally set the new content size
             photo.width  = newWidth
             photo.height = newHeight
             flickable.resizeContent(newWidth, newHeight, pinch.center)
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
            PropertyAnimation { property: "y"; duration: 250; easing.type: Easing.OutCubic }
     }

}
