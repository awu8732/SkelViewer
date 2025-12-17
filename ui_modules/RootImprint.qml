import QtQuick
import QtQuick3D
import "utility.js" as Utils

Node {
    id: imprintRoot
    property var jointProvider
    property int trailLength: 250          // Fixed pool size
    property real imprintRadius: 3e-4

    // Circular buffer
    property var posBuffer: []            // will be pre-sized
    property int writeIndex: 0            // circular write position
    property int length: 0                // how many points currently valid (<= trailLength)

    function recordFrame() {
        if (!jointProvider) return

        const p = jointProvider.getJoint(0)
        if (!p) return

        posBuffer[writeIndex] = Qt.vector3d(p.x, p.y, p.z)

        writeIndex = (writeIndex + 1) % trailLength
        if (length < trailLength)
            length++

        // Update positions & colors
        for (var i = 0; i < length; i++) {
            var bufIndex = (writeIndex - 1 - i + trailLength) % trailLength

            // Move sphere
            sphereModels[i].position = posBuffer[bufIndex]

            // Compute normalized age 0..1
            var age = i / (length - 1)
            sphereColors[i] = Utils.plasmaColor(age)
            sphereModels[i].materials[0].diffuseColor = sphereColors[i]
        }
    }

    Connections {
        target: imprintRoot.jointProvider
        enabled: target !== null
        function onJointsChanged() { imprintRoot.recordFrame() }
    }

    // preload posBuffer
    Component.onCompleted: {
        for (var i = 0; i < trailLength; i++)
            posBuffer.push(Qt.vector3d(0,0,0))
    }

    // pool of sphere objects
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

                // Start hidden until buffer fills
                visible: index < imprintRoot.length

                materials: DefaultMaterial {
                    //diffuseColor: imprintColor
                    cullMode: Material.NoCulling
                }

                Component.onCompleted: sphereModels[index] = sphere
            }
        }
    }

    // Store references to sphere Models for fast updates
    property var sphereModels: new Array(trailLength)
    property var sphereColors: new Array(trailLength)

    onTrailLengthChanged: {
        // 1. Rebuild posBuffer
        posBuffer = []
        for (var i = 0; i < trailLength; i++) {
            posBuffer.push(Qt.vector3d(0,0,0))
        }

        // 2. Reset writeIndex & length
        writeIndex = 0
        length = 0

        // 3. Resize model reference arrays
        sphereModels = new Array(trailLength)
        sphereColors = new Array(trailLength)

        // 4. Tell Instantiator to recreate spheres
        spheresInst.model = trailLength
    }

}
