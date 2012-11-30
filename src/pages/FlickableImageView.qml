import QtQuick 1.1
import com.jolla.components 1.0

SlideshowView {
    id: view

    property Item currentItem
    property bool alignMiddle
    property bool itemScaled: currentItem !== null && currentItem.itemScaled
    property bool enableZoom: currentItem !== null && currentItem.x === 0

    function currentItemUrl() {
        return model.get(currentIndex).url
    }

    anchors.fill: parent
    interactive: !itemScaled && count > 1
    flickDeceleration: 300

    // workaround lack of PathView.positionViewAtIndex() in QtQuick1
    highlightMoveDuration: 1
    Component.onCompleted: highlightMoveDuration = 300

    delegate: MediaItemContainer {
        id: container

        property url mediaUrl: model.url

        anchors { top: view.top; bottom: view.bottom }
        width: view.width
        alignTop: view.alignMiddle
        enableZoom: view.enableZoom
        isCurrentItem: container == currentItem
        // Adjust opacity based on item position
        opacity: Math.abs(x) <= view.width ? 1.0 -  (Math.abs(x) / view.width) : 0

        onClicked: view.toggleMenuMode()

        onMediaUrlChanged: {
            loadMediaContent(model.url, model.mimeType)
        }

        Component.onCompleted: {
            // workaround for lack of PathView.currentItem in QtQuick1
            if (container.PathView.isCurrentItem) {
                view.currentItem = container
            }
        }
        // workaround for lack of PathView.currentItem in QtQuick1
        PathView.onIsCurrentItemChanged: {
            if (container.PathView.isCurrentItem) {
                view.currentItem = container
            }
        }
    }
}
