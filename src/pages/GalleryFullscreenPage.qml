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
        width: parent.width
        height: parent.height / 2 // This is a workaround for keeping PullDownMenu up
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
        width: fullscreenPage.width
        height: fullscreenPage.height
        onClicked: alignMiddle = !alignMiddle
    }
}
