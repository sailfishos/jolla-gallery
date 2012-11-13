import QtQuick 1.1
import com.jolla.components 1.0
import QtMobility.gallery 1.1

Page {
    id: detailsPage
    property alias modelItem: galleryItem.item

    PageHeader {
        title: qsTr("Details")
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
                    durationHeading.text = qsTr("Duration")
                    durationLabel.text = durationDescription(galleryItem.metaData.duration)
                }
            }
        }

        function sizeDescription(size) {
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
        y: 100
        x: 24

        Label {
            height: 40
            font.family: theme.fontFamilyHeading
            text: qsTr("Filename")
        }
        Label {
            id: nameLabel
            height: 60
            text: ""
        }

        Label {
            height: 40
            font.family: theme.fontFamilyHeading
            text: qsTr("Size")
        }
        Label {
            id: sizeLabel
            height: 60
            text: ""
        }

        Label {
            height: 40
            font.family: theme.fontFamilyHeading
            text: qsTr("Type")
        }
        Label {
            id: typeLabel
            height: 60
            text: ""
        }

        Label {
            height: 40
            font.family: theme.fontFamilyHeading
            text: qsTr("Width")
        }
        Label {
            id: widthLabel
            height: 60
            text: ""
        }

        Label {
            height: 40
            font.family: theme.fontFamilyHeading
            text: qsTr("Height")
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
