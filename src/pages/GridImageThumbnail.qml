import QtQuick 2.0
import org.nemomobile.thumbnailer 1.0

/**
  * GridThumbnail is for displaying either photo or video thumbnail.
  * NOTE: At the moment it only supports photothumbnails.
  */

Thumbnail {
    id: thumbnail


    source: url
    mimeType: model.mimeType
    width:  size
    height: size
    sourceSize.width: width
    sourceSize.height: height

    priority: index >= firstVisibleIndex && index < firstVisibleIndex + 15
              ? Thumbnail.NormalPriority
              : Thumbnail.LowPriority

}
