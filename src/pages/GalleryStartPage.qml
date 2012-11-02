import QtQuick 1.1
import com.jolla.components 1.0
import com.jolla.gallery 1.0
import QtMobility.gallery 1.1


Page {

    Component {
        id: delegate
        BackgroundItem {
            id: delegateItem
            height: thumbnail.height

            Label {
                id: countLabel
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
                x: width
                width: 160
                height: 160
                source: media.icon
                opacity: delegateItem.down ? 0.5 : 1
            }

            Label {
                id: titleLabel
                width: parent.width
                elide: Text.ElideRight
                font.pixelSize: theme.fontSizeLarge
                text: media.title
                anchors {
                    left: thumbnail.right
                    leftMargin: 20
                    verticalCenter: parent.verticalCenter
                }
            }

            onClicked: { window.pageStack.push(Qt.resolvedUrl("GalleryGridPage.qml"), {title: media.title, model: media.model} ) }
        }
    }

    JollaListView {
        anchors.fill: parent
        delegate: delegate
        model: MediaSourceModel {
            id: mediaSourceModel
            DocumentGallerySource {
                title: "Photos"
                icon: "PhotoIcon.qml"
                type: DocumentGallery.Image
            }
        }

        ListView.onAdd: console.log("Adding an item")
    }
}
