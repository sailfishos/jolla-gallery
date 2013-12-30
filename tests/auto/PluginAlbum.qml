import QtQuick 2.1
import com.jolla.gallery 1.0

MediaSource {
    title: "dynamic-gallery-album"
    icon: ""
    page: ""
    model: testModel
    count: testModel.count
    ready: count > 0

    property ListModel testModel: ListModel {
        ListElement { title: "item1" }
        ListElement { title: "item2" }
        ListElement { title: "item3" }
    }
}
