// SideControl.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Imagine
import QtQuick.Layouts

Drawer {
    id: sideControlRoot
    edge: Qt.LeftEdge

    y: 50
    height: parent.height - 120
    width: parent ? parent.width * 0.27 : 280

    modal: false
    interactive: true
    dragMargin: 40
    closePolicy: Popup.NoAutoClose
    background: Rectangle {
        color: "transparent"
    }

    Component.onCompleted: sideControlRoot.open()

    property FocusScope cameraControls

    Rectangle {
        anchors.fill: parent
        color: "#333"
        radius: 4
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: parent ? parent.width * 0.03 : 22
        spacing: 15

        Rectangle {
            Layout.fillWidth: true
            height: 80
            color: "transparent"
            border.width: 1
            border.color: "#444"

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 4

                Label {
                    text: "SkelVIEW"
                    font.bold: true
                    font.pixelSize: 25
                    color: "white"
                    Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                }

                Label {
                    text: "Motion Analysis"
                    font.bold: true
                    font.pixelSize: 15
                    color: "white"
                    Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                }
            }
        }

        Flickable {
            id: scrollArea
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: 10
            contentHeight: columnContent.implicitHeight
            interactive: true
            clip: true

            ColumnLayout {
                id: columnContent
                width: parent.width
                spacing: 15

                /* SECTION: Root Imprint */
                RowLayout {
                    Layout.fillWidth: true

                    Label {
                        color: palette.highlight
                        text: "Root Imprint"
                        font.bold: true
                        Layout.alignment: Qt.AlignVCenter
                    }

                    Item { Layout.fillWidth: true }

                    Switch {
                        id: switchRoot
                        Layout.alignment: Qt.AlignRight
                        checked: globalSV.showImprint
                        onCheckedChanged: globalSV.showImprint = checked
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    enabled: globalSV.showImprint
                    spacing: 10

                    Label {
                        text: "Trail Length: " + rootImprint1.trailLength
                        color: palette.highlight
                        Layout.alignment: Qt.AlignVCenter
                    }

                    Item { Layout.fillWidth: true }

                    Slider {
                        id: trailLengthSlider
                        from: 10
                        to: 510
                        stepSize: 20
                        value: rootImprint1.trailLength
                        Layout.preferredWidth: sideControlRoot.width * 0.50
                        Layout.minimumWidth: Layout.preferredWidth
                        Layout.maximumWidth: Layout.preferredWidth

                        onValueChanged: rootImprint1.trailLength = Math.round(value)
                    }
                }

                /* SECTION: Motion Scatter */
                RowLayout {
                    Layout.fillWidth: true

                    Label {
                        color: palette.highlight
                        text: "Motion Scatter"
                        font.bold: true
                        Layout.alignment: Qt.AlignVCenter
                    }

                    Item { Layout.fillWidth: true }

                    Switch {
                        id: switchScatter
                        Layout.alignment: Qt.AlignRight
                        checked: globalSV.showScatter
                        onCheckedChanged: globalSV.showScatter = checked
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    enabled: globalSV.showScatter
                    spacing: 10

                    Label {
                        color: palette.highlight
                        text: "Window: " + motionScatter.n
                        Layout.alignment: Qt.AlignVCenter
                    }

                    Item { Layout.fillWidth: true }

                    Slider {
                        id: windowLengthSlider
                        from: 0
                        to: 10
                        stepSize: 1
                        value: motionScatter.n
                        Layout.preferredWidth: sideControlRoot.width * 0.50
                        Layout.minimumWidth: Layout.preferredWidth
                        Layout.maximumWidth: Layout.preferredWidth

                        onValueChanged: motionScatter.n = value
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    enabled: globalSV.showScatter
                    spacing: 10

                    Label {
                        color: palette.highlight
                        text: "Step: " + motionScatter.stepCount
                        Layout.alignment: Qt.AlignVCenter
                    }

                    Item { Layout.fillWidth: true }

                    Slider {
                        id: stepCountSlider
                        from: 1
                        to: 10
                        stepSize: 1
                        value: motionScatter.stepCount
                        Layout.preferredWidth: sideControlRoot.width * 0.50
                        Layout.minimumWidth: Layout.preferredWidth
                        Layout.maximumWidth: Layout.preferredWidth
                        onValueChanged: motionScatter.stepCount = value
                    }
                }

                /* SECTION: Playback */
                PlaybackHub {
                    Layout.fillWidth: true
                    //Layout.preferredHeight: implicitHeight
                    //Layout.minimumHeight: implicitHeight

                    onFrameChanged: function(newFrame) {
                        jointProvider3D.updateJoints(newFrame)
                        mainWindow.imprintRoot.recordFrame()
                        mainWindow.currentFrame = newFrame
                    }
                }

                /* SECTION: Camera Follow */

                RowLayout {
                    Layout.fillWidth: true

                    Label {
                        color: palette.highlight
                        text: "Camera Follow"
                        font.bold: true
                        Layout.alignment: Qt.AlignVCenter
                    }

                    Item { Layout.fillWidth: true }

                    Switch {
                        Layout.alignment: Qt.AlignRight
                        checked: cameraControls.cameraFollowEnabled
                        onCheckedChanged: cameraControls.cameraFollowEnabled = checked
                    }
                }

                /* SECTION: Camera Controls */
                RowLayout {
                    Layout.fillWidth: true

                    Label {
                        text: "Camera Zoom"
                        color: palette.highlight
                        font.bold: true
                        Layout.alignment: Qt.AlignVCenter
                    }

                    Item { Layout.fillWidth: true }

                    Slider {
                        id: cameraZoomSlider
                        from: -2
                        to: 30
                        stepSize: 0.1
                        value: cameraControls ? cameraControls.cameraZ : 0
                        Layout.preferredWidth: sideControlRoot.width * 0.50
                        Layout.minimumWidth: Layout.preferredWidth
                        Layout.maximumWidth: Layout.preferredWidth
                        focusPolicy: Qt.NoFocus

                        onValueChanged: {
                            if (cameraControls) cameraControls.cameraZ = value
                        }
                    }
                }

                Rectangle { height: 18; opacity: 0 }
            }

            // WheelHandler {
            //     target: scrollArea
            //     onWheel: {
            //         var delta = 0
            //         if (wheel.angleDelta) delta = wheel.angleDelta.y
            //         else if (wheel.pixelDelta) delta = wheel.pixelDelta.y

            //         if ((scrollArea.contentY <= 0 && delta > 0) ||
            //             (scrollArea.contentY >= scrollArea.contentHeight - scrollArea.height && delta < 0)) {
            //             wheel.accepted = false
            //         } else {
            //             wheel.accepted = true
            //         }
            //     }
            // }

            // ScrollBar.vertical: ScrollBar {
            //     policy: ScrollBar.AlwaysOn
            //     anchors.right: parent.right
            //     width: 6
            //     contentItem: Rectangle { color: "#888"; radius: 4 }
            // }
        }
    }
}
