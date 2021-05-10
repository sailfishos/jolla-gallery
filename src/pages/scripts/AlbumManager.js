// Emulate a module api from Qt5 using a singleton instance of a type.

.pragma library
.import QtQuick 2.1 as QtQuick

var _albumManagerComponent
var _albumManagerInstance

function albumManager() {
    if (_albumManagerComponent === undefined) {
        _albumManagerComponent = Qt.createComponent(Qt.resolvedUrl('../PhotoAlbumManager.qml'))
        if (_albumManagerComponent.status !== QtQuick.Component.Ready) {
            console.error("unable to create album manager component", _albumManagerComponent.errorString())
            return undefined
        }

        _albumManagerInstance = _albumManagerComponent.createObject(0)
    }
    return _albumManagerInstance
}

function deleteMedia(url) {
    var manager = albumManager()
    manager.deleteMedia(url)
}
