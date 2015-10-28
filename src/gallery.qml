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
    property alias ambienceModel: ambienceModel
    property var activeObject: ({url: "", mimeType: ""})
    property url previousAmbienceUrl
    property url ambienceUrl

    allowedOrientations: defaultAllowedOrientations
    _defaultLabelFormat: Text.PlainText

    function createAmbience(url)
    {
        previousAmbienceUrl = (Ambience.source != url) ? Ambience.source : ""
        if (!window.showAmbienceDialog(url)) {
            // Save the url for checking later if there is a new ambience created.
            window.ambienceUrl = url
        }
        Ambience.source = url
    }

    function showAmbienceDialog(ambienceUrl)
    {
        var ok = false
        for (var i = ambienceModel.count - 1; i >= 0; --i) {
              var data = ambienceModel.get(i)
              if (data.url == ambienceUrl) {
                  ok = true
                  break
              }
        }

        if (ok) {
            // We have a new ambience created. Show the settings dialog
            pageStack.push( ambienceSettings, { "ambienceModel": window.ambienceModel, "source":  ambienceUrl })
        }

        return ok
    }

    Component {
        id: ambienceSettings
        AmbienceSettingsPage {
            onAmbienceRemoved: {
                // User removed the newly created ambience.
                // Restore the previous ambience if it's still valid.
                if (previousAmbienceUrl != "") {
                    for (var i = ambienceModel.count - 1; i >= 0; --i) {
                          var data = ambienceModel.get(i)
                          if (data.url == previousAmbienceUrl) {
                              Ambience.source = previousAmbienceUrl
                              break
                          }
                    }
                }
            }
            Component.onDestruction: {
                previousAmbienceUrl = ""
            }
        }
    }


    DocumentGalleryModel {
        id: photosModel

        rootType: DocumentGallery.Image
        properties: ["url", "mimeType", "title", "orientation", "lastModified", "width", "height" ]
        sortProperties: ["-lastModified"]
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

    AmbienceModel {
        id: ambienceModel

        filter: AmbienceModel.NoFilter
        onRowsInserted: {
            if (ambienceUrl != "" && window.showAmbienceDialog(window.ambienceUrl)) {
                window.ambienceUrl = ""
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

