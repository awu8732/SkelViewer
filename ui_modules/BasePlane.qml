import QtQuick
import QtQuick3D

View3D {
    id: view
    anchors.fill: parent

    environment: SceneEnvironment {
        backgroundMode: SceneEnvironment.Color
        clearColor: "#202020"
    }

    Node {
        id: sceneRoot

        PerspectiveCamera {
            id: camera
            position: Qt.vector3d(inputArea.cameraX, inputArea.cameraY, inputArea.cameraZ)
            eulerRotation: Qt.vector3d(-15, 0, 0)
            clipNear: 0.1
            clipFar: 200
        }

        DirectionalLight {
            eulerRotation: Qt.vector3d(-45, 45, 0)
            brightness: 2
        }

        // Blue ground plane
        Model {
            source: "#Cube"
            scale: Qt.vector3d(50, 0.05, 50)
            y: -2
            materials: DefaultMaterial { diffuseColor: "#2060ff" }
        }

        // Coordinate system arrows (X=red, Y=green, Z=blue)
        // X-axis (red)
        Model {
            source: "#Cylinder"
            position: Qt.vector3d(1, 0.4, 0)
            eulerRotation: Qt.vector3d(0, 0, 90)
            scale: Qt.vector3d(0.01, 3, 0.01)
            materials: DefaultMaterial { diffuseColor: "red" }
        }

        // Y-axis (green)
        Model {
            source: "#Cylinder"
            position: Qt.vector3d(0, 0, 0)
            scale: Qt.vector3d(0.01, 3, 0.01)
            materials: DefaultMaterial { diffuseColor: "green" }
        }

        // Z-axis (blue)
        Model {
            source: "#Cylinder"
            position: Qt.vector3d(0, 0.4, 1)
            eulerRotation: Qt.vector3d(90, 0, 0)
            scale: Qt.vector3d(0.01, 3, 0.01)
            materials: DefaultMaterial { diffuseColor: "blue" }
        }
    }
}

