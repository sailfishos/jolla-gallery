import QtQuick 2.2
import Sailfish.Silica 1.0
import org.nemomobile.thumbnailer 1.0

Item {
    id: photo
    property alias source: thumbnail.source
    property alias mimeType: thumbnail.mimeType

    property real borderWidth: Theme.paddingMedium

    property real offsetX
    property real offsetY
    property real photoScale: 1.0
    property alias priority: thumbnail.priority
    property real photoSize: Math.min(width, height-borderWidth)

    Item {
        anchors {
            centerIn: parent
            horizontalCenterOffset: offsetX
            verticalCenterOffset: offsetY
        }

        // 1.414 is the ratio of a square diagonal::side
        width: photoSize * 1.414
        height: (photoSize + borderWidth) * 1.414
        scale: photoScale

        layer.enabled: parent.opacity != 1.0
        layer.smooth: true

        Thumbnail {
            id: thumbnail
            anchors {
                centerIn: parent
                verticalCenterOffset: -borderWidth/2
            }
            width: photoSize - borderWidth
            height: photoSize - borderWidth
            sourceSize.width: width * 1.5
            sourceSize.height: height * 1.5
            fillMode: Image.PreserveAspectCrop
        }
        Image {
            source: "image://theme/graphic-gallery-frame"
            anchors.centerIn: parent
            width: photoSize
            height: photoSize + borderWidth
            sourceSize.width: photo.width*1.5
            smooth: true
        }
    }
}
