import QtQuick
import QtQuick.Controls

Rectangle {
    id: menuBar
    width: parent ? parent.width * 0.75 : 800
    height: parent ? parent.height * 0.1 : 100
    color: "#222"

    Row {
        spacing: 10
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 10

        Button {
            text: "Open"
            onClicked: console.log("Open clicked")
        }

        Button {
            text: "Save"
            onClicked: console.log("Save clicked")
        }

        Button {
            text: "Reset Camera"
            onClicked: console.log("Reset Camera clicked")
        }

        Button {
            text: "Toggle Joints"
            onClicked: console.log("Toggle Joints clicked")
        }
    }
}
