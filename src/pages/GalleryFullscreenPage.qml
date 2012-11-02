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

        anchors { top: parent.top; left: parent.left }
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
                onClicked:{console.log("Changed wallpaper"); wallpaper.source = imageList.currentItemUrl()}
            }
            visibleChildren: PageHeader {  title: "Share" }
         }

        delegate: BackgroundItem {
            width: menuList.width
            Label {
                x: 26
                text: name
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    // Element for handling the actual flicking and image buffering
    FlickableImageView {
        id: imageList
        anchors { bottom: parent.bottom; right: parent.right }
        onClicked: alignMiddle = !alignMiddle
    }

    states: [
        State {
            name: "portrait"
            when: window.isPortrait && !imageList.alignMiddle
            AnchorChanges {
                target: menuList
                anchors { bottom: parent.verticalCenter; right: parent.right }
            }
            AnchorChanges {
                target: imageList
                anchors { top: parent.top; left:parent.left }
            }
        }, State {
            name: "portrait-menu"
            extend: "portrait"
            when: window.isPortrait && imageList.alignMiddle
            AnchorChanges {
                target: imageList
                anchors.top: parent.verticalCenter
            }
            PropertyChanges { target: imageList; clip: true }
        }, State {
            name: "landscape"
            when: !window.isPortrait && !imageList.alignMiddle
            AnchorChanges {
                target: menuList
                anchors { bottom: parent.bottom; right: parent.horizontalCenter }
            }
            AnchorChanges {
                target: imageList
                anchors { top: parent.top; left:parent.left }
            }
        }, State {
            name: "landscape-menu"
            extend: "landscape"
            when: !window.isPortrait && imageList.alignMiddle
            AnchorChanges {
                target: imageList
                anchors.left: parent.horizontalCenter
            }
            PropertyChanges { target: imageList; clip: true }
        }
    ]

    transitions: [
        Transition {
            from: "portrait"; to: "portrait-menu"; reversible: true
            SequentialAnimation {
                PropertyAction { target: imageList; property: "clip" }
                AnchorAnimation { duration: 300; easing.type: Easing.OutCubic }
            }
        }, Transition {
            from: "landscape"; to: "landscape-menu"; reversible: true
            SequentialAnimation {
                PropertyAction { target: imageList; property: "clip" }
                AnchorAnimation { duration: 300; easing.type: Easing.OutCubic }
            }
        }
    ]
}
