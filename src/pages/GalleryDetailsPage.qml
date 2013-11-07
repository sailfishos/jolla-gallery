import QtQuick 2.0
import Sailfish.Silica 1.0
import QtDocGallery 5.0

Page {
    id: detailsPage
    property alias modelItem: galleryItem.item

    DocumentGalleryItem {
        id: galleryItem
        autoUpdate: false
        properties: [ 'fileName', 'fileSize', 'mimeType', 'width', 'height', 'duration' ]

        onStatusChanged: {
            if (status == DocumentGalleryItem.Finished) {
                nameItem.value = galleryItem.metaData.fileName
                sizeItem.value = Format.formatFileSize(galleryItem.metaData.fileSize)
                typeItem.value = galleryItem.metaData.mimeType
                widthItem.value = galleryItem.metaData.width
                heightItem.value = galleryItem.metaData.height

                if (itemType == DocumentGallery.Video) {
                    durationItem.value = Format.formatDuration(galleryItem.metaData.duration, Formatter.DurationLong)
                }
            }
        }
    }

    Column {
        width: parent.width
        PageHeader {
            //% "Details"
            title: qsTrId("gallery-he-details")
        }
        GalleryDetailsItem {
            id: nameItem
            //% "Filename"
            detail: qsTrId("gallery-la-filename")
        }
        GalleryDetailsItem {
            id: sizeItem
            //% "Size"
            detail: qsTrId("gallery-la-size")
        }
        GalleryDetailsItem {
            id: typeItem
            //% "Type"
            detail: qsTrId("gallery-la-type")
        }
        GalleryDetailsItem {
            id: widthItem
            //% "Width"
            detail: qsTrId("gallery-la-width")
        }
        GalleryDetailsItem {
            id: heightItem
            //% "Height"
            detail: qsTrId("gallery-la-height")
        }
        GalleryDetailsItem {
            id: durationItem
            //% "Duration"
            detail: qsTrId("gallery-la-duration")
            visible: value.length > 0
        }
    }
}
