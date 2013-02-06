import QtQuick 1.1
import com.jolla.gallery 1.0
import QtMobility.gallery 1.1

MediaSource {
    property alias type: galleryModel.rootType
    property alias filter: galleryModel.filter
    model: DocumentGalleryModel {
        id: galleryModel
        properties: [ "url", "mimeType", "title", "dateTaken" ]
        autoUpdate: true        
        sortProperties: ["-dateTaken"]
    }
    count: galleryModel.count
    ready: true
}
