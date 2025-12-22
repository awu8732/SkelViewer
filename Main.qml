import QtQuick
import QtQuick.Controls
import QtQuick3D
import "ui_modules"

Window {
    id: mainWindow
    width: 800
    height: 600
    visible: true

    CameraControls {
        id: cameraControls
        anchors.fill: parent
        Component.onCompleted: cameraControls.forceActiveFocus()

        SceneView {
            id: globalSV
            cameraControls: cameraControls
            anchors.fill: parent

            property bool showImprint: false
            property bool showScatter: false

            property int imprintTrailLength: 250
            property int scatterCount: 5
            property int scatterStep: 2

            MenuBar {
                anchors.top: parent.top
                anchors.right: parent.right
                onResetCameraRequested: cameraControls.resetCamera()
                onToggleAxesRequested: {
                    globalSV.showAxes = !globalSV.showAxes
                }
            }

            Node {
                id: sceneRoot
                property var imprints: []

                Repeater3D {
                    model: skeletonManager.skeletons

                    delegate: Node {
                        id: skeletonNode

                        // The skeleton itself
                        SkeletonModel {
                            svm: model.viewModel
                            jointColor: "pink"
                        }

                        // Trail/Imprint for this skeleton
                        RootImprint {
                            svm: model.viewModel
                            frameSource: mainWindow
                            trailLength: globalSV.imprintTrailLength
                            visible: globalSV.showImprint
                        }

                        MotionScatter {
                            svm: model.viewModel
                            frameSource: mainWindow
                            n: globalSV.scatterCount
                            scatterStep: globalSV.scatterStep
                            visible: globalSV.showScatter
                        }
                    }
                }
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
                    }
                    cameraControls.cameraZ = Math.max(-10, Math.min(cameraControls.cameraZ, 20))

                    event.accepted = true
                }
            }
        }


        Item {
            anchors.fill: parent

            Column {
                id: frameSliderColumn
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottomMargin: 15
                spacing: 8
                width: parent.width

                Repeater {
                    model: skeletonManager.skeletons

                    delegate: Item {
                            width: parent.width
                            height: 60

                            FrameSlider {
                                anchors.fill: parent
                                playback: model.playback
                            }
                        }
                }
            }

            SideControl {
                cameraControls: cameraControls
            }

            HUD {
                anchors.right: parent.right
                anchors.rightMargin: parent ? parent.width * 0.05 : 50
                anchors.bottom: frameSliderColumn.top
                anchors.bottomMargin: 20
                cameraControls: cameraControls
                height: 200
                width: 250
            }
        }
    }
}
