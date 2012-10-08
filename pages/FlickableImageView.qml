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

    // Make all the image elements to align correctly if this Element
    // is align ed in the middle
    onAlignMiddleChanged: ItemContainer.alignTop(alignMiddle)

    // Make this element to slide in the middle
    y: alignMiddle ? parent.height / 2 : 0
    Behavior on y { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

    // Create fullscreen images
    Component.onCompleted: createFSImageItems()

    // Create Fullscreen image items based on buffer size
    function createFSImageItems()
    {
        // First create "empty" images to make sure that they are ordered properly
        // This creates 1 + 2*bufferSize number of images
        for (var i=0; i < 1+2*bufferSize; i++){
            var component = Qt.createComponent("FullScreenImage.qml");
            if (component.status === Component.Ready) {
                var fsImage = component.createObject(flickListView);

                if (fsImage === null){
                    console.log("Failed to create FS Image")
                    return;
                }

                fsImage.width     = flickListView.width
                fsImage.height    = flickListView.height

                ItemContainer.addItem(fsImage)

                // Make the first item to go left most
                if (i == 0){
                    fsImage.x = (i - bufferSize) * width
                    leftMostItem = fsImage
                }

                // Anchor items so that all the items are achored to
                // the left item execpte the first one
                if (i > 0) {
                    var obj = ItemContainer.itemAt(i-1)
                    fsImage.anchors.left = obj.right
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

            var image = ItemContainer.itemAt(bufferItemIndex)
            image.source = modelItem.url
            image.mimeType = modelItem.mimeType
        }
    }

    function moveToLeft()
    {
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
        if (flickAnimation.running)
            return

        moveDirection = 1
        flickAnimation.target = ItemContainer.itemAt(0)
        flickAnimation.to = -flickListView.width

        currentIndex = modelIndex(currentIndex - 1)
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
        leftMostItem.source = modelItem.url
        leftMostItem.mimeType  = modelItem.mimeType
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
    }

    function modelIndex(index)
    {
        if (index < 0)
            return (index+model.count) % model.count
        else
            return (index%model.count)
    }

    PropertyAnimation{
        id: flickAnimation
        property: "x"
        duration: flickAnimationDuration
        alwaysRunToEnd: true
        onCompleted: {
            if (moveDirection < 0)
                swapLeft()
            if (moveDirection > 0)
                swapRight()
        }
    }

    MouseArea {
        anchors.fill: parent
        property real firstPressX
        property real pressX
        property real tapThresshold: 15

        onPressed: {
            firstPressX = mouseX
            pressX = mouseX
        }

        onPositionChanged: {
            leftMostItem.x = leftMostItem.x - (pressX - mouseX)
            pressX = mouseX
        }

        onReleased: {
            if ( Math.abs(firstPressX-mouseX) < tapThresshold){
                flickListView.clicked()
                return
            }

            if ( firstPressX > mouseX )
                moveToLeft()
            else
                moveToRight()
        }
    }
}
