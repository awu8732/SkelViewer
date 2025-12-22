// SectionBox.qml
import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root
    radius: 4
    border.width: 1
    border.color: "white"
    color: "transparent"

    Layout.fillWidth: true
    Layout.minimumHeight: 75

    // Define padding as a property so it's easy to adjust
    property int innerPadding: 12

    // CRITICAL: The rectangle's height is now driven by the layout's size
    implicitHeight: contentLayout.implicitHeight + (innerPadding * 2)

    ColumnLayout {
        id: contentLayout

        // Anchor to the top and sides, but NOT the bottom.
        // We let the layout grow downwards naturally.
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            margins: root.innerPadding
        }

        spacing: 20

        // This allows you to drop components inside SectionBox {} in other files
        default property alias data: contentLayout.data
    }
}
