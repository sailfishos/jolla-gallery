import QtQuick 1.1
import org.nemomobile.thumbnailer 1.0

Item {
    id: thumbnail

    Image {
        id: icon1
        asynchronous: true
        sourceSize.width: thumbnail.width
        sourceSize.height: thumbnail.height
        Behavior on opacity { NumberAnimation { duration: 1500 }}
    }

    Image {
        id: icon2
        // Just show the first item from the model in the beginning.
        // after everything's loaded, we use timer to make a slideshow
        // effect.
        source: mediaModel.get(0).url
        asynchronous: true
        sourceSize.width: thumbnail.width
        sourceSize.height: thumbnail.height
        Behavior on opacity { NumberAnimation { duration: 1500 }}
    }

    Timer {
        property int iconIndex: 1
        interval: 10000
        repeat: true
        running: window.applicationActive
        onTriggered: {
            var modelIndex = Math.floor((Math.random()*mediaModel.count));
            if ( iconIndex % 2 == 0){
                icon2.source = "image://nemoThumbnail/" + mediaModel.get(modelIndex).url
                icon1.opacity = 0
                icon2.opacity = 1
            } else {
                icon1.source = "image://nemoThumbnail/" + mediaModel.get(modelIndex).url
                icon2.opacity = 0
                icon1.opacity = 1
            }
            ++iconIndex;
        }
    }
}
