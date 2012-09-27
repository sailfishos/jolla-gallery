import QtQuick 1.1
import com.jolla.components 1.0

Page{
    id: fullscreenPage
    property alias model: imageList.model
    property int currentIndex


    function hideOrShowMenu()
    {
        if (imageList.y === 0)
            imageList.y = fullscreenPage.height/2
        else
            imageList.y = 0
    }

    ListModel{
        id: actionsModel
        ListElement{
            name: "Email"
            title: "Share"
        }
        ListElement{
            name: "SMS"
        }
        ListElement{
            name: "Facebook"
        }
        ListElement{
            name: "Picasa"
        }
        ListElement{
            name: "Evernote"
        }
    }

    JollaListView{
        id: menuList
        anchors{ top: fullscreenPage.top }
        width: parent.width
        height: parent.height / 2 // This is a workaround for keeping PullDownMenu up
        model: actionsModel

        header:PullDownMenu {
            id: pullDownMenu

            MenuItem {
                text: "delete"
                onClicked: {
                    console.log("Delete clicked")
                }
            }
            MenuItem {
                text: "edit"
                onClicked: {
                    console.log("Delete clicked")
                }
            }
            MenuItem {
                text: "all images"
                onClicked: {
                    pageStack.pop();
                    console.log("all images")
                }
            }

         }

        delegate:BackgroundItem{

            width: menuList.width

            Label{
                text: name                
                anchors{left: parent.left; verticalCenter: parent.verticalCenter}
            }

            Label{
                text: title === undefined?"":title                
                color: theme.highlightColor
                anchors{right: parent.right; verticalCenter: parent.verticalCenter}
            }

            onClicked: fullscreenPage.hideOrShowMenu()
        }
    }

    // TODO: Replace ListView with more nemo gallery like implementation. This is just a placeholder
    //       in this implementation a
    JollaListView{
        id: imageList
        width: fullscreenPage.width
        height: fullscreenPage.height

        Behavior on y {NumberAnimation{duration: 200}}
        orientation: ListView.Horizontal
        snapMode: ListView.SnapOneItem
        clip: true

        delegate: Image{
            source: model.fullsize
            width: imageList.width
            height: imageList.height
            fillMode: Image.PreserveAspectCrop
            clip: true
            MouseArea{
                anchors.fill: parent
                onClicked: fullscreenPage.hideOrShowMenu();
            }

        }
    }


}
