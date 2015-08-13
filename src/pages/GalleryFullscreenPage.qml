import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Gallery 1.0
import Sailfish.TransferEngine 1.0
import Sailfish.Ambience 1.0
import com.jolla.gallery 1.0
import com.jolla.gallery.ambience 1.0
import com.jolla.settings.accounts 1.0
import com.jolla.signonuiservice 1.0
import "scripts/AlbumManager.js" as AlbumManager

/**
  * GalleryFullScreenPage is a QML Element for displaying Photos and Videos
  * fullscreen. User can flick photos and Videos by flicking them horizontally.
  */
SplitViewPage {
    id: fullscreenPage

    closeOnMinimize: false
    property alias model: imageList.model
    property alias currentIndex: imageList.currentIndex
    property alias autoPlay: imageList.autoPlay
    property bool imageViewerMode: false

    readonly property bool currentItemIsImage: model && model.get(fullscreenPage.currentIndex).mimeType.indexOf("image/") == 0
    readonly property bool currentItemIsJpeg: model && model.get(fullscreenPage.currentIndex).mimeType === "image/jpeg"

    signal deleteMedia(int index)
    signal requestIndex(int index)

    function remove(index) {
        //: Delete an image
        //% "Deleting"
        remorsePopup.execute( qsTrId("gallery-la-deleting"), function() {
            var files = []
            files.push(model.get(index).url)
            fileRemover.deleteFiles(files)
            pageStack.pop();
        })
    }

    open: true
    objectName: "fullscreenPage"
    allowedOrientations: Orientation.All

    FileRemover {
        id: fileRemover
    }

    // Update the Cover via window.activeObject property
    Binding {
        target: window
        property: "activeObject"
        value: fullscreenPage.status === PageStatus.Active
               ? { url: fileInfo.source, mimeType: fileInfo.mimeType }
               : { url: "", mimeType: ""}
    }

    onCurrentIndexChanged: {
        if (status !== PageStatus.Active) {
            return
        }
        requestIndex(currentIndex)
    }

    FileInfo {
        id: fileInfo
        source: model.get(currentIndex).url
    }

    // This is the share method list, but it also
    // includes the pulley menu
    background: ShareMethodList {
        id: menuList

        property string url: fullscreenPage.model.get(fullscreenPage.currentIndex).url
        filter: fileInfo.localFile ? fileInfo.mimeType : "text/x-url"
        objectName: "menuList"
        source: fileInfo.localFile ? url : ""
        anchors.fill: parent
        content: fileInfo.localFile ? undefined : {
                                                    "type": "text/x-url",
                                                    "status": url
                                                  }

        PullDownMenu {
            id: pullDownMenu

            visible: (fileInfo.localFile || fullscreenPage.currentItemIsImage) && !fullscreenPage.imageViewerMode

            MenuItem {
                id: detailsMenuItem
                Component {
                    id: detailsComponent
                    DetailsPage {}
                }

                //% "Details"
                text: qsTrId("gallery-me-details")
                visible: fileInfo.localFile && !fullscreenPage.imageViewerMode
                onClicked: window.pageStack.push(detailsComponent, {modelItem: model.get(currentIndex).itemId} )
            }

            MenuItem {
                id: deleteMenuItem
                //% "Delete"
                text: qsTrId("gallery-me-delete")
                visible: fileInfo.localFile
                onClicked: fullscreenPage.imageViewerMode
                        ? fullscreenPage.remove(fullscreenPage.currentIndex)
                        : deleteMedia(fullscreenPage.currentIndex)
            }

            MenuItem {
                id: editMenuItem
                //: Gallery image edit, will lead to a page where user can perform edit operations.
                //% "Edit"
                text: qsTrId("gallery-me-edit")
                visible:  fullscreenPage.currentItemIsImage && !fullscreenPage.imageViewerMode
                enabled: fullscreenPage.currentItemIsJpeg
                onClicked: pageStack.push("Sailfish.Gallery.ImageEditPage", { source: imageList.currentItemUrl() })
            }

            MenuItem {
                id: createAmbienceMenuItem
                //% "Create ambience"
                text: qsTrId("gallery-me-create_ambience")
                visible:  fullscreenPage.currentItemIsImage && !fullscreenPage.imageViewerMode
                onClicked: {
                    window.createAmbience(model.get(currentIndex).url)
                }
            }
        }

        header: PageHeader {
            title: fileInfo.localFile ? model.get(currentIndex).title : (imageList._videoActive ?
                                                                             qsTrId("gallery-la-share") : "")
            //% "Share"
            description: fileInfo.localFile ? qsTrId("gallery-la-share") : ""
            rightMargin: fullscreenPage.isPortrait ? Theme.horizontalPageMargin : Theme.paddingLarge
        }

        // Add "add account" to the footer. User must be able to
        // create accounts in a case there are none.
        footer: BackgroundItem {
            // Disable mousearea
            enabled: addAccountLabel.visible
            Label {
                id: addAccountLabel
                //% "Add account"
                text: qsTrId("gallery-la-add_account")
                x: Theme.horizontalPageMargin
                anchors.verticalCenter: parent.verticalCenter
                color: highlighted ? Theme.highlightColor : Theme.primaryColor
                visible: fileInfo.localFile
            }

            onClicked: {
                jolla_signon_ui_service.inProcessParent = fullscreenPage
                accountCreator.startAccountCreation()
            }
        }

        SignonUiService {
            id: jolla_signon_ui_service
            inProcessServiceName: "com.jolla.gallery"
            inProcessObjectPath: "/JollaGallerySignonUi"
        }

        AccountCreationManager {
            id: accountCreator
            serviceFilter: ["sharing","e-mail"]
            endDestination: fullscreenPage
            endDestinationAction: PageStackAction.Pop
        }
        SplitViewBackHint {}
    }


    // Element for handling the actual flicking and image buffering
    FlickableImageView {
        id: imageList

        // XXX Qt5 Port - workaround PathView bug
        pathItemCount: 3

        contentWidth: fullscreenPage.width
        contentHeight: fullscreenPage.height

        anchors.fill: parent

        objectName: "flickableView"
        isPortrait: fullscreenPage.isPortrait
        menuOpen: fullscreenPage.open

        onClicked: {
            fullscreenPage.open = !fullscreenPage.open
        }
    }

    RemorsePopup {
        id: remorsePopup
    }
}
