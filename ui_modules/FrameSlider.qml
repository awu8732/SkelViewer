import QtQuick
import QtQuick.Controls

Item {
    property FocusScope cameraControls
    anchors.bottom: parent.bottom
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.bottomMargin: 15
    width: parent.width
    height: column.implicitHeight

    required property var playback   // SkeletonPlayback*

    Column {
        id: column
        width: parent.width
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 5

        Rectangle {
            color: "#333"
            radius: 5
            anchors.horizontalCenter: parent.horizontalCenter
            width: labelFrame.implicitWidth * 1.5
            height: labelFrame.implicitHeight * 1.5

            Label {
                id: labelFrame
                text: "Frame " + playback.frame
                font.pixelSize: 20
                font.bold: true
                anchors.centerIn: parent
                color: "white"
                horizontalAlignment: Text.AlignHCenter
            }
        }

        Slider {
            id: slider
            width: parent.width * 0.9
            anchors.horizontalCenter: parent.horizontalCenter
            from: 0
            to: Math.max(0, playback.maxFrames - 1)
            stepSize: 1
            value: playback.frame
            focusPolicy: Qt.NoFocus

            onMoved: playback.setFrame(Math.round(value))
            onPressedChanged: {
                if (pressed)
                    playback.pause()
            }
        }
    }
}


