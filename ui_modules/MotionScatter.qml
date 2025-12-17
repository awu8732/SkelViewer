import QtQuick
import QtQuick3D
import "utility.js" as Utils

Node {
    id: motionScatterRoot

    property var jointProvider          // main provider
    property int n: 5                   // total skeletons (odd preferred)
    property int stepCount: 4           // frame step between skeletons
    property real jointRadius: 5e-4
    property real boneThickness: 1e-4
    property int currentFrame: 0

    // Preallocated cloned providers and skeleton models
    property var providerBuffer: []     // size n
    property var skeletonModels: []     // size n

    Connections {
        target: motionScatterRoot.jointProvider
        enabled: target !== null
        function onJointsChanged() { motionScatterRoot.updateBuffer(currentFrame) }
    }

    function updateBuffer(frame) {
        if (!jointProvider) return
        //console.log("MotionScatter: updating buffer for frame", frame)

        var half = Math.floor((n-1) / 2)
        for (var i = -half; i <= half; i++) {
            var bufferIndex = i + half
            var frameIndex = frame + i * stepCount
            if (frameIndex < 0) continue

            providerBuffer[bufferIndex].updateJoints(frameIndex)
            if (skeletonModels[bufferIndex].jointProvider !== providerBuffer[bufferIndex]) {
                skeletonModels[bufferIndex].jointProvider = providerBuffer[bufferIndex]
            }

        }
    }

    // Initialize buffer and skeletons once on completion
    Component.onCompleted: {
        if (!jointProvider) return
        console.log("MotionScatter: initializing", n, "skeletons")
        for (var i = 0; i < n; i++) {
            providerBuffer.push(jointProvider.clone())
        }
    }

    // Pool of SkeletonModels
    Node {
        id: skeletonRoot

        Instantiator {
            id: skeletonInst
            model: motionScatterRoot.n

            delegate: SkeletonModel {
                id: skeletonModel
                parent: skeletonRoot
                opacity: 0.15
                jointColor: Utils.viridisColor(index / Math.max(1, motionScatterRoot.n - 1))
                jointRadius: motionScatterRoot.jointRadius
                boneThickness: motionScatterRoot.boneThickness

                Component.onCompleted: {
                    skeletonModels[index] = skeletonModel
                }
            }
        }
    }

}
