import QtQuick 1.1



Flickable {
    id: flickable

    property bool itemScaled: false
    property bool alignTop
    property bool enableZoom: parent.enableZoom
    property alias source: photo.source
    property real minimumDimension: Math.min(window.width, window.height)
    property real maximumDimension: Math.max(window.width, window.height)

    flickableDirection: Flickable.HorizontalAndVerticalFlick
    boundsBehavior: Flickable.StopAtBounds

    contentWidth: Math.max(width, photo.width)
    contentHeight: Math.max(height, photo.height)

    function scaleToMax(centerX, centerY)
    {
        if (!itemScaled){
            scaleImage(3.5, Qt.point(centerX, centerY))
            flickable.returnToBounds()
        }
    }

    function resetScale()
    {
        if (itemScaled) {
            photo.scale = photo.fittedScale
            contentX = 0
            contentY = 0
            itemScaled = false
        }
    }

    function scaleImage(scale, center)
    {
        var newWidth
        var newHeight
        var oldWidth = contentWidth
        var oldHeight = contentHeight

        if (window.isPortrait) {
            // Scale and bounds check the width, and then apply the same scale to height.
            newWidth = contentWidth * scale
            if (newWidth <= minimumDimension) {
                resetScale()
                return
            } else {
                newWidth = Math.min(newWidth, minimumDimension * 3.5)
                photo.scale = newWidth / photo.implicitWidth
                newHeight = Math.max(photo.height, maximumDimension)
            }
        } else {
            // Scale and bounds check the height, and then apply the same scale to width.
            newHeight = contentHeight * scale
            if (newHeight <= minimumDimension) {
                resetScale()
                return
            } else {
                newHeight = Math.min(newHeight, minimumDimension * 3.5)
                photo.scale = newHeight / photo.implicitHeight
                newWidth = Math.max(photo.width, maximumDimension)
            }
        }
        // Fixup contentX and contentY
        contentX += (center.x * newWidth / oldWidth) - center.x
        contentY += (center.y * newHeight / oldHeight) - center.y

        itemScaled = true
    }

    PinchArea {
        id: pinchArea
        enabled: !flickable.alignTop && flickable.enableZoom && photo.status == Image.Ready
        anchors.fill: parent
        onPinchUpdated: scaleImage(1.0 + pinch.scale - pinch.previousScale, pinch.center)
        onPinchFinished: flickable.returnToBounds()

        Image {
            id: photo

            property real fittedScale
            property real scale
            property bool isPortrait: window.isPortrait

            function updateScale() {
                if (status != Image.Ready)
                    return
                fittedScale = window.isPortrait
                        ? minimumDimension / photo.implicitWidth
                        : minimumDimension / photo.implicitHeight
                if (!itemScaled || scale < fittedScale) {
                    scale = fittedScale
                    contentX = 0
                    contentY = 0
                    itemScaled = false
                }
            }

            smooth: !(flickable.movingVertically || flickable.movingHorizontally)
            width: implicitWidth * scale
            height: implicitHeight * scale
            sourceSize.width: minimumDimension * 1.5
            fillMode: Image.PreserveAspectFit
            asynchronous: true
            anchors.centerIn: parent

            onStatusChanged: updateScale()
            onIsPortraitChanged: updateScale()
            onSourceChanged: {
                fittedScale = 0
                itemScaled = false
                updateScale()
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
