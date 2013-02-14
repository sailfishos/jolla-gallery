import QtQuick 1.1
import org.nemomobile.thumbnailer 1.0

/**
  * GridThumbnail is for displaying either photo or video thumbnail.
  * NOTE: At the moment it only supports photothumbnails.
  */

Thumbnail {
    id: thumbnail

    sourceSize.width: screen.width/3
    sourceSize.height: screen.width/3

    source: url
    mimeType: model.mimeType

    priority: index >= grid.firstVisible && index < grid.firstVisible + 15
              ? Thumbnail.NormalPriority
              : Thumbnail.LowPriority
}
