import QtQuick
import QtQuick.Controls
import QtQuick3D

FocusScope {
    id: cameraControls
    focus: true
    property vector3d defaultPosition: Qt.vector3d(1, 2, 3)
    property vector3d defaultRotation: Qt.vector3d(-25, 15, 0)
    property bool cameraFollowEnabled: false
    property var skeletonModel

    property real cameraX: defaultPosition.x
    property real cameraY: defaultPosition.y
    property real cameraZ: defaultPosition.z
    property real moveStep: 0.3
    property real mouseSensitivity: 0.2
    property bool dragging: false
    property real lastMouseX: 0
    property real lastMouseY: 0

    property PerspectiveCamera camera

    Keys.onPressed: function(event) {
        switch (event.key) {
            case Qt.Key_Left: cameraX -= moveStep; break
            case Qt.Key_Right: cameraX += moveStep; break
            case Qt.Key_Up: cameraY += moveStep; break
            case Qt.Key_Down: cameraY -= moveStep; break
        }
        event.accepted = true
    }
    Keys.priority: Keys.BeforeItem

    MouseArea {
        anchors.fill: parent
        onPressed: function(mouse) {
            cameraControls.forceActiveFocus()
            cameraControls.dragging = true
            cameraControls.lastMouseX = mouse.x
            cameraControls.lastMouseY = mouse.y
        }
        onReleased: cameraControls.dragging = false
        onPositionChanged: function(mouse) {
            if (cameraControls.dragging && cameraControls.camera) {
                let dx = mouse.x - cameraControls.lastMouseX
                let dy = mouse.y - cameraControls.lastMouseY
                cameraControls.camera.eulerRotation.y += dx * cameraControls.mouseSensitivity
                cameraControls.camera.eulerRotation.x += dy * cameraControls.mouseSensitivity
                cameraControls.lastMouseX = mouse.x
                cameraControls.lastMouseY = mouse.y
            }
        }
    }

    // COOL FEATURE -> reimplement later
    // Connections {
    //     target: skeletonModel
    //     ignoreUnknownSignals: true

    //     function onCenterChanged(center) {
    //         if (!cameraFollowEnabled)
    //             return;
    //         if (!skeletonManager || skeletonManager.skeletons.length !== 1)
    //                     return;

    //         // Smooth camera follow (adjust values as you like)
    //         const offset = Qt.vector3d(0.5, 0.8, 2.0)

    //         camera.position = Qt.vector3d(
    //             camera.position.x * 0.85 + (center.x + offset.x) * 0.15,
    //             camera.position.y * 0.85 + (center.y + offset.y) * 0.15,
    //             camera.position.z * 0.85 + (center.z + offset.z) * 0.15
    //         )

    //         camera.lookAt(center)
    //     }
    // }

    onCameraYChanged: {
            if (cameraY < -1) cameraY = -1
        }

    function resetCamera() {
        cameraX = defaultPosition.x
        cameraY = defaultPosition.y
        cameraZ = defaultPosition.z

        if (camera) {
            camera.eulerRotation = Qt.vector3d(
                defaultRotation.x,
                defaultRotation.y,
                defaultRotation.z
            )
        }
    }
}
