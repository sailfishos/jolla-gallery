import QtQuick 1.1
import "DummyData.js" as DummyData

ListModel{
    id: model
    Component.onCompleted:  DummyData.populateThumbnails(model, 120)
}
