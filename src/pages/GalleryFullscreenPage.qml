import QtQuick 1.1
import Sailfish.Silica 1.0
import Sailfish.TransferEngine 1.0
import com.jolla.components.accounts 1.0
import com.jolla.gallery 1.0
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

    signal deleteMedia(int index)

    objectName: "fullscreenPage"
    clip: imageList.alignMiddle
    backNavigation: imageList.alignMiddle

    onCurrentIndexChanged: {
        if (status !== PageStatus.Active) {
            return
        }

        var grid = pageStack.previousPage()
        if (grid !== null) {
            grid.currentIndex = currentIndex
        }
    }

    onStatusChanged: {
        if (status === PageStatus.Inactive) {
            menuProgressBehavior.enabled = false
            imageList.alignMiddle = false
            menuProgressBehavior.enabled = true
            pullDownMenu.hide()
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


    FileInfo {
        id: fileInfo
        source: model.get(currentIndex).url
    }

    SailfishTransferMethodsModel {id: transferMethodsModel }

    // This is the share method list, but it also
    // includes the pulley menu
    ShareMethodList {
        id: menuList

        objectName: "menuList"
        model:  fileInfo.localFile ? transferMethodsModel : null

        anchors {
            left: parent.left
            top: parent.top
            right: isPortrait ? parent.right : parent.horizontalCenter
            bottom: isPortrait ? parent.verticalCenter : parent.bottom
        }
        clip: true
        visible: imageList.menuProgress != 0
        //% "Share"
        listHeader: fileInfo.localFile ? qsTrId("gallery-la-share") : ""

        PullDownMenu {
            id: pullDownMenu
            MenuItem {
                //% "Details"
                text: qsTrId("gallery-me-details")
                visible: fileInfo.localFile
                onClicked: window.pageStack.push(Qt.resolvedUrl("GalleryDetailsPage.qml"), {modelItem: model.get(currentIndex).itemId} )
            }
            MenuItem {
                //% "Delete"
                text: qsTrId("gallery-me-delete")
                visible: fileInfo.localFile
                onClicked: fullscreenPage.deleteMedia(fullscreenPage.currentIndex)
            }
            MenuItem {
                //% "Edit"
                text: qsTrId("gallery-me-edit")
                visible: fileInfo.localFile
                onClicked: {
                    console.log("Delete clicked")
                }
            }
            MenuItem {
                //% "Create ambience"
                text: qsTrId("gallery-me-create_ambience")

                onClicked: wallpaper.source = imageList.currentItemUrl()

                Connections {
                    target: wallpaper
                    onSourceChanged: AlbumManager.addToAlbum("<urn:jolla-gallery:albums:wallpapers>", wallpaper.source)
                }
            }
        }

        // Workaround to clip title correctly.
        // TODO: When we have Jolla style to truncate
        //       too long lines, replace this code with it.
        header: Item {
            height: theme.itemSizeLarge
            width: menuList.width * 0.7 - theme.paddingLarge
            x: menuList.width * 0.3


            Text {
                text: fileInfo.localFile ? model.get(currentIndex).title : ""
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

        // Add "add account" to the footer. User must be able to
        // create accounts in a case there are none.
        footer: BackgroundItem {
            Label {
                //% "Add account"
                text: qsTrId("gallery-la-add_account")
                x: theme.paddingLarge
                anchors.verticalCenter: parent.verticalCenter
                color: parent.down ? theme.highlightColor : theme.primaryColor
                visible: fileInfo.localFile
            }

            onClicked: pageStack.push(accountsPage)
        }

        Component {
            id: accountsPage
            AccountsPage {
                // If we don't do this, pageStack goes grazy. Bug 4751
                Component.onCompleted: pageStack.busyChanged.disconnect(maybePushMaybePop)
            }
        }

        onShareMethodClicked: {
            var item  = fullscreenPage.model.get(fullscreenPage.currentIndex)
            pageStack.openDialog(shareDialog, {
                                     displayName: displayName,
                                     accountName: userName,
                                     methodId: methodId,
                                     accountId: accountId,
                                     accountRequired: accountRequired,
                                     source: item.url,
                                     mimeType: item.mimeType,
                                     docItemId: item.itemId
                                 })
        }
    }

    Component {
        id: shareDialog
        ShareDialog { }
    }

    // Fade out the background image so it isn't visually conflicting
    Rectangle {
        anchors.fill: parent
        opacity: imageList.alignMiddle ? 0 : 0.65
        color: "black"
        Behavior on opacity { NumberAnimation { duration: 300 }}
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
