import QtQuick 1.1



Flickable {
    id: flickable

    property bool itemScaled: photo.width > flickable.width
    property bool alignTop: parent.alignTop
    property bool enableZoom: parent.enableZoom
    property alias source: photo.source

    flickableDirection: Flickable.HorizontalAndVerticalFlick
    contentWidth: parent.width
    contentHeight: parent.height
    clip: itemScaled
    boundsBehavior: Flickable.StopAtBounds

    onItemScaledChanged: parent.itemScaled = itemScaled

    function scaleToMax(centerX, centerY)
    {
        if (!itemScaled){
            scaleImage(3.5, Qt.point(centerX, centerY))
            flickable.returnToBounds()
        }
    }

    function resetScale()
    {
        if (itemScaled){
            photo.width =  photo.initialWidth
            photo.height = photo.initialHeight
            flickable.contentX = 0
            flickable.contentY = 0
            flickable.contentWidth = flickable.width
            flickable.contentHeight= flickable.height
        }
    }

    function scaleImage(scale, center)
    {
        var newPhotoWidth  = photo.width * scale
        var newPhotoHeight = photo.height * scale

        // We need to compare painted size here in order to
        // decide if painted image is larger that the container
        // around it. We can't compare width/height or a sourceSize
        // because they are not related what's visible on a display
        var newWidth = photo.paintedWidth * scale < flickable.width ? flickable.width * 0.98 : newPhotoWidth
        var newHeight = photo.paintedHeight * scale < flickable.height ? flickable.height : newPhotoHeight

        // It's enough to check against width if we have reached min or max scale values
        if (newWidth <= flickable.width * 0.97 || flickable.width * 3.51 <= newWidth)
            return

        // Finally set the new content size
        photo.width  = newWidth
        photo.height = newHeight
        flickable.resizeContent(newWidth, newHeight, center)
    }

    PinchArea {
        id: pinchArea
        enabled: !flickable.alignTop && flickable.enableZoom
        anchors.fill: parent
        onPinchUpdated: scaleImage(1.0 + pinch.scale - pinch.previousScale, pinch.center)
        onPinchFinished: flickable.returnToBounds()

        // Rect is a container which is used to provide black bars if the image doesn't fill
        // the display area fully
        Rectangle {
            color: "black"
            width: Math.max(photo.paintedWidth, flickable.width)
            height: Math.max(photo.paintedHeight, flickable.height)
            transformOrigin: Item.TopLeft

            Image {
                id: photo
                property int initialWidth
                property int initialHeight
                smooth: !(flickable.movingVertically || flickable.movingHorizontally)
                sourceSize.width: flickable.width*1.5
                width: flickable.width * 0.98
                fillMode: Image.PreserveAspectFit
                transformOrigin: Item.TopLeft
                asynchronous: true
                y: Math.max(0, (flickable.height - height) / 2)
                x: Math.max(0, (flickable.width - width) / 2)
                onStatusChanged: {
                    if ( status == Image.Ready){
                        initialWidth = width
                        initialHeight = height
                    }
                }

                // We need to handle the second double tap because the top level mouse area
                // is disabled while interacting with this QML element.
                // NOTE: onDoubleClicked didn't work here. It worked randomly on N950.
                MouseArea {
                    anchors.fill: parent
                    Timer { id: clickTimer; interval: 200 }

                    onPressed: {
                        if (clickTimer.running)
                            resetScale()
                        else
                            clickTimer.start()
                    }
                }
            }
        }
    }


     states: State {
         when: alignTop
         PropertyChanges {
            target: photo
            y: Math.max(0, (flickable.height/2 - height) / 2)
         }
     }


    transitions: Transition { PropertyAnimation { property: "y"; duration: 250; easing.type: Easing.OutCubic } }



}
