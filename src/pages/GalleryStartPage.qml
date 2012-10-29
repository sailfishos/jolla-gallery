import QtQuick 1.1
import com.jolla.components 1.0
import com.jolla.gallery 1.0

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
                text: mediaCount
                font.pixelSize: theme.fontSizeLarge
            }

            // Load icon from a plugin
            Loader {
                id: thumbnail
                x: width
                width: parent.width / 4
                height: parent.width / 4
                source: mediaQmlSourceIconUrl
                opacity: delegateItem.down ? 0.5 : 1
            }

            Label {
                id: titleLabel
                anchors {
                    left: thumbnail.right
                    leftMargin: 20
                    verticalCenter: parent.verticalCenter
                }
                text: mediaTitle
                font.pixelSize: theme.fontSizeLarge
            }

            onClicked: { window.pageStack.push(Qt.resolvedUrl("GalleryGridPage.qml"), {title: mediaTitle, model: mediaModel} ) }
        }
    }


    JollaListView {
        anchors.fill: parent
        delegate: delegate
        model: MediaSourceModel { id: mediaSourceModel}

        ListView.onAdd: console.log("Adding an item")
    }
}
