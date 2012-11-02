import QtQuick 1.1



Flickable {
    id: flickable

    property bool itemScaled: false
    property bool alignTop: false
    property alias source: photo.source
    property bool isPortrait: window.isPortrait

    flickableDirection: Flickable.HorizontalAndVerticalFlick
    contentWidth: width
    contentHeight: height
    boundsBehavior: Flickable.StopAtBounds

    onSourceChanged: resetScale()
    onIsPortraitChanged: resetScale()

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
            contentX = 0
            contentY = 0
            contentWidth = width
            contentHeight = height
            itemScaled = false
        }
    }

    function scaleImage(scale, center)
    {
        var newWidth
        var newHeight

        if (window.isPortrait) {
            // Scale and bounds check the width, and then apply the same scale to height.
            newWidth = contentWidth * scale
            if (newWidth <= flickable.width) {
                resetScale()
                return
            } else {
                newWidth = Math.min(newWidth, photo.sourceSize.width)
                newHeight = Math.max(photo.paintedHeight * newWidth / contentWidth, flickable.height)
            }
        } else {
            // Scale and bounds check the height, and then apply the same scale to width.
            newHeight = photo.paintedHeight * scale
            if (newHeight <= flickable.height) {
                resetScale()
                return
            } else {
                newHeight = Math.min(newHeight, photo.sourceSize.height)
                newWidth = Math.max(photo.paintedWidth * newHeight / contentHeight, flickable.width)
            }
        }

        itemScaled = true

        // Finally set the new content size
        flickable.resizeContent(newWidth, newHeight, center)
    }

    PinchArea {
        id: pinchArea
        enabled: !flickable.alignTop && photo.status == Image.Ready
        anchors.fill: parent
        onPinchUpdated: scaleImage(1.0 + pinch.scale - pinch.previousScale, pinch.center)
        onPinchFinished: flickable.returnToBounds()

        Image {
            id: photo
            smooth: !(flickable.movingVertically || flickable.movingHorizontally)
            sourceSize.width: window.isPortrait ? flickable.width*1.5 : undefined
            sourceSize.height: window.isPortrait ? undefined : flickable.height*1.5
            fillMode: Image.PreserveAspectFit
            asynchronous: true

            anchors {
                left: window.isPortrait ? parent.left : undefined
                horizontalCenter: parent.horizontalCenter
                top: window.isPortrait ? undefined : parent.top
                verticalCenter: parent.verticalCenter
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
