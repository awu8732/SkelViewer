import QtQuick
import QtQuick.Controls

Item {
    id: wrapper
    property alias text: button.text
    signal clicked

    implicitHeight: parent ? parent.height : 60
    implicitWidth: Math.max(150, button.implicitWidth)  // minimum width

    Button {
        id: button
        anchors.fill: parent
        text: "Button"
        font.bold: true
        onClicked: wrapper.clicked()  // propagate click

        background: Rectangle {
            radius: 4
            color: button.down ? "#222" :
                   button.hovered ? "#222" :
                                     "#333"

            border.color: "#333"
            border.width: 1
        }
    }
}
