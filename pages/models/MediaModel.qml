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
    property string currentMedia

    function queryImages()
    {
        if (currentMedia === "image")
            return;

        currentMedia  = "image"
        var oldFilter = filter
        rootType = DocumentGallery.Image
        filter = __createFilter(currentMedia)

        if (oldFilter !== null)
            oldFilter.destroy()
    }

    function queryVideos()
    {
        if (currentMedia === "video")
            return;

        currentMedia  = "video"
        rootType = DocumentGallery.Video
        var oldFilter = filter
        filter = __createFilter(currentMedia)

        if (oldFilter !== null)
            oldFilter.destroy()
    }

    function queryAll()
    {

        if (currentMedia === "all")
            return;

        currentMedia  = "all"

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

