import QtQuick
import QtQuick.Controls

Rectangle {
    id: menuBar
    implicitWidth: menuRow.width
    height: parent ? parent.height * 0.1 : 60
    color: "#222"

    signal resetCameraRequested()
    signal toggleAxesRequested()
    signal toggleImprintRequested()

    Row {
        id: menuRow
        height: parent.height
        spacing: 5
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: 10

        MenuButton { text: "Open"; onClicked: console.log("Open clicked") }
        MenuButton { text: "Save"; onClicked: console.log("Save clicked") }
        MenuButton { text: "Reset Camera"; onClicked: resetCameraRequested() }
        MenuButton { text: "Toggle Axes"; onClicked: toggleAxesRequested() }
    }
}
