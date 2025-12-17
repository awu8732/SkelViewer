import QtQuick
import QtQuick.Controls

Item {
    property FocusScope cameraControls
    anchors.bottom: parent.bottom
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.bottomMargin: 15
    width: parent.width
    height: column.implicitHeight

    property int frame: 0
    property int max_frame: 0
    property var jointProvider

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
                text: "Frame " + mainWindow.currentFrame
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
            //to: mainWindow.maxFrame
            stepSize: 1
            //value: mainWindow.currentFrame
            focusPolicy: Qt.NoFocus
            onValueChanged: {
                //mainWindow.currentFrame = value
                jointProvider.updateJoints(value)
            }
        }
    }
    Component.onCompleted: {
        if (jointProvider && typeof jointProvider.frameCount === "number") {
                max_frame = jointProvider.frameCount - 1
                slider.to = max_frame  // update the Slider range
            } else {
                max_frame = 0
                slider.to = 0
            }
    }
}


