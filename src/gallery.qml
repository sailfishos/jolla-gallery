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

    property alias photosModel: photosModel
    property alias videosModel: videosModel
    property var activeObject: ({url: "", mimeType: ""})

    allowedOrientations: defaultAllowedOrientations
    _defaultLabelFormat: Text.PlainText

    function createAmbience(url)
    {
        var previousAmbienceUrl = Ambience.source
        Ambience.setAmbience(url, function(ambienceId) {
            pageStack.push(ambienceSettings, {
                'contentId': ambienceId,
                'previousAmbienceUrl': previousAmbienceUrl
            })
        })
    }

    Component {
        id: ambienceSettings
        AmbienceSettingsPage {
            property alias previousAmbienceUrl: previousAmbience.url

            allowRemove: previousAmbience.contentId !== 0

            // Monitor the previous ambience, if it has been removed don't allow the
            // current one to be removed as well.
            AmbienceInfo {
                id: previousAmbience
            }

            onAmbienceRemoved: {
                Ambience.source = previousAmbienceUrl
            }
        }
    }

    DocumentGalleryModel {
        id: photosModel

        rootType: DocumentGallery.Image
        properties: ["url", "mimeType", "title", "orientation", "dateTaken", "width", "height" ]
        sortProperties: ["-dateTaken"]
        autoUpdate: true
        filter: GalleryStartsWithFilter { property: "filePath"; value: StandardPaths.music; negated: true }
    }

    DocumentGalleryModel {
        id: videosModel

        rootType: DocumentGallery.Video
        properties: ["url", "mimeType", "title", "lastModified", "orientation", "duration"]
        sortProperties: ["-lastModified"]
        autoUpdate: true
    }

    // For some reason if the gallery is launched via invoker, it sets codecForLocale to
    // be ISO8859-1 instead of UTF-8 which causes the loading failure of the images using
    // Chinese characters. This can be used as a workaround for a bug: JB#11179.
    // NOTE: Setting codec in main.cpp doesn't seem to have any effect at all
    TextCodec { codecForLocale: "UTF-8" }

    cover: Qt.resolvedUrl("pages/GalleryCover.qml")

    initialPage: Component { GalleryStartPage {} }
}

