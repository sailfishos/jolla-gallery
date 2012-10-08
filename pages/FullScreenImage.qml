import QtQuick 1.1
import com.jolla.components 1.0

Rectangle {
    property alias source: image.source
    property string mimeType
    property bool alignTop
    property alias asynchronous: image.asynchronous
    color: "black"

    Image {
        id: image
        width: parent.width
        sourceSize.height: parent.height
        asynchronous: true
        fillMode: Image.PreserveAspectFit

        // If PullDownMenu is visible, the image needs to be centered to the area of size of half a screen
        y: alignTop ? (Math.max(0, (parent.height/2 - height) / 2)) : ((parent.height - height) / 2)

        // Disable this if image is still loading. May cause unwanted behavior
        Behavior on y {
            animation: NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
            enabled: image.progress == 1
        }

        // If this is current item make sure to make it again asynchronous. This is set false
        // in initial setup
        onStateChanged: if (!asynchronous && state === Image.Ready) asynchronous = true

    }

    Label {
        text: "video"
        anchors.centerIn: image
        visible: mimeType.substring(0,5) === "video"
    }

}
