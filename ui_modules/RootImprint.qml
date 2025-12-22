import QtQuick
import QtQuick3D
import "utility.js" as Utils

Node {
    id: imprintRoot

    property var svm
    property var frameSource
    property int trailLength: 250          // Fixed pool size
    property real imprintRadius: 3e-4

    // --- Circular buffer ---
    property var posBuffer: []             // pre-sized
    property int writeIndex: 0              // circular write position
    property int length: 0                  // how many points currently valid

    function resetBuffer() {
        writeIndex = 0
        length = 0
    }

    function recordFrame() {
        if (!svm)
            return

        const p = svm.getJoint(0)
        if (!p)
            return

        posBuffer[writeIndex] = Qt.vector3d(p.x, p.y, p.z)

        writeIndex = (writeIndex + 1) % trailLength
        if (length < trailLength)
            length++

        // Update positions & colors
        for (var i = 0; i < length; i++) {
            var bufIndex = (writeIndex - 1 - i + trailLength) % trailLength
            var sphere = sphereModels[i]
            if (!sphere)
                continue

            sphere.position = posBuffer[bufIndex]

            // normalized age [0..1], guarded
            var age = (length > 1) ? i / (length - 1) : 0
            var color = Utils.plasmaColor(age)
            sphere.materials[0].diffuseColor = color
            sphereColors[i] = color
        }
    }

    // --- Safe connection to SkeletonViewModel ---
    Connections {
        id: jointConn
        target: svm
        enabled: svm !== null

        function onJointsChanged() {
            imprintRoot.recordFrame()
        }
    }

    // --- Preload buffer ---
    Component.onCompleted: {
        posBuffer.length = trailLength
        for (var i = 0; i < trailLength; i++)
            posBuffer[i] = Qt.vector3d(0, 0, 0)
    }

    // --- Pool of sphere objects ---
    Node {
        id: spheresRoot

        Instantiator {
            id: spheresInst
            model: trailLength

            delegate: Model {
                id: sphere
                parent: spheresRoot
                source: "#Sphere"
                scale: Qt.vector3d(imprintRadius, imprintRadius, imprintRadius)
                visible: false

                materials: DefaultMaterial {
                    cullMode: Material.NoCulling
                }

                Component.onCompleted: {
                    sphereModels[index] = sphere
                }
            }
        }
    }

    // --- Fast access arrays ---
    property var sphereModels: new Array(trailLength)
    property var sphereColors: new Array(trailLength)

    // --- Keep visibility in sync with buffer length ---
    onLengthChanged: {
        for (var i = 0; i < trailLength; i++) {
            if (sphereModels[i])
                sphereModels[i].visible = i < length
        }
    }

    // --- Handle trailLength changes ---
    onTrailLengthChanged: {
        // rebuild buffer
        posBuffer = new Array(trailLength)
        for (var i = 0; i < trailLength; i++)
            posBuffer[i] = Qt.vector3d(0, 0, 0)

        // reset state
        resetBuffer()

        // resize references
        sphereModels = new Array(trailLength)
        sphereColors = new Array(trailLength)

        // recreate spheres
        spheresInst.model = trailLength
    }

    // --- Reset when skeleton changes ---
    onSvmChanged: {
        resetBuffer()
    }
}
