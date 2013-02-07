import QtQuick 1.1
import Sailfish.Silica 1.0
import com.jolla.gallery 1.0
import QtMobility.gallery 1.1


Page {

    Component {
        id: delegate
        BackgroundItem {
            id: delegateItem
            width: view.width
            height: thumbnail.height

            Label {
                id: countLabel
                objectName: "countLabel"
                anchors {
                    right: thumbnail.left
                    rightMargin: 20
                    verticalCenter: parent.verticalCenter
                }
                text: media.count
                font.pixelSize: theme.fontSizeLarge
            }

            // Load icon from a plugin
            Loader {
                id: thumbnail
                x: width - 20
                width: 120
                height: width
                source: media.icon
                opacity: delegateItem.down ? 0.5 : 1
            }

            Label {
                id: titleLabel
                objectName: "titleLabel"
                elide: Text.ElideRight
                font.pixelSize: theme.fontSizeLarge
                text: media.title
                anchors {
                    left: thumbnail.right
                    right: parent.right
                    leftMargin: 20
                    verticalCenter: parent.verticalCenter
                }
            }

            onClicked: { window.pageStack.push(Qt.resolvedUrl("GalleryGridPage.qml"), {title: media.title, model: media.model} ) }
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
                icon: "PhotoIcon.qml"
                type: DocumentGallery.Image
                properties: ["url", "mimeType", "title", "dateTaken"]
                sortProperties: ["-dateTaken"]
            }

            DocumentGallerySource {
                //% "Videos"
                title: qsTrId("gallery-bt-videos")
                icon: "PhotoIcon.qml"
                type: DocumentGallery.Video
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
                icon: "PhotoIcon.qml"
                ready: true
            }
        }
    }
}
