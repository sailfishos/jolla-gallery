import QtQuick 2.0


Item {
    property bool timerEnabled: false
    property int timerInterval: 10000
    property variant model

    signal timerTriggered

    Timer {
        interval: 15000
        repeat: true
        running: window.applicationActive && timerEnabled && pageStack.currentPage === startPage
        onTriggered: timerTriggered()
    }

}
