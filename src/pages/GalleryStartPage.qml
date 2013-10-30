import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Silica.theme 1.0
import Sailfish.Silica.private 1.0
import com.jolla.gallery 1.0
import QtDocGallery 5.0

Page {
    id: startPage

    property Page imageViewerPage: null

    function showMedia(media, transition, index) {
        var mediaType = null
        if (media.type !== undefined) {
            if (media.type === DocumentGallery.Image) {
                mediaType = "photos"
            } else
            if (media.type === DocumentGallery.Video) {
                mediaType = "videos"
            }
        }

        window.pageStack.push(
                    Qt.resolvedUrl(media.page),
                    { title: media.title,
                      model: media.model,
                      userData: mediaType
                    },
                    transition !== undefined ? transition : PageStackAction.Animated)
    }

    function showImage(urls)
    {
        var createPage = true
        if (imageViewerPage && pageStack.currentPage === imageViewerPage) {
            createPage = false
        } else {
            viewerModel.clear()
        }

        for (var i=0; i < urls.length; ++i) {
            var file = urls[i]
            var fileType =  file.substr(file.lastIndexOf(".") + 1, file.length - 1)
            if (fileType === "jpg") {
                fileType = "jpeg"
            }

            viewerModel.set(viewerModel.count, {url: file, mimeType: "image/"+fileType, title: "" })
        }

        if (createPage) {
            imageViewerPage = window.pageStack.push(
                            Qt.resolvedUrl("GalleryFullscreenPage.qml"),
                            { title: "Photo viewer",
                              model: viewerModel,
                              currentIndex: viewerModel.count - urls.length,
                              imageViewerMode: true
                            },
                            PageStackAction.Immediate)
        } else {
            imageViewerPage.currentIndex = viewerModel.count - 1
        }
    }

    ListModel { id: viewerModel }

    Component {
        id: delegate
        BackgroundItem {
            id: delegateItem
            width: view.width
            height: thumbnail.height
            enabled: media.count > 0
            opacity: enabled ? 1.0 : 0.5

            Label {
                id: countLabel
                objectName: "countLabel"
                anchors {
                    right: thumbnail.left
                    rightMargin: Theme.paddingLarge
                    verticalCenter: parent.verticalCenter
                }
                opacity: 0.4
                text: media.count
                color: delegateItem.down ? Theme.highlightColor : Theme.primaryColor
                font.pixelSize: Theme.fontSizeLarge
            }

            // Load icon from a plugin
            Loader {
                id: thumbnail
                x: Theme.itemSizeExtraLarge
                width: Theme.itemSizeExtraLarge
                height: width
                source: media.icon
                opacity: delegateItem.down ? 0.5 : 1
                onStatusChanged: {
                    if (status == Loader.Ready) {
                        item.model = media.model
                    }
                }
            }

            Label {
                id: titleLabel
                objectName: "titleLabel"
                elide: Text.ElideRight
                font.pixelSize: Theme.fontSizeLarge
                text: media.title
                color: delegateItem.down ? Theme.highlightColor : Theme.primaryColor
                anchors {
                    left: thumbnail.right
                    right: parent.right
                    leftMargin: Theme.paddingLarge
                    verticalCenter: parent.verticalCenter
                }
            }

            onClicked: showMedia(media)
        }
    }

    SilicaListView {
        id: view
        objectName: "albumsView"
        anchors.fill: parent
        delegate: delegate
        model: MediaSourceModel {
            id: mediaSourceModel
            DocumentGallerySource {
                id: photoSource
                //: Main screen
                //% "Photos"
                title: qsTrId("gallery-bt-photos")
                type: DocumentGallery.Image
                properties: ["url", "mimeType", "title", "orientation", "lastModified" ]
                sortProperties: ["-lastModified"]
                icon: "PhotoIcon.qml"
                page: "GalleryGridPage.qml"
            }

            DocumentGallerySource {
                id: videoSource
                //% "Videos"
                title: qsTrId("gallery-bt-videos")
                type: DocumentGallery.Video
                properties: ["url", "mimeType", "title", "dateTaken", "orientation", "duration"]
                sortProperties: ["-dateTaken"]
                icon: "VideoIcon.qml"
                page: "GalleryGridPage.qml"
            }

        }
    }

    GalleryService {

        onOpenImages:{
            if (urls.length > 0) {
                showImage(urls)
            }
            activate()
        }

        onShowAllPhotos: {
            window.pageStack.pop(startPage, PageStackAction.Immediate)
            showMedia(photoSource, PageStackAction.Immediate)
            activate()
        }

        onShowAllVideos: {
            window.pageStack.pop(startPage, PageStackAction.Immediate)
            showMedia(videoSource, PageStackAction.Immediate)
            activate()
        }
    }

}
