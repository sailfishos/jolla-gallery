import QtQuick 1.1
import Sailfish.Silica 1.0

SilicaFlickable {
    id: flickable

    property bool itemScaled: false
    property bool menuOpen
    property bool enableZoom: parent.enableZoom
    property alias source: photo.source
    property real minimumDimension: Math.min(window.width, window.height)
    property real maximumDimension: Math.max(window.width, window.height)
    property bool isPortrait

    signal clicked

    flickableDirection: Flickable.HorizontalAndVerticalFlick

    contentWidth: itemScaled ? Math.max(width, photo.width) : width
    contentHeight: itemScaled ? Math.max(height, photo.height) : height

    onMenuOpenChanged: setSplitMode()

    interactive: itemScaled

    function setSplitMode()
    {
        if (menuOpen) {
            scaleBehavior.enabled = true
            photo.updateScale()
        } else {
            photo.updateScale()
            scaleBehavior.enabled = false
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

        if (isPortrait) {
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

        // If photo height is greater than view height, do Y centering only after that
        // otherwise it shoots to the skies.
        if (photo.height > height) {
            contentY += (center.y * newHeight / oldHeight) - center.y
        }

        itemScaled = true
    }

    children: ScrollDecorator {}
    PinchArea {
        id: pinchArea
        enabled: !flickable.menuOpen && flickable.enableZoom && photo.status == Image.Ready
        anchors.fill: parent
        onPinchUpdated: scaleImage(1.0 + pinch.scale - pinch.previousScale, pinch.center)
        onPinchFinished: flickable.returnToBounds()

        Image {
            id: photo

            property real fittedScale
            property real scale
            property bool isPortrait: flickable.isPortrait
            property bool isImagePortrait: photo.implicitWidth < photo.implicitHeight
            property bool reloadTried

            function updateScale() {
                if (status != Image.Ready)
                    return

                if (menuOpen) {
                    fittedScale = minimumDimension / (isImagePortrait ? photo.implicitWidth : photo.implicitHeight)
                } else {
                    fittedScale = isPortrait
                            ? minimumDimension / photo.implicitWidth
                            : minimumDimension / photo.implicitHeight
                }

                if (!itemScaled || scale < fittedScale) {
                    scale = fittedScale
                    contentX = 0
                    contentY = 0
                    itemScaled = false
                }
            }

            // This Behavior is used only when user has aligned image i.e. we are on a split screen mode
            Behavior on scale { id: scaleBehavior; NumberAnimation {  duration: 300; alwaysRunToEnd: true } }

            smooth: !(flickable.movingVertically || flickable.movingHorizontally)
            width: implicitWidth * scale
            height: implicitHeight * scale
            sourceSize.width: minimumDimension * 1.5
            fillMode:  Image.PreserveAspectFit
            asynchronous: true
            anchors.centerIn: parent

            onStatusChanged: {
                updateScale()

                if (reloadTried === false && status === Image.Error) {
                    reloadTried = true
                    source = fileInfo.fromPercentEncoding(source)
                }

            }
            onIsPortraitChanged: updateScale()
            onSourceChanged: {
                scaleBehavior.enabled = false
                fittedScale = 0
                itemScaled = false
            }
        }

        MouseArea {
            anchors.fill: parent
            enabled: !flickable.itemScaled

            onClicked: {
                flickable.clicked()
            }
        }
    }
}
