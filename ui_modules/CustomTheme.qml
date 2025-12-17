import QtQuick
import QtQuick.Controls

QtObject {
    id: theme

    Slider {
        id: sample
        visible: false
    }

    property color primary: sample.implicitBackgroundColor
}
