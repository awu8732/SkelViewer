import QtQuick
import QtQuick3D
import "utility.js" as Utils

Node {
    id: motionScatterRoot

    /* --- Inputs --- */
    property var svm
    property var frameSource

    /* --- Scatter parameters --- */
    property int n: 5                     // number of ghosts
    property int scatterStep: 2            // record every N frames
    property real jointRadius: 5e-4
    property real boneThickness: 1e-4

    /* --- Circular buffer state --- */
    property var jointsBuffer: []          // Array<jointSet>
    property int writeIndex: 0
    property int length: 0
    property int frameCounter: 0
    property int cursor: 0   // which skeleton model is "newest"

    /* --- Skeleton model pool --- */
    property var skeletonModels: new Array(n)

    /* ------------------ Buffer logic ------------------ */

    function recordFrame() {
        if (!svm)
            return

        frameCounter++
        if (frameCounter % scatterStep !== 0)
            return

        const src = svm.joints
        if (!src)
            return

        // clone into JS array
        var snapshot = new Array(src.length)
        for (var i = 0; i < src.length; ++i) {
            var p = src[i]
            snapshot[i] = Qt.vector3d(p.x, p.y, p.z)
        }

        jointsBuffer[cursor] = snapshot

        // advance cursor (newest position)
        cursor = (cursor + 1) % n
        if (length < n)
            length++

        updateSkeletons()
    }

    function resetBuffer() {
        // Preserve existing data if possible
        if (length === 0 || jointsBuffer.length === 0) {
            jointsBuffer = new Array(n)
            writeIndex = 0
            cursor = 0
            length = 0
            return
        }

        // Extract poses in newest → oldest order
        var preserved = []
        var maxKeep = Math.min(length, n)

        for (var age = 0; age < maxKeep; ++age) {
            var idx = (cursor - 1 - age + jointsBuffer.length) % jointsBuffer.length
            var joints = jointsBuffer[idx]
            if (joints)
                preserved.push(joints)
        }

        // Rebuild buffer with new size
        jointsBuffer = new Array(n)

        // Write back so that cursor points to "next write"
        for (var i = 0; i < preserved.length; ++i) {
            jointsBuffer[i] = preserved[preserved.length - 1 - i]
        }

        length = preserved.length
        cursor = length % n
        writeIndex = cursor

        updateSkeletons()
    }



    function updateSkeletons() {
        for (var age = 0; age < length; ++age) {
            // newest = cursor - 1
            var dataIndex =
                (cursor - 1 - age + n) % n

            // model slot matches age directly
            var model = skeletonModels[age]
            var joints = jointsBuffer[dataIndex]

            if (!model || !joints)
                continue

            model.useCachedJoints = true
            model.jointsCache = joints
            model.updateAll()
            model.visible = true

            var denom = Math.max(1, n - 1)
            var t = age / denom
            model.opacity = 1.0 - Utils.smoothstep(t)
        }

        // hide unused ghosts
        for (var i = length; i < n; ++i) {
            if (skeletonModels[i])
                skeletonModels[i].visible = false
        }
    }

    /* ------------------ Connections ------------------ */

    Connections {
        target: svm
        enabled: svm !== null

        function onJointsChanged() {
            recordFrame()
        }
    }

    /* ------------------ Lifecycle ------------------ */

    Component.onCompleted: {
        jointsBuffer = new Array(n)
    }

    onNChanged: {
        skeletonModels = new Array(n)
        resetBuffer()
        skeletonInst.model = n
    }

    onSvmChanged: {
        resetBuffer()
    }

    /* ------------------ Skeleton pool ------------------ */

    Node {
        Repeater3D {
            id: skeletonInst
            model: motionScatterRoot.n

            delegate: SkeletonModel {
                id: skeletonModel

                svm: motionScatterRoot.svm
                enableBodyMesh: false
                visible: false
                opacity: 0.15

                jointRadius: motionScatterRoot.jointRadius
                boneThickness: motionScatterRoot.boneThickness

                jointColor: 'red'/*Utils.viridisColor(
                    index / Math.max(1, motionScatterRoot.n - 1)
                )*/

                Component.onCompleted: {
                    skeletonModels[index] = skeletonModel
                }
            }
        }
    }
}
