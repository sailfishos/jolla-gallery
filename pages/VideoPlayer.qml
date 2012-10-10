import QtQuick 1.1
import com.jolla.components 1.0

// This is a placeholder for actual video item
Rectangle {
    // Url is something that each media item has to have
    property url source
    color: "black"

    Rectangle{
        color: "green"
        width: parent.width
        height: parent.width / (16/9.0)
        anchors.centerIn: parent

        Label{
            anchors.centerIn: parent
            text: "Video"
        }
    }
}
