import QtQuick 1.1
import Sailfish.Silica 1.0
import QtMobility.gallery 1.1

Page {
    id: detailsPage
    property alias modelItem: galleryItem.item

    allowedOrientations: window.allowedOrientations

    PageHeader {
        //% "Details"
        title: qsTrId("gallery-he-details")
    }

    DocumentGalleryItem {
        id: galleryItem
        autoUpdate: false
        properties: [ 'fileName', 'fileSize', 'mimeType', 'width', 'height', 'duration' ]

        onStatusChanged: {
            if (status == DocumentGalleryItem.Finished) {
                nameLabel.text = galleryItem.metaData.fileName
                sizeLabel.text = sizeDescription(galleryItem.metaData.fileSize)
                typeLabel.text = galleryItem.metaData.mimeType
                widthLabel.text = galleryItem.metaData.width
                heightLabel.text = galleryItem.metaData.height

                if (itemType == DocumentGallery.Video) {
                    //% "Duration"
                    durationHeading.text = qsTrId("gallery-la-duration")
                    durationLabel.text = durationDescription(galleryItem.metaData.duration)
                }
            }
        }

        function sizeDescription(size) {
            // FIXME: in french these should be mega/kilo octets
            var bytes = parseInt(size)
            if (bytes > (1024 * 1024)) {
                return Math.floor(bytes / (1024 * 1024)) + 'MB'
            }
            if (bytes > 1024) {
                return Math.floor(bytes / 1024) + 'KB'
            }
            return size + 'B'
        }

        function durationDescription(duration) {
            var seconds = parseInt(duration)
            var minutes = Math.floor(seconds / 60) % 60
            var hours = Math.floor(seconds / 3600)
            seconds %= 60

            return ((hours < 10) ? '0' : '') + hours + ':' + ((minutes < 10) ? '0' : '') + minutes + ':' + ((seconds < 10) ? '0' : '') + seconds
        }
    }

    Column {
        y: theme.itemSizeLarge
        x: theme.paddingLarge

        Label {
            height: 40
            font.family: theme.fontFamilyHeading
            //: Details page
            //% "Filename"
            text: qsTrId("gallery-la-filename")
        }
        Label {
            id: nameLabel
            height: 60
            text: ""
        }

        Label {
            height: 40
            font.family: theme.fontFamilyHeading
            //% "Size"
            text: qsTrId("gallery-la-size")
        }
        Label {
            id: sizeLabel
            height: 60
            text: ""
        }

        Label {
            height: 40
            font.family: theme.fontFamilyHeading
            //% "Type"
            text: qsTrId("gallery-la-type")
        }
        Label {
            id: typeLabel
            height: 60
            text: ""
        }

        Label {
            height: 40
            font.family: theme.fontFamilyHeading
            //% "Width"
            text: qsTrId("gallery-la-width")
        }
        Label {
            id: widthLabel
            height: 60
            text: ""
        }

        Label {
            height: 40
            font.family: theme.fontFamilyHeading
            //% "Height"
            text: qsTrId("gallery-la-height")
        }
        Label {
            id: heightLabel
            height: 60
            text: ""
        }

        Label {
            id: durationHeading
            height: 40
            font.family: theme.fontFamilyHeading
            text: ""
        }
        Label {
            id: durationLabel
            height: 60
            text: ""
        }
    }
}
