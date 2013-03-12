import QtQuick 1.1
import Sailfish.Silica 1.0
import com.jolla.gallery 1.0
import QtMobility.gallery 1.1

Page {

    allowedOrientations: window.allowedOrientations

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
                text: media.count
                color: delegateItem.down ? theme.highlightColor : theme.primaryColor
                font.pixelSize: theme.fontSizeLarge
            }

            // Load icon from a plugin
            Loader {
                id: thumbnail
                x: width - theme.paddingLarge
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

            onClicked: {
                    window.pageStack.push(media.page != "" ? Qt.resolvedUrl(media.page) : Qt.resolvedUrl("GalleryGridPage.qml") , {
                    title: media.title,
                    model: media.model,
                    thumbnailDelegate: media.thumbnail != "" ? media.thumbnail : Qt.resolvedUrl("GridImageThumbnail.qml")
            } ) }
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
                //: Main screen
                //% "Photos"
                title: qsTrId("gallery-bt-photos")
                type: DocumentGallery.Image
                properties: ["url", "mimeType", "title", "dateTaken"]
                sortProperties: ["-dateTaken"]
                filter: GalleryStartsWithFilter { property: "filePath"; value: "/home/nemo/Pictures/" }
            }

            DocumentGallerySource {
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
}
