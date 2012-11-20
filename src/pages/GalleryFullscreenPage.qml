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

        function title(index)
        {
            if (title["text"] === undefined) {
                title.text = [
                            "Facebook",
                            //% "Email"
                            qsTrId("gallery-bt-share_email"),
                            //% "MMS"
                            qsTrId("gallery-bt-share_mms"),
                            "Picasa",
                            "Evernote",
                            "Bluetooth"
                        ]
            }
            return title.text[index]
        }

        ListElement {
            // placeholder for Facebook
        }
        ListElement {
            // placeholder for Email
        }
        ListElement {
            // placeholder for MMS
        }
        ListElement {
            // placeholder for Picasa
        }
        ListElement {
            // placeholder for Evernote
        }
        ListElement {
            // placeholder for Bluetooth
        }
    }

    Connections {
        target: window
        // reset the page state if gallery is pushed to the background
        onApplicationActiveChanged: {
            if (!window.applicationActive && pageStack.currentPage === fullscreenPage) {
                menuProgressBehavior.enabled = false
                imageList.alignMiddle = false
                menuProgressBehavior.enabled = true
                pullDownMenu.hide()
            }
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
        clip: true
        model: actionsModel

        PullDownMenu {
            id: pullDownMenu

            bottomMargin: 0

            MenuItem {
                //% "Details"
                text: qsTrId("gallery-me-details")
                onClicked: window.pageStack.push(Qt.resolvedUrl("GalleryDetailsPage.qml"), {modelItem: model.get(currentIndex).itemId} )
            }
            MenuItem {
                //% "Delete"
                text: qsTrId("gallery-me-delete")
                onClicked: {
                    console.log("Delete clicked")
                }
            }
            MenuItem {
                //% "Edit"
                text: qsTrId("gallery-me-edit")
                onClicked: {
                    console.log("Delete clicked")
                }
            }
            MenuItem {
                //% "Create ambience"
                text: qsTrId("gallery-me-create_ambience")
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
                text: actionsModel.title(index)
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        Label {
            //% "Share"
            text: qsTrId("gallery-la-share")
            color: theme.highlightColor
            height: theme.standardItemHeight
            verticalAlignment: Text.AlignVCenter
            anchors {
                top: parent.top
                topMargin: theme.pageHeaderHeight - menuList.contentY
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
        property bool isPortrait: window.isPortrait
        property real menuProgress: alignMiddle ? 1.0 : 0

        onClicked: alignMiddle = !alignMiddle

        Behavior on menuProgress {
            id: menuProgressBehavior
            NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
        }

        anchors {
            fill: parent
            leftMargin: window.isPortrait ? 0 : menuProgress * parent.width / 2
            topMargin: window.isPortrait ? menuProgress * parent.height / 2 : 0
        }
    }
}
