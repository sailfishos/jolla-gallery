import QtQuick 1.1
import com.jolla.components 1.0

Page{
    // TODO: handle orientation changes
    // TODO: Add Pulldown menu for other activities
    GridView{
        cellWidth: parent.width/4
        cellHeight: parent.width/4
        boundsBehavior: Flickable.StopAtBounds
        anchors.fill: parent
        model: imageModel

        delegate: Image{
            width: GridView.view.cellWidth
            height: GridView.view.cellHeight
            source: model.thumbnail

            MouseArea{
                anchors.fill: parent
                onClicked: window.pageStack.push(Qt.resolvedUrl("GalleryFullscreenPage.qml"), {currentIndex: index, model: imageModel} )
            }
        }

        ScrollBar { }
        ScrollDecorator {}
    }
}
