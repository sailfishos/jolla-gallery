import QtQuick 1.1
import com.jolla.components 1.0
import "scripts/AlbumManager.js" as AlbumManager

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
    property int currentIndex

    onCurrentIndexChanged: {
        if (status !== PageStatus.Active) {
            return
        }

        var grid = pageStack.previousPage()
        if (grid !== null) {
            grid.currentIndex = currentIndex
        }
    }

    objectName: "fullscreenPage"
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
                            //% "Multimedia message"
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

        objectName: "menuList"

        anchors {
            left: parent.left
            top: parent.top
            right: isPortrait ? parent.right : parent.horizontalCenter
            bottom: isPortrait ? parent.verticalCenter : parent.bottom
        }
        clip: true
        visible: imageList.menuProgress != 0
        model: actionsModel

        PullDownMenu {
            id: pullDownMenu
            MenuItem {
                //% "Details"
                text: qsTrId("gallery-me-details")
                onClicked: window.pageStack.push(Qt.resolvedUrl("GalleryDetailsPage.qml"), {modelItem: model.get(currentIndex).itemId} )
            }
            MenuItem {
                //% "Delete"
                text: qsTrId("gallery-me-delete")
                onClicked: {
                    pageStack.pop()
                    AlbumManager.deleteMedia(imageList.currentItemUrl())

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
                onClicked: {
                    wallpaper.source = imageList.currentItemUrl()
                    AlbumManager.addToAlbum("<urn:jolla-gallery:albums:wallpapers>", wallpaper.source)
                }
            }
        }

        // Workaround to clip title correctly.
        // TODO: When we have Jolla style to truncate
        //       too long lines, replace this code with it.
        header: Item {
            height: theme.pageHeaderHeight
            width: parent.width * 0.7
            x: parent.width * 0.3

            Text {
                text: model.get(currentIndex).title
                width: parent.width
                elide: Text.ElideRight
                color: theme.highlightColor
                anchors.verticalCenter: parent.verticalCenter
                objectName: "imageTitle"
                horizontalAlignment: Text.AlignRight
                font {
                    pixelSize: theme.fontSizeLarge
                    family: theme.fontFamilyHeading
                }

            }
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

    // Fade out the background image so it isn't visually conflicting
    Rectangle {
        anchors.fill: parent
        opacity: 0.65
        color: "black"
    }

    // Element for handling the actual flicking and image buffering
    FlickableImageView {
        id: imageList
        property real menuProgress: alignMiddle ? 1.0 : 0

        function toggleMenuMode() {
            alignMiddle = !alignMiddle
        }

        objectName: "flickableView"
        isPortrait: fullscreenPage.isPortrait

        // can't just alias fullscreenPage.currentIndex to this currentIndex due to PathView bug
        currentIndex: fullscreenPage.currentIndex
        onCurrentIndexChanged: fullscreenPage.currentIndex = currentIndex

        Behavior on menuProgress {
            id: menuProgressBehavior
            NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
        }

        anchors {
            fill: parent
            leftMargin: isPortrait ? 0 : menuProgress * parent.width / 2
            topMargin: isPortrait ? menuProgress * parent.height / 2 : 0
        }
    }
}
