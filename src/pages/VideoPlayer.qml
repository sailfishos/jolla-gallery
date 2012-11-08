import QtQuick 1.1
import com.jolla.components 1.0
import QtMultimediaKit 1.1
import org.nemomobile.thumbnailer 1.0

Item {
    id: player
    property alias source: poster.source
    property alias mimeType: poster.mimeType
    property bool alignTop

    property real windowWidth: window.isPortrait
            ? Math.min(window.width, window.height)
            : Math.max(window.width, window.height)
    property real windowHeight: window.isPortrait
            ? Math.max(window.width, window.height)
            : Math.min(window.width, window.height)

    property real minimumDimension: Math.min(window.width, window.height)
    property real maximumDimension: Math.max(window.width, window.height)

    property real scale: alignTop
            ? minimumDimension / Math.max(implicitWidth, implicitHeight)
            : window.isPortrait
                    ? minimumDimension / implicitWidth
                    : minimumDimension / implicitHeight

    implicitWidth: poster.implicitWidth !== 0 // Once the video is loaded it should override this.
            ? poster.implicitWidth
            : windowWidth
    implicitHeight: poster.implicitHeight !== 0
            ? poster.implicitHeight
            : windowHeight

    Behavior on scale {
        id: scaleBehavior
        enabled: poster.status == Thumbnail.Ready
        NumberAnimation {  duration: 200; alwaysRunToEnd: true }
    }

    Thumbnail {
        id: poster

        x: Math.max(0, (parent.width - width) / 2)
        y: Math.max(0, (parent.height - height) / 2)

        anchors.centerIn: parent

        width: implicitWidth * player.scale
        height: implicitHeight * player.scale

        sourceSize.width: maximumDimension
        sourceSize.height: maximumDimension

        priority: Thumbnail.HighPriority
        fillMode: Thumbnail.PreserveAspectFit
    }
}
