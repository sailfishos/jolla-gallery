import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Gallery 1.0
import Sailfish.TransferEngine 1.0
import Sailfish.Ambience 1.0
import com.jolla.gallery 1.0
import com.jolla.settings.accounts 1.0
import "scripts/AlbumManager.js" as AlbumManager

/**
  * GalleryFullScreenPage is a QML Element for displaying Photos and Videos
  * fullscreen. User can flick photos and Videos by flicking them horizontally.
  *
  * NOTE: Current implementation will be replaced with a new one in the following
  *       commits.
  */
SplitViewPage {
    id: fullscreenPage

    property alias model: imageList.model
    property alias currentIndex: imageList.currentIndex

    signal deleteMedia(int index)

    objectName: "fullscreenPage"
    allowedOrientations: window.allowedOrientations

    onCurrentIndexChanged: {
        if (status !== PageStatus.Active) {
            return
        }

        var grid = pageStack.previousPage()
        if (grid !== null) {
            grid.currentIndex = currentIndex
        }
    }

    FileInfo {
        id: fileInfo
        source: model.get(currentIndex).url
    }

    SailfishTransferMethodsModel {
        id: transferMethodsModel
        filter: fileInfo.localFile ? fullscreenPage.model.get(fullscreenPage.currentIndex).mimeType : ""
    }

    // This is the share method list, but it also
    // includes the pulley menu
    background: ShareMethodList {
        id: menuList


        objectName: "menuList"
        model:  fileInfo.localFile ? transferMethodsModel : null
        source: fullscreenPage.model.get(fullscreenPage.currentIndex).url
        anchors.fill: parent

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
                //: Gallery image edit, will lead to a page where user can perform edit operations.
                //% "Edit"
                text: qsTrId("gallery-me-edit")

                onClicked: pageStack.push(imageEditPage, {source: imageList.currentItemUrl(), orientation: model.get(currentIndex).orientation})
                visible:  imageList.currentItemIsImage
            }

            MenuItem {
                //% "Create ambience"
                text: qsTrId("gallery-me-create_ambience")

                onClicked: Ambience.source = model.get(currentIndex).url
                visible:  imageList.currentItemIsImage
            }
        }

        header: Item {
            height: Theme.itemSizeLarge
            width: menuList.width * 0.7 - Theme.paddingLarge
            x: menuList.width * 0.3

            Label {
                text: fileInfo.localFile ? model.get(currentIndex).title : ""
                width: parent.width
                truncationMode: TruncationMode.Fade
                color: Theme.highlightColor
                anchors.verticalCenter: parent.verticalCenter
                objectName: "imageTitle"
                horizontalAlignment: Text.AlignRight
                font {
                    pixelSize: Theme.fontSizeLarge
                    family: Theme.fontFamilyHeading
                }
            }
        }

        // Add "add account" to the footer. User must be able to
        // create accounts in a case there are none.
        footer: BackgroundItem {
            Label {
                //% "Add account"
                text: qsTrId("gallery-la-add_account")
                x: Theme.paddingLarge
                anchors.verticalCenter: parent.verticalCenter
                color: highlighted ? Theme.highlightColor : Theme.primaryColor
                visible: fileInfo.localFile
            }

            onClicked: {
                if (typeof jolla_signon_ui_service !== "undefined") {
                    jolla_signon_ui_service.inProcessParent = fullscreenPage
                }
                pageStack.push(accountsPage)
            }
        }

        Component {
            id: accountsPage
            AccountsPage { }
        }
    }


    // Element for handling the actual flicking and image buffering
    FlickableImageView {
        id: imageList

        // XXX Qt5 Port - workaround PathView bug
        pathItemCount: 3

        property bool currentItemIsImage: true
        objectName: "flickableView"
        isPortrait: fullscreenPage.isPortrait
        menuOpen: fullscreenPage.opened

        onClicked: {
            // For some reason, PathView::currentItem == null, when currentIndex == 0. Binding it
            // to any property doesn't seem to work until the currentIndex changes. Therefore
            // currentItemIsImage is assigned here.
            if (currentItem) {
                currentItemIsImage = currentItem.isImage
            }

            fullscreenPage.open = !fullscreenPage.open
        }
    }

    Component {
        id: imageEditPage

        ImageEditPage {
            allowedOrientations: window.allowedOrientations
            splitOpen: true
        }
    }
}
