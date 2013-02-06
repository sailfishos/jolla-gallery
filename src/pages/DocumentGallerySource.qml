import QtQuick 1.1
import com.jolla.gallery 1.0
import QtMobility.gallery 1.1

MediaSource {
    property alias type: galleryModel.rootType
    property alias filter: galleryModel.filter
    property alias sortProperties: galleryModel.sortProperties
    property alias properties: galleryModel.properties

    model: DocumentGalleryModel {
        id: galleryModel
        properties: [ "url", "mimeType", "title"]
        autoUpdate: true
    }
    count: galleryModel.count
    ready: true
}
