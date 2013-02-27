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
    clip: menuList.visible
    backNavigation: menuList.active

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
            menuList.active = false
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
                menuList.active = false
                menuProgressBehavior.enabled = true
                pullDownMenu.hide()
            }
        }
    }


    FileInfo {
        id: fileInfo
        source: model.get(currentIndex).url
    }

    Wallpaper {
        id: wallpaper
        onSourceChanged: AlbumManager.addToAlbum("<urn:jolla-gallery:albums:wallpapers>", source)
    }

    SailfishTransferMethodsModel {
        id: transferMethodsModel
        filter: fileInfo.localFile ? fullscreenPage.model.get(fullscreenPage.currentIndex).mimeType : ""
    }

    // This is the share method list, but it also
    // includes the pulley menu
    ShareMethodList {
        id: menuList

        property bool active
        property real progress: active ? 1.0 : 0.0
        Behavior on progress {
            id: menuProgressBehavior
            NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
        }

        objectName: "menuList"
        model:  fileInfo.localFile ? transferMethodsModel : null
        anchors {
            left: parent.left
            top: parent.top
            right: isPortrait ? parent.right : parent.horizontalCenter
            bottom: isPortrait ? parent.verticalCenter : parent.bottom
        }
        clip: true
        visible: progress !== 0

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
                visible: fileInfo.localFile && imageList.currentItemIsImage
                onClicked: {
                    console.log("Delete clicked")
                }
            }
            MenuItem {
                //% "Create ambience"
                text: qsTrId("gallery-me-create_ambience")

                onClicked: wallpaper.source = imageList.currentItemUrl()
                visible:  imageList.currentItemIsImage
            }
        }

        header: Item {
            height: theme.itemSizeLarge
            width: menuList.width * 0.7 - theme.paddingLarge
            x: menuList.width * 0.3

            Label {
                text: fileInfo.localFile ? model.get(currentIndex).title : ""
                width: parent.width
                truncationMode: TruncationMode.Fade
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
                                     shareUIPath: shareUIPath,
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
        opacity: menuList.active ? 0 : 0.65
        color: "black"
        Behavior on opacity { NumberAnimation { duration: 300 }}
    }

    // Element for handling the actual flicking and image buffering
    FlickableImageView {
        id: imageList

        menu: menuList

        function toggleMenuMode() {
            menuList.active = !menuList.active
        }

        property bool currentItemIsImage: currentItem && currentItem.imageItem

        objectName: "flickableView"
        isPortrait: fullscreenPage.isPortrait

        // can't just alias fullscreenPage.currentIndex to this currentIndex due to PathView bug
        currentIndex: fullscreenPage.currentIndex
        onCurrentIndexChanged: fullscreenPage.currentIndex = currentIndex

        anchors {
            fill: parent
            leftMargin: isPortrait ? 0 : menuList.progress * parent.width / 2
            topMargin: isPortrait ? menuList.progress * parent.height / 2 : 0
        }
    }
}
