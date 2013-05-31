import QtQuick 1.1
import Sailfish.Silica 1.0
import Sailfish.Silica.private 1.0
import com.jolla.gallery 1.0
import QtMobility.gallery 1.1

Page {
    id: startPage

    allowedOrientations: window.allowedOrientations

    function showMedia(media, transition) {
        var page = media.page != ""
                ? Qt.resolvedUrl(media.page)
                : Qt.resolvedUrl("GalleryGridPage.qml")
        window.pageStack.push(
                    page,
                    { title: media.title, model: media.model },
                    transition !== undefined ? transition : PageStackAction.Animated)
    }

    Component {
        id: delegate
        BackgroundItem {
            id: delegateItem
            width: view.width
            height: thumbnail.height
            enabled: media.count > 0
            opacity: enabled ? 1.0 : 0.5

            Label {
                id: countLabel
                objectName: "countLabel"
                anchors {
                    right: thumbnail.left
                    rightMargin: theme.paddingLarge
                    verticalCenter: parent.verticalCenter
                }
                opacity: 0.4
                text: media.count
                color: delegateItem.down ? theme.highlightColor : theme.primaryColor
                font.pixelSize: theme.fontSizeLarge
            }

            // Load icon from a plugin
            Loader {
                id: thumbnail
                x: theme.itemSizeExtraLarge
                width: theme.itemSizeExtraLarge
                height: width
                source: media.icon != "" ? media.icon : "PhotoIcon.qml"
                opacity: delegateItem.down ? 0.5 : 1
            }

            Label {
                id: titleLabel
                objectName: "titleLabel"
                elide: Text.ElideRight
                font.pixelSize: theme.fontSizeLarge
                text: media.title
                color: delegateItem.down ? theme.highlightColor : theme.primaryColor
                anchors {
                    left: thumbnail.right
                    right: parent.right
                    leftMargin: theme.paddingLarge
                    verticalCenter: parent.verticalCenter
                }
            }

            onClicked: showMedia(media)
        }
    }

    SilicaListView {
        id: view
        objectName: "albumsView"

        anchors.fill: parent
        delegate: delegate
        model: MediaSourceModel {
            id: mediaSourceModel
            DocumentGallerySource {
                id: photoSource
                //: Main screen
                //% "Photos"
                title: qsTrId("gallery-bt-photos")
                type: DocumentGallery.Image
                properties: ["url", "mimeType", "title", "dateTaken"]
                sortProperties: ["-dateTaken"]
                filter: GalleryStartsWithFilter { property: "filePath"; value: "/home/nemo/Pictures/" }
            }

            DocumentGallerySource {
                id: videoSource
                //% "Videos"
                title: qsTrId("gallery-bt-videos")
                type: DocumentGallery.Video
                filter: GalleryStartsWithFilter { property: "filePath"; value: "/home/nemo/Videos/" }
            }

            albumDelegate: MediaSource {
                model: DocumentGalleryModel {
                    id: albumModel
                    properties: [ "url", "mimeType", "title", "dateTaken" ]
                    sortProperties: ["-dateTaken"]
                    autoUpdate: true
                    rootType: DocumentGallery.Image
                    rootItem: albumId
                }
                title: albumTitle
                count: albumModel.count
                ready: true
            }
        }
    }

    DBusAdaptor {
        service: "com.jolla.gallery"
        path: "/com/jolla/gallery/ui"
        iface: "com.jolla.gallery.ui"

        signal showPhotos
        signal showVideos

        onShowPhotos: {
            window.pageStack.pop(startPage, PageStackAction.Immediate)
            showMedia(photoSource, PageStackAction.Immediate)
            activate()
        }

        onShowVideos: {
            window.pageStack.pop(startPage, PageStackAction.Immediate)
            showMedia(videoSource, PageStackAction.Immediate)
            activate()
        }
    }
}
