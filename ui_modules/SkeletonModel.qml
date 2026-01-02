import QtQuick
import QtQuick3D
import Utils
import HMR_Trial_2 1.0

Node {
    id: skeletonModel
    property var svm  //SkeletonViewModel
    property bool enableBodyMesh: true
    property real jointRadius: 6e-4
    property real boneThickness: 2e-4
    property color jointColor: "purple"
    property color boneColor: "white"
    property var smplEdges: []

    // Local cache of joint positions (array of Qt.vector3d)
    property var jointsCache: null
    property bool useCachedJoints: false
    signal centerChanged(vector3d newCenter)

    // MAIN UPDATE FUNCTION (single-call for all updates)
    function updateAll() {
        if (!svm && !useCachedJoints)
            return;

        var sourceJoints = null;

        if (useCachedJoints && jointsCache) {
            sourceJoints = jointsCache;
        } else if (svm && svm.joints) {
            sourceJoints = svm.joints;
        }

        if (!sourceJoints || sourceJoints.length === 0)
            return;

        var jointCount = sourceJoints.length;

        // Ensure local cache is mutable
        if (!Array.isArray(jointsCache) || jointsCache.length !== jointCount) {
            jointsCache = new Array(jointCount);
        }

        for (var i = 0; i < jointCount; ++i) {
            var p = sourceJoints[i];
            jointsCache[i] = Qt.vector3d(p.x, p.y, p.z);
        }

        updateVisuals();
    }

    function updateVisuals() {

        // if (svm && svm.vertices && meshGeometry) {
        //     meshGeometry.updateVertices(svm.vertices);
        // }

        for (var j = 0; j < jointInstantiator.count; ++j) {
            var jointDelegate = jointInstantiator.objectAt(j);
            if (jointDelegate)
                jointDelegate.updateJoint(jointsCache[j]);
        }

        for (var e = 0; e < edgeInst.count; ++e) {
            var boneDelegate = edgeInst.objectAt(e);
            if (boneDelegate)
                boneDelegate.updateBone(jointsCache);
        }
    }

    function getCenterPosition() {
        if (!jointsCache || jointsCache.length === 0)
            return Qt.vector3d(0, 0, 0);

        var cx = 0, cy = 0, cz = 0;
        var n = jointsCache.length;

        for (var i = 0; i < n; ++i) {
            var p = jointsCache[i];
            if (p) {
                cx += p.x;
                cy += p.y;
                cz += p.z;
            }
        }

        return Qt.vector3d(cx / n, cy / n, cz / n);
    }

    Connections {
        id: svmConnection
        target: null

        function onJointsChanged() {
            // const now = Date.now()
            // const dt = now - lastTime
            // lastTime = now

            //console.log("Frame time:", dt, "ms - FPS:", Math.round(1000/dt))
            skeletonModel.updateAll();
        }
    }

    //
    // 1. JOINTS
    //
    Node {
        id: jointRoot

        Instantiator {
            id: jointInstantiator
            // keep existing behavior: model is provider.joints.length if available
            model: svm && svm.joints ? svm.joints.length : 0

            delegate: Node {
                id: jointDelegate
                parent: jointRoot

                Model {
                    id: jointSphere
                    source: "#Sphere"
                    scale: Qt.vector3d(jointRadius, jointRadius, jointRadius)
                    materials: DefaultMaterial {
                        diffuseColor: jointColor
                        cullMode: Material.NoCulling
                    }
                }

                // updateJoint receives a Qt.vector3d (or undefined)
                function updateJoint(pos) {
                    if (pos)
                        jointSphere.position = pos;
                }

                Component.onCompleted: {
                    // initialize with whatever provider currently has
                    if (svm)
                        updateJoint(svm.getJoint(index));
                }
            }
        }
    }

    //
    // 2. BONES
    //
    Node {
        id: boneRoot

        Instantiator {
            id: edgeInst
            model: smplEdges ? smplEdges.length : 0

            delegate: Node {
                id: boneDelegate
                parent: boneRoot

                // store indices for quick access
                property int a: (smplEdges && smplEdges[index]) ? smplEdges[index].x : -1
                property int b: (smplEdges && smplEdges[index]) ? smplEdges[index].y : -1

                Model {
                    id: boneModel
                    visible: false
                    source: "#Cylinder"
                    materials: DefaultMaterial {
                        diffuseColor: boneColor
                        cullMode: Material.NoCulling
                    }
                }

                // updateBone gets the full joints cache (array of Qt.vector3d)
                function updateBone(joints) {
                    if (!joints || a < 0 || b < 0) return;

                    var pA = joints[a];
                    var pB = joints[b];
                    if (a < 0 || b < 0 || a >= joints.length || b >= joints.length) {
                        boneModel.visible = false;
                        return;
                    }

                    // compute diff components (avoid extra allocations where possible)
                    var dx = pB.x - pA.x;
                    var dy = pB.y - pA.y;
                    var dz = pB.z - pA.z;
                    // compute length directly to avoid constructing temporary vector for tiny checks
                    var length = Math.sqrt(dx*dx + dy*dy + dz*dz);
                    if (length < 0.001) {
                        boneModel.visible = false; return;
                    } else {
                        boneModel.visible = true;
                    }
                    // midpoint: use UtilityProvider.midpoint (C++)
                    var mid = UtilityProvider.midpoint(
                                Qt.vector3d(pA.x, pA.y, pA.z), Qt.vector3d(pB.x, pB.y, pB.z)
                    );
                    // rotation: from up (0,1,0) to diff vector
                    var diffVec = Qt.vector3d(dx, dy, dz);
                    var rot = UtilityProvider.quaternionFromTo(Qt.vector3d(0,1,0), diffVec);
                    boneModel.position = mid;

                    // NOTE: cylinder assumed aligned along Y; scale Y to length/meshUnit (adjust divisor if mesh unit differs)
                    boneModel.scale = Qt.vector3d(boneThickness, length / 100.0, boneThickness);
                    boneModel.rotation = rot;
                }

                Component.onCompleted: {
                    // attempt an initial update using current provider state
                    if (svm) {
                        var localCache = [];
                        // small, local fetch to update this bone once
                        var pA = svm.getJoint(a);
                        var pB = svm.getJoint(b);
                        if (pA && pB) {
                            updateBone([Qt.vector3d(pA.x, pA.y, pA.z), Qt.vector3d(pB.x, pB.y, pB.z)]);
                        }
                    }
                }
            }
        }

        Model {
            id: bodyMesh
            visible: true1

            geometry: SkeletonMeshGeometry {
                id: meshGeometry
            }

            materials: [
                DefaultMaterial {
                    diffuseColor: "#c8c8c8"
                    lighting: DefaultMaterial.FragmentLighting
                    cullMode: Material.NoCulling
                }
            ]
        }

    }

    // When provider changes: set the connection target safely, load edges, and prime update
    onSvmChanged: {
        svmConnection.target = svm ? svm : null;

        if (svm) {
            // load edges (cached list) once
            smplEdges = svm.getSMPLEdgesQML();

            // initialize joints cache and update visuals
            updateAll();
        } else {
            // clear
            smplEdges = [];
            jointsCache = [];
            // update instantiator models so delegates are removed if needed
            jointInstantiator.model = 0;
            edgeInst.model = 0;
        }
    }
}
