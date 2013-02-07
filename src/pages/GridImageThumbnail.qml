import QtQuick 1.1
import org.nemomobile.thumbnailer 1.0

/**
  * GridThumbnail is for displaying either photo or video thumbnail.
  * NOTE: At the moment it only supports photothumbnails.
  */

MouseArea {
    id: delegate

    property alias menuOffset: thumbnail.y

    Thumbnail {
        id: thumbnail

        property bool secondRow: window.isPortrait
                ? index <= 5 && 3 <= index
                : index <= 9 && 5 <= index

        z: 1    // The context menu should be below the thumbnail if it is scaled.
        width: delegate.GridView.view.cellWidth
        height: delegate.GridView.view.cellHeight
        sourceSize.width: screen.width/3
        sourceSize.height: screen.width/3

        source: url
        mimeType: model.mimeType
        opacity: delegate.GridView.view.showTitle && secondRow ? 0 : 1
        priority: index >= grid.firstVisible && index < grid.firstVisible + 15
                  ? Thumbnail.NormalPriority
                  : Thumbnail.LowPriority

        // Animation for displaying a title. Used only once for the
        // second row items.
        NumberAnimation on opacity {
            id: opacityAnimation
            duration: 1500
            to: 1
            onCompleted: delegate.GridView.view.showTitle = false
            running: delegate.GridView.view.showTitle
        }
    }
}
