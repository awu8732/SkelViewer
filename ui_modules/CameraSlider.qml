import QtQuick
import QtQuick.Controls

Item {
    property FocusScope cameraControls
    // anchors.left: parent.left
    // anchors.bottom: parent.bottom
    // anchors.leftMargin: parent ? parent.width * 0.05 : 50
    // anchors.bottomMargin: 10
    width: parent ? parent.width * 0.25 : 100
    height: column.implicitHeight


    Column {
        id: column
        width: parent.width
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 2

        Label {
            text: "Camera Zoom"
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Slider {
            from: -2
            to: 30
            value: 5
            width: parent.width
            anchors.left: parent.left
            focusPolicy: Qt.NoFocus

            onValueChanged: {
                if (cameraControls) cameraControls.cameraZ = value
            }
        }
    }
}


