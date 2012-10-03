import QtQuick 1.1
import com.jolla.components 1.0
import QtMobility.gallery 1.1

/**
  * MediaModel provides local content from a device. Currently supported content is:
  * - Images
  * - Videos
  *
  * The model updates content automatically e.g. when a new content is copied to the
  * device via USB or when a new photo is captured. It's possible to call queryX()
  * functions to query different content.
  */
DocumentGalleryModel {
    id: localMediaModel

    function queryImages()
    {       
        var oldFilter = filter
        rootType = DocumentGallery.Image
        filter = __createFilter("image")

        if (oldFilter !== null)
            oldFilter.destroy()
    }

    function queryVideos()
    {
        rootType = DocumentGallery.Video
        var oldFilter = filter
        filter = __createFilter("video")

        if (oldFilter !== null)
            oldFilter.destroy()
    }

    function queryAll()
    {
        // FilterUnion
        console.log("Query all")
        var images = __createFilter("image")
        var videos = __createFilter("video")

        var filterUnion = Qt.createQmlObject('import QtMobility.gallery 1.1; GalleryFilterUnion { }',
                                             localMediaModel, "queryAllFilter");
        filterUnion.filters = [ images, videos ]
        var oldFilter = filter
        filter = filterUnion

        if (oldFilter !== null)
            oldFilter.destroy()

    }

    function __createFilter(type)
    {
        return Qt.createQmlObject('import QtMobility.gallery 1.1; GalleryStartsWithFilter { property: "mimeType"; value: "' + type + '/" }',
                                  localMediaModel, type + "Filter")
    }


    autoUpdate: true   
    properties: [ "dateTaken", "url", "mimeType" ]
    sortProperties: ["-dateTaken"]
}

