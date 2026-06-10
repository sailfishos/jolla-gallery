// SPDX-FileCopyrightText: 2013-2018 Jolla Ltd.
// SPDX-FileCopyrightText: 2025 Jolla Mobile Ltd
//
// SPDX-License-Identifier: BSD-3-Clause

import QtQuick 2.0


Item {
    property int timerInterval: 10000
    property bool timerEnabled
    property var model

    signal timerTriggered

    Timer {
        interval: parent.timerInterval
        repeat: true
        running: window.applicationActive && timerEnabled && pageStack.currentPage === startPage
        onTriggered: timerTriggered()
    }
}
