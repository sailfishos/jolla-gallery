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
    property bool showMenu: false


    ListModel {
        id: actionsModel
        ListElement {
            name: "Email"
            title: "Share"
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
        width: parent.width
        height: parent.height / 2 // This is a workaround for keeping PullDownMenu up
        model: actionsModel

        header:PullDownMenu {

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
                onClicked: {

                }
            }

            MenuItem {
                text: "Show all"
                onClicked: {
                    pageStack.pop();
                    console.log("all images")
                }
            }
         }

        delegate: BackgroundItem {
            width: menuList.width

            Label {
                text: name                
                anchors { left: parent.left; verticalCenter: parent.verticalCenter }
            }

            Label {
                text: title === undefined ? "" : title
                color: theme.highlightColor
                anchors { right: parent.right; verticalCenter: parent.verticalCenter }
            }

            onClicked: fullscreenPage.showMenu = !fullscreenPage.showMenu
        }
    }

    // TODO: Replace ListView with more nemo gallery like implementation. This is just a placeholder
    //       until we have a better implementation.
    JollaListView {
        id: imageList
        width: fullscreenPage.width
        height: fullscreenPage.height
        orientation: ListView.Horizontal
        snapMode: ListView.SnapOneItem
        cacheBuffer: width*2
        y: fullscreenPage.showMenu ? fullscreenPage.height / 2 : 0
        Behavior on y { NumberAnimation { duration: 200 } }


        // TODO: No UI spec for a background yet. Just keep the image aspect ratio,
        //       center it and display a black background.
        // TODO: This implementation will be replaced in the next commit
        delegate: Rectangle {
            property bool isVideoItem: mimeType.substring(0,5) === "video"
            width: ListView.view.width
            height: ListView.view.height
            color: "black"

            Image {
                id: image
                source: isVideoItem ? "" : url
                width: parent.width
                sourceSize.height: imageList.height
                asynchronous: true
                fillMode: Image.PreserveAspectFit
                y: fullscreenPage.showMenu ? (Math.max(0, (parent.height/2 - height) / 2)) : ((parent.height - height) / 2)

                Behavior on y {
                    animation: NumberAnimation { duration: 150 }
                    enabled: image.progress == 1
                }
            }

            Label {
                text: "video"
                anchors.centerIn: image
                visible: isVideoItem
            }

            MouseArea {
                anchors.fill: parent
                onClicked:  fullscreenPage.showMenu = !fullscreenPage.showMenu
            }
        }
    }
}
