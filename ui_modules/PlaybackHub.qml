import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: frameControls

    property FocusScope cameraControls
    property int frameRate: jointProvider3D ? jointProvider3D.getFPS() : 30
    property real speedFactor: 1.0
    property real computedInterval: 1000 / (frameRate * speedFactor)
    property bool running: false

    signal frameChanged(int frame)

    // --- Timer ---
    Timer {
        id: timer
        interval: frameControls.computedInterval
        repeat: true
        running: frameControls.running

        onTriggered: {
            if (mainWindow.currentFrame >= mainWindow.maxFrame) {
                mainWindow.currentFrame = 0
            } else {
                mainWindow.currentFrame += 1
            }
            jointProvider3D.updateJoints(mainWindow.currentFrame)
        }
    }

    function start() { running = true; timer.start(); timer.interval = computedInterval}
    function stop() { running = false; timer.stop() }
    function reset() { mainWindow.currentFrame = 0; }

    // --- MAIN LAYOUT ---
    ColumnLayout {
        id: column
        anchors.fill: parent
        spacing: 8

        /* -----------------------------------------------------------
           ROW 1: Playback title + Play button
        ----------------------------------------------------------- */
        RowLayout {
            Layout.fillWidth: true

            Label {
                color: palette.highlight
                text: "Playback"
                font.bold: true
                Layout.alignment: Qt.AlignVCenter
            }

            Item { Layout.fillWidth: true }  // spacer

            Button {
                id: playButton
                icon.name: frameControls.running ? "media-playback-pause" : "media-playback-start"
                text: frameControls.running ? "Pause" : "Play"
                Layout.alignment: Qt.AlignRight
                Layout.minimumWidth: 70
                padding: 8

                onClicked: {
                    frameControls.running ? frameControls.stop()
                                          : frameControls.start()
                }
                background: Rectangle {
                    radius: 4
                    color: palette.highlight
                }
            }
        }

        /* -----------------------------------------------------------
           ROW 2: FPS label + FPS slider (60% width, right aligned)
        ----------------------------------------------------------- */
        RowLayout {
            Layout.fillWidth: true
            spacing: 8
            //enabled: frameControls.running

            Label {
                color: palette.highlight
                text: "Speedup: " + frameControls.speedFactor + "x"
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
                    frameControls.speedFactor = factors[value]
                    timer.interval = frameControls.computedInterval
                }
            }
        }
    }

    // Height grows with content
    implicitHeight: column.implicitHeight
}
