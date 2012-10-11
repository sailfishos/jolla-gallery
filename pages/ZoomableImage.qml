import QtQuick 1.1


Flickable {
     id: flickable

     property bool imageScaled: photo.scale > 1
     property bool alignTop: parent.alignTop
     property alias source: photo.source

     contentWidth: imageContainer.width
     contentHeight: imageContainer.height
     onHeightChanged: photo.calculateSize()
     boundsBehavior: Flickable.DragOverBounds
     clip: imageScaled

     // Bind info about scaling to parent
     Binding {
         target: parent
         property: "itemScaled"
         value: imageScaled
     }

     Rectangle{
         id: imageContainer
         width: Math.max(photo.width * photo.scale, flickable.width)
         height:Math.max(photo.height * photo.scale, flickable.height)
         color: "black"

         Image {
             id: photo
             property real prevScale
             smooth: !(flickable.movingVertically || flickable.movingHorizontally)
             sourceSize.width: flickable.width
             fillMode: Image.PreserveAspectFit
             asynchronous: true
             anchors { horizontalCenter: parent.horizontalCenter; verticalCenter: parent.verticalCenter }
             onStatusChanged: if (status == Image.Ready) calculateSize()

             onScaleChanged: {
                 if (photo.progress < 1)
                     return

                 if ((width * scale) > flickable.width) {
                     var xoff = (flickable.width / 2 + flickable.contentX) * scale / prevScale
                     flickable.contentX = xoff - flickable.width / 2
                 }

                 if ((height * scale) > flickable.height) {
                     var yoff = (flickable.height / 2 + flickable.contentY) * scale / prevScale
                     flickable.contentY = yoff - flickable.height / 2
                 }

                 prevScale = scale;
             }

             function calculateSize()
             {
                 scale = Math.min(flickable.width / width, flickable.height / height)*0.98;
                 pinchArea.minScale = scale;
                 prevScale = Math.min(scale, 1);
             }
         }
     }

     PinchArea {
         id: pinchArea
         enabled: !flickable.alignTop
         property real minScale:  1.0
         anchors.fill: parent
         pinch.target: photo
         pinch.minimumScale: minScale
         pinch.maximumScale: 4.5
         onPinchFinished: flickable.returnToBounds()
     }

     states: State {
         when: alignTop
         AnchorChanges {
             target: photo
             anchors.horizontalCenter: undefined
             anchors.verticalCenter: undefined
             anchors.top: imageContainer.top
         }
         PropertyChanges {
             target: photo
             anchors.topMargin: Math.max(0, (parent.height/2 - height) / 2)
         }
     }

     transitions: Transition {
            AnchorAnimation { duration: 300; easing.type: Easing.OutCubic }
            PropertyAnimation { property: "anchors.topMargin"; duration: 250; easing.type: Easing.OutCubic }
     }
}
