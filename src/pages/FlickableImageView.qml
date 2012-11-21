import QtQuick 1.1
import "scripts/ItemContainer.js" as ItemContainer

MouseArea {
    id: flickListView    
    signal clicked

    property alias currentItem: flickAnimation.target
    property int currentIndex
    property variant model
    property int moveDirection // -1 left, 0 nothing, 1 right
    property int bufferSize: 2
    property int flickAnimationDuration: 1100
    property bool alignMiddle
    property bool itemScaled: currentItem !== null && currentItem.itemScaled
    property bool enableZoom: currentItem.x === 0

    property real firstPressX
    property real pressX
    property real pressY
    property real tapThresshold: 5

    enabled: currentItem !== null && !currentItem.itemScaled
    preventStealing: true
    drag.filterChildren: true

    Component {
        id: mediaItemComponent

        MediaItemContainer {
            id: container

            anchors { top: flickListView.top; bottom: flickListView.bottom }
            width: flickListView.width
            alignTop: alignMiddle
            isCurrentItem: container == currentItem
            // Adjust opacity based on item position
            opacity: Math.abs(x) <= flickListView.width ? 1.0 -  (Math.abs(x) / flickListView.width) : 0
        }
    }

    // Create fullscreen images
    Component.onCompleted: createFSImageItems()

    // Create Fullscreen image items based on buffer size
    function createFSImageItems()
    {
        currentItem = mediaItemComponent.createObject(flickListView, { z: 1 })
        if (currentItem === null) {
            console.log("Failed to create FS Image")
            return
        }

        // Create the center item and load its content first.
        ItemContainer.addItem(currentItem)

        var modelItem = model.get(modelIndex(currentIndex))
        currentItem.loadMediaContent(modelItem.url, modelItem.mimeType)

        var previousLeftItem = currentItem
        var previousRightItem = currentItem

        // Create 2 * bufferSize items and load their content radiating
        // out from the center item.
        for (var i=1; i <= bufferSize; i++) {
            var leftItem = mediaItemComponent.createObject(flickListView);
            var rightItem = mediaItemComponent.createObject(flickListView);

            ItemContainer.prependItem(leftItem)
            ItemContainer.addItem(rightItem)

            // Anchor items so that all the items are anchored outwards
            // of the center item.
            leftItem.anchors.right =  previousLeftItem.left
            rightItem.anchors.left = previousRightItem.right

            modelItem = model.get(modelIndex(currentIndex - i))
            leftItem.loadMediaContent(modelItem.url, modelItem.mimeType)

            modelItem = model.get(modelIndex(currentIndex + i))
            rightItem.loadMediaContent(modelItem.url, modelItem.mimeType)

            previousLeftItem = leftItem
            previousRightItem = rightItem
        }        
    }

    function moveToLeft()
    {
        // Right to left flick
        if (flickAnimation.running)
            return

        var previousCurrentItem = currentItem
        currentItem = ItemContainer.itemAt(bufferSize + 1)

        currentItem.anchors.left = undefined
        currentItem.z = 1
        previousCurrentItem.anchors.right = currentItem.left
        previousCurrentItem.z = 0

        moveDirection = -1

        currentIndex = modelIndex(currentIndex + 1)
        flickAnimation.start()
    }

    function moveToRight()
    {
        // Left to right flick
        if (flickAnimation.running)
            return

        var previousCurrentItem = currentItem
        currentItem = ItemContainer.itemAt(bufferSize - 1)

        currentItem.anchors.right = undefined
        currentItem.z = 1
        previousCurrentItem.anchors.left = currentItem.right
        previousCurrentItem.z = 0

        moveDirection = 1

        currentIndex = modelIndex(currentIndex - 1)
        flickAnimation.start()
    }

    function moveBackToBeginning()
    {
        if (flickAnimation.running)
            return

        moveDirection = 0

        flickAnimation.start()
    }

    function swapRight()
    {
        var previousLeftMost = ItemContainer.first()
        ItemContainer.rotateEnd()

        // Un-anchor the now left most item from the right most item and anchor it
        // to the previously left most item.
        var leftMost = ItemContainer.first()
        leftMost.anchors.left = undefined
        leftMost.anchors.right = previousLeftMost.left

        // Make it load new content
        var modelItem = model.get(modelIndex((0 - bufferSize) + currentIndex))
        leftMost.loadMediaContent(modelItem.url, modelItem.mimeType)
    }

    function swapLeft()
    {
        var previousRightMost = ItemContainer.last()
        ItemContainer.rotateBeginning()

        // Un-anchor the now right most item from the left most item and anchor it
        // to the previously right most item.
        var rightMost = ItemContainer.last()
        rightMost.anchors.right = undefined
        rightMost.anchors.left = previousRightMost.right

        // Make it load new content
        var modelItem = model.get(modelIndex(bufferSize + currentIndex))
        rightMost.loadMediaContent(modelItem.url, modelItem.mimeType)
    }

    function modelIndex(index)
    {
        if (index < 0) {
            return (index + model.count) % model.count
        } else {
            return (index % model.count)
        }
    }

    function currentItemUrl()
    {
        return model.get(currentIndex).url
    }

    PropertyAnimation {
        id: flickAnimation
        property: "x"
        to: 0
        duration: flickAnimationDuration
        easing.type: Easing.OutExpo
        onCompleted: {
            if (moveDirection < 0)
                swapLeft()
            if (moveDirection > 0)
                swapRight()
        }
    }

    onPressed: {
        if (flickAnimation.running) {
            flickAnimation.stop()
        }

        firstPressX = mouseX
        pressX = mouseX
        pressY = mouseY
    }

    onPositionChanged: {
        if (currentItem.itemScaled) {
            return
        }

        currentItem.x = currentItem.x - (pressX - mouseX)
        pressX = mouseX
    }

    onReleased: {
        if (Math.abs(firstPressX-mouseX) < tapThresshold && !flickListView.itemScaled) {
            flickListView.clicked()
            return
        }

        if (flickListView.itemScaled)
            return

        // If user has moved too little, return back to beginning
        var delta = Math.abs(firstPressX-mouseX)
        if (0 < delta && delta < (parent.width / 4)) {
            moveBackToBeginning()
            return
        }

        // Move to the next or previous item
        if (firstPressX > mouseX) {
            moveToLeft()
        } else {
            moveToRight()
        }
    }
}
