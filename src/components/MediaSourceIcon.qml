import QtQuick 1.1


Item {
    property bool timerEnabled: false
    property int timerInterval: 10000

    signal timerTriggered

    Timer {
        interval: 15000
        repeat: true
        running: window.applicationActive && timerEnabled && pageStack.currentPage === startPage
        onTriggered: timerTriggered()
    }

}
