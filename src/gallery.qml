import QtQuick 2.0
import Sailfish.Silica 1.0
import com.jolla.gallery 1.0
import com.jolla.gallery.ambience 1.0
import QtDocGallery 5.0
import Sailfish.Ambience 1.0
import "pages"
import "pages/scripts/AlbumManager.js" as AlbumManager

ApplicationWindow {
    id: window

    property var photosModel: photosModelComponent.createObject(window)
    property var videosModel: videosModelComponent.createObject(window)
    property var ambienceModel: ambienceModelComponent.createObject(window)
    property var activeObject: ({url: "", mimeType: ""})
    property int ambienceCount

    allowedOrientations: Orientation.Portrait | Orientation.Landscape

    function createAmbience(url)
    {
        // Save current ambience count for checking later if there is a new
        // ambience created.
        ambienceCount = ambienceModel.count
        Ambience.source = url
    }

    function showAmbienceDialog()
    {
        if (ambienceModel.count > ambienceCount) {
            ambienceCount = 0
            // We have a new ambience created. Show the settings dialog
            pageStack.push( ambienceSettings, { "ambienceModel": window.ambienceModel, "source":  Ambience.source })
        }
    }

    Component {
        id: ambienceSettings
        AmbienceSettingsPage {}
    }

    Component {
        id: photosModelComponent
        DocumentGalleryModel {
            rootType: DocumentGallery.Image
            properties: ["url", "mimeType", "title", "orientation", "lastModified", "width", "height" ]
            sortProperties: ["-lastModified"]
            autoUpdate: true
            filter: GalleryStartsWithFilter { property: "filePath"; value: StandardPaths.music; negated: true }
        }
    }

    Component {
        id: videosModelComponent
        DocumentGalleryModel {
            rootType: DocumentGallery.Video
            properties: ["url", "mimeType", "title", "lastModified", "orientation", "duration"]
            sortProperties: ["-lastModified"]
            autoUpdate: true
        }
    }

    Component {
        id: ambienceModelComponent
        AmbienceModel {
            filter: AmbienceModel.NoFilter
            onCountChanged: {
                if (ambienceCount > 0)
                    window.showAmbienceDialog()
            }
        }
    }

    // For some reason if the gallery is launched via invoker, it sets codecForLocale to
    // be ISO8859-1 instead of UTF-8 which causes the loading failure of the images using
    // Chinese characters. This can be used as a workaround for a bug: JB#11179.
    // NOTE: Setting codec in main.cpp doesn't seem to have any effect at all
    TextCodec { codecForLocale: "UTF-8" }

    cover: Qt.resolvedUrl("pages/GalleryCover.qml")

    initialPage: Component { GalleryStartPage {} }
}

