import QtQuick 1.1
import com.jolla.components 1.0

/**
  * GalleryFullScreenPage is a QML Element for displaying Photos and Videos
  * fullscreen. User can flick photos and Videos by flicking them horizontally.
  *
  * NOTE: Current implementation will be replaced with a new one in the following
  *       commits.
  */
Page {
    id: fullscreenPage
    property alias model: imageList.model
    property alias currentIndex: imageList.currentIndex

    clip: imageList.alignMiddle
    backNavigation: imageList.alignMiddle

    ListModel {
        id: actionsModel
        ListElement {
            name: "Email"
        }

        ListElement {
            name: "SMS"
        }

        ListElement {
            name: "Facebook"
        }

        ListElement {
            name: "Picasa"
        }

        ListElement {
            name: "Evernote"
        }
    }

    JollaListView {
        id: menuList

        anchors {
            left: parent.left
            top: parent.top
            right: window.isPortrait ? parent.right : parent.horizontalCenter
            bottom: window.isPortrait ? parent.verticalCenter : parent.bottom
        }
        model: actionsModel

        PullDownMenu {
            bottomMargin: 0

            MenuItem {
                text: "Delete"
                onClicked: {
                    console.log("Delete clicked")
                }
            }
            MenuItem {
                text: "Edit"
                onClicked: {
                    console.log("Delete clicked")
                }
            }
            MenuItem {
                text: "Set as wallpaper"
                onClicked: wallpaper.source = imageList.currentItemUrl()
            }
        }

        header: PageHeader {
            title: model.get(currentIndex).title
        }

        delegate: BackgroundItem {
            width: menuList.width
            Label {
                x: 26
                text: name
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        Label {
            text: "Share"
            color: theme.highlightColor
            height: theme.standardItemHeight
            verticalAlignment: Text.AlignVCenter
            anchors {
                top: parent.top
                topMargin: 78 - menuList.contentY  // 78 is the height of the PageHeader
                right: parent.right
                rightMargin: 24
            }
        }
    }

    // Hide the menu items from the pulldown menu with this image.
    // Handle landscape & portrait changes also here.
    Item {
        anchors.fill: parent
        opacity: imageList.alignMiddle ? 0 : 1
        Behavior on opacity { NumberAnimation { duration: 300 } }

        Image {
            id: image

            fillMode: Image.PreserveAspectCrop
            width: window.isPortrait ? window.height : window.width
            height: window.isPortrait ? window.width : window.height
            source: theme.backgroundImage
            transform: Rotation {
                angle: !window.isPortrait ? -90 : 0
                origin {
                    x: !window.isPortrait ? window.height / 2 : 0
                    y: !window.isPortrait ? window.height / 2 : 0
                }
            }
        }

        Rectangle {
            anchors.fill: parent
            opacity: 0.65
            color: "black"
        }
    }

    // Element for handling the actual flicking and image buffering
    FlickableImageView {
        id: imageList

        property real menuProgress: alignMiddle ? 1.0 : 0.0
        Behavior on menuProgress {
            NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
        }

        anchors {
            fill: parent
            leftMargin: window.isPortrait ? 0 : menuProgress * parent.width / 2
            topMargin: window.isPortrait ? menuProgress * parent.height / 2 : 0
        }
        clip: menuProgress != 0.0
        onClicked: alignMiddle = !alignMiddle
    }
}
