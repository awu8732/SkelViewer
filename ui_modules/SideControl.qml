// SideControl.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Imagine
import QtQuick.Layouts
import HMR_Trial_2.Playback

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

        // Header Section
        SectionBox {
            Layout.fillWidth: true

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                Label {
                    text: "SkelVIEW"
                    font.bold: true
                    font.pixelSize: 25
                    color: "white"
                    Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                }

                Label {
                    text: "Kinematic Motion Analysis"
                    font.bold: true
                    font.pixelSize: 14
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
                width: scrollArea.width
                spacing: 15

                // SECTION: Root Imprint
                SectionBox {
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4

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
                                text: "Trail Length: " + globalSV.imprintTrailLength
                                color: palette.highlight
                                Layout.alignment: Qt.AlignVCenter
                            }

                            Item { Layout.fillWidth: true }

                            Slider {
                                id: trailLengthSlider
                                from: 10
                                to: 510
                                stepSize: 20
                                value: globalSV.imprintTrailLength
                                Layout.preferredWidth: sideControlRoot.width * 0.50
                                Layout.minimumWidth: Layout.preferredWidth
                                Layout.maximumWidth: Layout.preferredWidth

                                onValueChanged: globalSV.imprintTrailLength = Math.round(value)
                            }
                        }
                    }
                }

                // SECTION: Motion Scatter
                SectionBox {
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4

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
                                text: "Window: " + globalSV.scatterCount
                                Layout.alignment: Qt.AlignVCenter
                            }

                            Item { Layout.fillWidth: true }

                            Slider {
                                id: windowLengthSlider
                                from: 0
                                to: 10
                                stepSize: 1
                                value: globalSV.scatterCount
                                Layout.preferredWidth: sideControlRoot.width * 0.50
                                Layout.minimumWidth: Layout.preferredWidth
                                Layout.maximumWidth: Layout.preferredWidth

                                onValueChanged: globalSV.scatterCount = value
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            enabled: globalSV.showScatter
                            spacing: 10

                            Label {
                                color: palette.highlight
                                text: "Step: " + globalSV.scatterStep
                                Layout.alignment: Qt.AlignVCenter
                            }

                            Item { Layout.fillWidth: true }

                            Slider {
                                id: stepCountSlider
                                from: 1
                                to: 10
                                stepSize: 1
                                value: globalSV.scatterStep
                                Layout.preferredWidth: sideControlRoot.width * 0.50
                                Layout.minimumWidth: Layout.preferredWidth
                                Layout.maximumWidth: Layout.preferredWidth
                                onValueChanged: globalSV.scatterStep = value
                            }
                        }
                    }
                }

                // SECTION: Playback
                SectionBox {
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8
                            Label {
                                color: palette.highlight
                                text: "Playback"
                                font.bold: true
                                Layout.alignment: Qt.AlignVCenter
                            }
                            Item { Layout.fillWidth: true }
                            Button {
                                id: playButton
                                icon.name: PlaybackHub.playing ? "media-playback-pause" : "media-playback-start"
                                text: PlaybackHub.playing ? " Pause" : " Play"
                                Layout.alignment: Qt.AlignRight
                                Layout.minimumWidth: 70
                                padding: 8
                                onClicked: PlaybackHub.playing = !PlaybackHub.playing
                                background: Rectangle {
                                    radius: 4
                                    color: palette.highlight
                                }
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8
                            Label {
                                color: palette.highlight
                                text: "Speedup: " + PlaybackHub.playbackRate + "x"
                                Layout.alignment: Qt.AlignVCenter
                            }
                            Item { Layout.fillWidth: true }
                            Slider {
                                id: fpsSlider
                                from: 0
                                to: 4
                                stepSize: 1
                                value: 2
                                Layout.preferredWidth: sideControlRoot.width * 0.50
                                Layout.minimumWidth: Layout.preferredWidth
                                Layout.maximumWidth: Layout.preferredWidth
                                onValueChanged: {
                                    const factors = [0.25, 0.5, 1.0, 2.0, 3.0]
                                    PlaybackHub.playbackRate = factors[value]
                                }
                            }
                        }
                    }
                }

                // SECTION: Camera Follow
                SectionBox {
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
                }

                // SECTION: Camera Controls
                SectionBox {
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
                }

                Rectangle { height: 18; opacity: 0 }
            }
        }
    }
}
