import QtQuick
import QtQuick3D
import QtQuick.Controls
import QtQuick3D.Helpers

View3D {
    id: view
    anchors.fill: parent

    // Allow parent to pass cameraControls reference
    property FocusScope cameraControls
    property bool showAxes: true

    environment: SceneEnvironment {
        backgroundMode: SceneEnvironment.Color
        clearColor: "#202020"
    }

    Node {
        id: sceneRoot

        PerspectiveCamera {
            id: camera
            //property alias cameraControls: cameraControls
            // Keep reference in cameraControls for mouse rotation
            Component.onCompleted: {
                if (cameraControls) cameraControls.camera = camera
            }
            position: Qt.vector3d(cameraControls ? cameraControls.cameraX : -1,
                                   cameraControls ? cameraControls.cameraY : 3,
                                   cameraControls ? cameraControls.cameraZ : 5)
            eulerRotation: cameraControls.defaultRotation
            clipNear: 0.1
            clipFar: 200
        }

        DirectionalLight { eulerRotation: Qt.vector3d(-45, 45, 0); brightness: 2 }

        // Axes
        Model { source: "#Cylinder"; visible: view.showAxes
            position: Qt.vector3d(1,0,0); eulerRotation: Qt.vector3d(0,0,90);
            scale: Qt.vector3d(4e-4,3,4e-4); materials: DefaultMaterial { diffuseColor: "#333" } }
        Model { source: "#Cylinder"; visible: view.showAxes
            position: Qt.vector3d(0,0,0); scale: Qt.vector3d(4e-4,3,4e-4);
            materials: DefaultMaterial { diffuseColor: "#333" } }
        Model { source: "#Cylinder"; visible: view.showAxes
            position: Qt.vector3d(0,0,1); eulerRotation: Qt.vector3d(90,0,0);
            scale: Qt.vector3d(4e-4,3,4e-4); materials: DefaultMaterial { diffuseColor: "#333" } }

    }
}
