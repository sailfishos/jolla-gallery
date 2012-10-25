import QtQuick 1.1
import "scripts/ItemContainer.js" as ItemContainer

Item{
    id: flickListView    
    signal clicked

    property QtObject leftMostItem
    property QtObject rightMostItem
    property int currentIndex
    property variant model
    property int moveDirection // -1 left, 0 nothing, 1 right
    property int bufferSize: 2
    property int flickAnimationDuration: 150
    property bool alignMiddle
    property bool itemScaled


    // Make this element to slide in the middle
    y: alignMiddle ? parent.height / 2 : 0
    Behavior on y { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }

    // Create fullscreen images
    Component.onCompleted: createFSImageItems()

    // Create Fullscreen image items based on buffer size
    function createFSImageItems()
    {
        // First create "empty" images to make sure that they are ordered properly
        // This creates 1 + 2*bufferSize number of images
        for (var i=0; i < 1+2*bufferSize; i++){
            var component = Qt.createComponent("MediaItemContainer.qml");
            if (component.status === Component.Ready) {
                var mediaItemContainer = component.createObject(flickListView);

                if (mediaItemContainer === null){
                    console.log("Failed to create FS Image")
                    return;
                }

                mediaItemContainer.width  = flickListView.width
                mediaItemContainer.height = flickListView.height

                ItemContainer.addItem(mediaItemContainer)

                // Make the first item to go left most
                if (i == 0){
                    mediaItemContainer.x = (i - bufferSize) * width
                    leftMostItem = mediaItemContainer
                }

                // Anchor items so that all the items are achored to
                // the left item execpte the first one
                if (i > 0) {
                    var obj = ItemContainer.itemAt(i-1)
                    mediaItemContainer.anchors.left = obj.right
                }
            }
        }

        // Next make images to load their sources starting from the current index
        // to make sure it's loaded first
        for (var i=0; i < 1+2*bufferSize; i++){

            // modelItemIndex is an index to get items from a model
            var modelItemIndex = currentIndex + i
            if (modelItemIndex > currentIndex + bufferSize)
                modelItemIndex = currentIndex - ((currentIndex + i) % (currentIndex + bufferSize))

            // bufferItemIndex is index for an item in a ItemContainer (buffer)
            var bufferItemIndex = i + bufferSize
            if (bufferItemIndex >= 1+2*bufferSize)
                bufferItemIndex = (i + bufferSize) % bufferSize

            var modelItem = model.get(modelIndex(modelItemIndex))

            var mediaItemContainer = ItemContainer.itemAt(bufferItemIndex)
            mediaItemContainer.source = modelItem.url
            mediaItemContainer.mimeType = modelItem.mimeType
            mediaItemContainer.loadMediaContent()
        }
    }

    function moveToLeft()
    {
        // Right to left flick
        if (flickAnimation.running)
            return

        moveDirection = -1
        flickAnimation.target = ItemContainer.itemAt(0)
        flickAnimation.to = (flickListView.width * -bufferSize)-flickListView.width

        currentIndex = modelIndex(currentIndex + 1)
        flickAnimation.start()
    }

    function moveToRight()
    {
        // Left to right flick
        if (flickAnimation.running)
            return

        moveDirection = 1
        flickAnimation.target = ItemContainer.itemAt(0)
        flickAnimation.to = -flickListView.width

        currentIndex = modelIndex(currentIndex - 1)
        flickAnimation.start()
    }

    function moveBackToBeginning()
    {
        if (flickAnimation.running)
            return

        moveDirection = 0
        flickAnimation.target = ItemContainer.itemAt(0)
        flickAnimation.to = (flickListView.width * -bufferSize)

        flickAnimation.start()
    }

    function swapRight()
    {
        ItemContainer.rotateEnd()

        var leftMost = ItemContainer.first()
        leftMost.anchors.left = undefined
        leftMostItem = leftMost
        leftMostItem.x = flickListView.width*-bufferSize
        leftMostItem.anchors.left = undefined

        var secondLeftMost = ItemContainer.itemAt(1)
        secondLeftMost.anchors.left = leftMostItem.right

        // Make it load new content
        var modelItem = model.get(modelIndex((0 - bufferSize) + currentIndex))
        leftMostItem.source   = modelItem.url
        leftMostItem.mimeType = modelItem.mimeType
        leftMostItem.loadMediaContent()
    }

    function swapLeft()
    {

        ItemContainer.rotateBeginning()

        // First make sure to update the first item anchors
        leftMostItem = ItemContainer.first()
        leftMostItem.anchors.left = undefined

        rightMostItem = ItemContainer.last()
        var secondRightMost = ItemContainer.itemAt(2*bufferSize-1)

        secondRightMost.anchors.right = undefined
        rightMostItem.anchors.left = secondRightMost.right
        rightMostItem.x = flickListView*bufferSize
        rightMostItem.anchors.right = undefined

        // Make it load new content
        var modelItem = model.get(modelIndex(bufferSize + currentIndex))
        rightMostItem.source   = modelItem.url
        rightMostItem.mimeType = modelItem.mimeType
        rightMostItem.loadMediaContent()
    }

    function modelIndex(index)
    {
        if (index < 0)
            return (index+model.count) % model.count
        else
            return (index%model.count)
    }

    function currentItemUrl()
    {
        return model.get(currentIndex).url
    }

    PropertyAnimation{
        id: flickAnimation
        property: "x"
        duration: flickAnimationDuration
        alwaysRunToEnd: true
        easing.type: Easing.OutQuad
        onCompleted: {
            if (moveDirection < 0)
                swapLeft()
            if (moveDirection > 0)
                swapRight()
        }
    }

    // NOTE: onDoubleClicked didn't work here. It worked randomly on N950.
    MouseArea {
        id: mouseArea
        property real firstPressX
        property real pressX
        property real pressY
        property real tapThresshold: 15
        z: 10
        anchors.fill: parent
        enabled: !itemScaled


        Timer {
            id: clickTimer
            interval: 200
            onTriggered: if ( !flickListView.itemScaled ) flickListView.clicked()
        }

        onPressed: {
            firstPressX = mouseX
            pressX = mouseX
            pressY = mouseY
        }

        onPositionChanged: {

            if (parent.itemScaled){
                return
            }

            leftMostItem.x = leftMostItem.x - (pressX - mouseX)
            pressX = mouseX
        }

        onReleased: {         
            if ( Math.abs(firstPressX-mouseX) < tapThresshold){
                if (clickTimer.running && !flickListView.alignMiddle){
                    clickTimer.stop()
                    ItemContainer.itemAt(bufferSize).scaleToMax(pressX, pressY)
                } else {
                     clickTimer.restart()
                }
                return
            }

            if ( flickListView.itemScaled)
                return

            // If user has moved too little, return back to beginning
            var delta = Math.abs(firstPressX-mouseX)
            if ( 0 < delta && delta < (parent.width / 4)){
                moveBackToBeginning()
                return
            }

            // Move to the next or previous item
            if ( firstPressX > mouseX )
                moveToLeft()
            else
                moveToRight()

        }
    }
}
