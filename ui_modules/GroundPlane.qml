// GroundPlane.qml
import QtQuick3D

Model {
    property string color: "#2060ff"
    property real width: 50
    property real depth: 50
    property real height: -2

    source: "#Cube"
    scale: Qt.vector3d(width, 0.05, depth)
    y: height
    materials: DefaultMaterial {
        diffuseColor: color
    }
}
