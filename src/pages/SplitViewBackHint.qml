import QtQuick 2.0
import Sailfish.Silica 1.0

Loader {
    anchors.fill: parent
    active: counter.active
    sourceComponent: Component {
        Item {
            property bool pageActive: fullscreenPage.status === PageStatus.Active && Qt.application.active
            onPageActiveChanged: {
                if (pageActive) {
                    touchInteractionHint.restart()
                    pageActive = false
                    counter.increase()
                }
            }

            anchors.fill: parent
            InteractionHintLabel {
                //: Flick here to go to previous view
                //% "Flick here to go to previous view"
                text: qsTrId("gallery-la-split_view_back_hint")
                anchors.bottom: parent.bottom
                opacity: touchInteractionHint.running ? 1.0 : 0.0
                Behavior on opacity { FadeAnimation { duration: 1000 } }
            }
            TouchInteractionHint {
                id: touchInteractionHint

                direction: TouchInteraction.Right
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
    FirstTimeUseCounter {
        id: counter
        limit: 3
        key: "/sailfish/gallery/split_view_back_hint_count"
    }
}
