function quaternionFromTo(from, to) {
    var f = Qt.vector3d(from.x, from.y, from.z).normalized();
    var t = Qt.vector3d(to.x, to.y, to.z).normalized();

    var dot = f.x * t.x + f.y * t.y + f.z * t.z;
    dot = Math.max(-1, Math.min(1, dot));

    // Already aligned
    if (Math.abs(dot - 1) < 0.000001)
        return Qt.quaternion(1, 0, 0, 0);

    // Opposite direction → pick perpendicular axis
    if (Math.abs(dot + 1) < 0.000001) {
        var perp = Qt.vector3d(1, 0, 0).crossProduct(f);
        if (perp.length() < 0.0001)
            perp = Qt.vector3d(0, 1, 0).crossProduct(f);
        perp = perp.normalized();
        return Qt.quaternion(0, perp.x, perp.y, perp.z);
    }

    // General case
    var axis = f.crossProduct(t).normalized();
    var angle = Math.acos(dot);
    var half = angle / 2;
    var s = Math.sin(half);

    return Qt.quaternion(
        Math.cos(half),
        axis.x * s,
        axis.y * s,
        axis.z * s
    );
}

function midpoint_v(a, b) {
    return Qt.vector3d(
        (a.x + b.x)*0.5,
        (a.y + b.y)*0.5,
        (a.z + b.z)*0.5
    );
}

function length_v(v) {
    return Math.sqrt(v.x*v.x + v.y*v.y + v.z*v.z);
}

function magmaColor(t) {
    // Clamp t 0..1
    t = Math.max(0, Math.min(1, t));

    // Approximate magma colormap (from matplotlib)
    // These polynomials approximate the R,G,B curves.
    var r = 0.987 * t + 0.002 * t*t - 0.004 * t*t*t;
    var g = 0.001 + 2.20*t*t*t - 1.72*t*t + 0.33*t;
    var b = 0.138 + 1.47*t*t - 1.57*t + 0.64*t;

    return Qt.rgba(r, g, b, 1.0);
}

function plasmaColor(t) {
    // Clamp input 0..1
    t = Math.max(0, Math.min(1, t));

    // Polynomial coefficients (R, G, B)
    // Fitted from Matplotlib plasma LUT
    const c0 = [0.050383, 0.029802, 0.527975];
    const c1 = [2.404014, 0.512255, -4.425163];
    const c2 = [ -4.018490, 1.535701, 2.659336];
    const c3 = [ 2.093394, -2.339124, 3.007644];
    const c4 = [ -0.298995, 0.627736, -1.009949];

    // Horner form evaluation
    const r = c0[0] + t*(c1[0] + t*(c2[0] + t*(c3[0] + t*c4[0])));
    const g = c0[1] + t*(c1[1] + t*(c2[1] + t*(c3[1] + t*c4[1])));
    const b = c0[2] + t*(c1[2] + t*(c2[2] + t*(c3[2] + t*c4[2])));

    return Qt.rgba(
        Math.max(0, Math.min(1, r)),
        Math.max(0, Math.min(1, g)),
        Math.max(0, Math.min(1, b)),
        1.0
    );
}


function viridisColor(t) {
    // Clamp to [0,1]
    t = Math.max(0, Math.min(1, t));

    // Polynomial coefficients fitted to matplotlib's viridis
    // Source: https://github.com/BIDS/colormap/blob/master/colormaps.py (adapted)
    const c0 = [0.277727, 0.005407, 0.334099];
    const c1 = [0.105094, 1.404613, 1.384590];
    const c2 = [0.065000, 0.708036, 0.182466];
    const c3 = [0.019000, -1.316135, -1.497103];
    const c4 = [0.000000, 1.386688, 0.734795];

    // Horner evaluation
    const r = c0[0] + t*(c1[0] + t*(c2[0] + t*(c3[0] + t*c4[0])));
    const g = c0[1] + t*(c1[1] + t*(c2[1] + t*(c3[1] + t*c4[1])));
    const b = c0[2] + t*(c1[2] + t*(c2[2] + t*(c3[2] + t*c4[2])));

    return Qt.rgba(
        Math.max(0, Math.min(1, r)),
        Math.max(0, Math.min(1, g)),
        Math.max(0, Math.min(1, b)),
        1.0
    );
}

