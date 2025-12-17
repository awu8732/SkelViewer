import QtQuick
import QtQuick.Controls
import QtQuick3D
import "ui_modules"

Window {
    id: mainWindow
    width: 800
    height: 600
    visible: true
    property int currentFrame: 0
    property int maxFrame: jointProvider3D ? jointProvider3D.frameCount - 1 : 0

    CameraControls {
        id: cameraControls
        anchors.fill: parent
        skeletonModel: mainSkel
        Component.onCompleted: cameraControls.forceActiveFocus()

        SceneView {
            id: globalSV
            cameraControls: cameraControls
            anchors.fill: parent

            property bool showImprint: false
            property bool showScatter: false

            MenuBar {
                anchors.top: parent.top
                anchors.right: parent.right
                onResetCameraRequested: cameraControls.resetCamera()
                onToggleAxesRequested: {
                    globalSV.showAxes = !globalSV.showAxes
                }
            }

            SkeletonModel {
                id: mainSkel
                jointProvider: jointProvider3D
            }

            SkeletonModel {
                id: secondSkel
                jointProvider: jointProvider3D_2
                jointColor: "pink"
            }

            MotionScatter {
                id: motionScatter
                jointProvider: jointProvider3D
                visible: globalSV.showScatter
                currentFrame: mainWindow.currentFrame
            }

            RootImprint {
                id: rootImprint1
                jointProvider: jointProvider3D
                visible: globalSV.showImprint
            }
        }

        Item {
            anchors.fill: parent
            focus: true

            WheelHandler {
                id: wheelHandler
                target: parent

                onWheel: (event) => {
                    var stepLinear = 0.2
                    var stepZoom = 0.05

                    if (event.modifiers & Qt.ControlModifier) {
                        // Ctrl + scroll → multiplicative zoom
                        cameraControls.cameraZ *= event.angleDelta.y > 0 ? (1 - stepZoom) : (1 + stepZoom)
                    } /*else {
                        // Plain scroll → linear Z movement
                        cameraControls.cameraZ -= event.angleDelta.y > 0 ? stepLinear : -stepLinear
                    }*/
                    cameraControls.cameraZ = Math.max(-5, Math.min(cameraControls.cameraZ, 20))

                    event.accepted = true
                }
            }
        }


        Item {
            anchors.fill: parent

            FrameSlider {
                id: frameSlider
                anchors.bottom: frameSlider2.top
                cameraControls: cameraControls
                jointProvider: jointProvider3D
            }

            FrameSlider {
                id: frameSlider2
                cameraControls: cameraControls
                jointProvider: jointProvider3D_2
            }


            SideControl {
                // anchors.bottom: frameSlider.top
                // anchors.left: parent.left
                cameraControls: cameraControls
            }

            HUD {
                anchors.right: parent.right
                anchors.rightMargin: parent ? parent.width * 0.05 : 50
                anchors.bottom: frameSlider.top
                anchors.bottomMargin: 20
                cameraControls: cameraControls
                height: 200
                width: 250
            }
        }

    }
}
