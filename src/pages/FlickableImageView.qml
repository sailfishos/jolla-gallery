import QtQuick 2.0
import Sailfish.Silica 1.0

SlideshowView {
    id: view

    property bool itemScaled: currentItem !== null && currentItem.itemScaled
    property bool enableZoom: currentItem !== null && currentItem.x === 0
    property bool isPortrait
    property bool menuOpen

    signal clicked

    function currentItemUrl() {
        return model.get(currentIndex).url
    }

    anchors.fill: parent
    interactive: !itemScaled && count > 1
    flickDeceleration: 300

    delegate: MediaItemContainer {
        id: container

        property url mediaUrl: model.url
        property string mediaMimeType: model.mimeType

        anchors { top: view.top; bottom: view.bottom }
        width: view.width
        menuOpen: view.menuOpen
        enableZoom: view.enableZoom
        isCurrentItem: container == currentItem
        isPortrait: view.isPortrait
        // Adjust opacity based on item position
        opacity: Math.abs(x) <= view.width ? 1.0 -  (Math.abs(x) / view.width) : 0

        onClicked: view.clicked()

        onMediaUrlChanged: loadMediaContent(model.url, model.mimeType)
        onMediaMimeTypeChanged: loadMediaContent(model.url, model.mimeType)       
    }   
}
