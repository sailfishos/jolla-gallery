import QtQuick 1.1
import Sailfish.Silica 1.0

Item {
    property alias detail: detailLabel.text
    property alias value: valueLabel.text

    width: parent.width
    height: theme.itemSizeLarge

    Column {
        x: theme.paddingLarge
        Label {
            id: detailLabel
            height: theme.fontSizeLarge
            font.family: theme.fontFamilyHeading
        }
        Label { id: valueLabel }
    }
}

