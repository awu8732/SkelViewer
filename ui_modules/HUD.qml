import QtQuick
import QtQuick.Layouts

Item {
    id: hudContainer
    property FocusScope cameraControls

    anchors.right: parent.right
    anchors.bottom: parent.bottom
    anchors.rightMargin: parent ? parent.width * 0.05 : 50
    anchors.bottomMargin: 15

    Rectangle {
        id: background
        height: column.implicitHeight + 30
        width: column.implicitWidth + 30
        color: "#333"
        radius: 5

        ColumnLayout {
            id: column
            anchors.fill: parent
            anchors.margins: 15
            spacing: 10

            //Camera HUD
            Text {
                color: "white"
                text: cameraControls ?
                    "Camera HUD:\n" +
                    "(X, Y, Z): (" + cameraControls.camera.position.x.toFixed(2) + ", " + cameraControls.camera.position.y.toFixed(2) + ", " + cameraControls.camera.position.z.toFixed(2) + ")\n" +
                    "Pitch/Yaw: " + cameraControls.camera.eulerRotation.x.toFixed(1) + "°/" + cameraControls.camera.eulerRotation.y.toFixed(1) + "°\n"
                    : "Camera: N/A"
            }


            // Velocity/Acceleration HUD
            Text {
                color: "white"
                text: {
                    if (!jointProvider3D) return "Velocity/Acceleration: N/A"

                    const vel = jointProvider3D.getVelocity(currentFrame)
                    const acc = jointProvider3D.getAcceleration(currentFrame)
                    const speed = Math.sqrt(vel.x * vel.x + vel.y * vel.y + vel.z * vel.z)
                    const accel = Math.sqrt(acc.x * acc.x + acc.y * acc.y + acc.z * acc.z)

                    // REMOVE LATER
                    // const scale = 3.1
                    // const velScaled = {
                    //     x: vel.x * scale,
                    //     y: vel.y * scale,
                    //     z: vel.z * scale
                    // }

                    // const speed = Math.sqrt(
                    //     velScaled.x * velScaled.x +
                    //     velScaled.y * velScaled.y +
                    //     velScaled.z * velScaled.z
                    // )

                    return "Velocity: " + speed.toFixed(2) + " m/s\n" +
                           "(" + vel.x.toFixed(2) + ", " +  vel.y.toFixed(2) + ", " + vel.z.toFixed(2) + ")\n" +
                           "Acceleration: " + accel.toFixed(2) + " m/s²\n" +
                           "(" + acc.x.toFixed(2) + ", " +  acc.y.toFixed(2) + ", " + acc.z.toFixed(2) + ")"
                }
            }
        }
    }
}
