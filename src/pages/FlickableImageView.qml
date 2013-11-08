import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Media 1.0
import Sailfish.Gallery 1.0
import QtMultimedia 5.0

SlideshowView {
    id: view

    property bool itemScaled: currentItem !== null && currentItem.itemScaled
    property bool isPortrait
    property bool menuOpen
    property Item _activeItem
    property bool _applicationActive: window.applicationActive

    signal clicked

    function currentItemUrl() {
        return model.get(currentIndex).url
    }

    interactive: !itemScaled && count > 1
    flickDeceleration: 300


    Component.onCompleted: {
        if (!view._activeItem && currentItem) {
            view._activeItem = currentItem
            view._activeItem.active = true
        }
    }

    onCurrentItemChanged: {
        if (!moving && currentItem) {
            if (view._activeItem) {
                view._activeItem.active = false
            }

            view._activeItem = currentItem
            view._activeItem.active = true
        }
    }

    onMovingChanged: {
        if (!moving && view._activeItem != currentItem) {
            if (view._activeItem) {
                view._activeItem.active = false
            }
            mediaPlayer.stop()
            mediaPlayer.source = ""
            view._activeItem = currentItem
            if (view._activeItem) {
                view._activeItem.active = true
            }
        }
    }

    on_ApplicationActiveChanged: {
        if (!_applicationActive && mediaPlayer.playbackState == MediaPlayer.PlayingState) {
            mediaPlayer.pause()
        }
    }

    delegate: Item {
        id: mediaItem

        property QtObject modelData: model
        property bool isImage: model.mimeType.indexOf("image/") == 0
        property bool active
        readonly property bool itemScaled: loader.item.scaled != undefined && loader.item.scaled

        // Delegate width needs to set right from the beginning or otherwise
        // the size is initially 0 and then scaled to the right size, but this
        // causes that most of the delegates will be created in the beginning
        // causing a huge memory consumption and maybe a crash.
        width: view.isPortrait ? Screen.width : Screen.height
        height: view.height

        visible: view.moving || active

        opacity: Math.abs(x) <= view.width ? 1.0 -  (Math.abs(x) / view.width) : 0

        Component {
            id: imageComponent

            ImageViewer {
                source: model.url
                menuOpen: view.menuOpen
                fit: view.isPortrait ? Fit.Width : Fit.Height
                orientation: model.orientation
                enableZoom: !view.moving

                active: mediaItem.active
                maximumWidth: model.width
                maximumHeight: model.height

                onClicked: view.clicked()
            }
        }

        Component {
            id: videoComponent

            VideoPoster {
                property bool scaled

                player: mediaPlayer

                source: model.url
                mimeType: model.mimeType
                active: mediaItem.active
                duration: model.duration

                onClicked: {
                   if (mediaPlayer.playbackState == MediaPlayer.PlayingState) {
                       mediaPlayer.pause()
                   } else {
                       view.clicked()
                   }
               }
            }
        }

        Loader {
            id: loader

            width: mediaItem.width
            height: mediaItem.height

            sourceComponent: mediaItem.isImage ? imageComponent: videoComponent
        }
    }   

    children: [
        GStreamerVideoOutput {
            id: video

            source: MediaPlayer {
                id: mediaPlayer
            }

            visible: mediaPlayer.playbackState != MediaPlayer.StoppedState
            width: view.width
            height: view.height
            anchors.centerIn: view._activeItem

            ScreenBlank {
                suspend: mediaPlayer.playbackState == MediaPlayer.PlayingState
            }
        }
    ]

}
