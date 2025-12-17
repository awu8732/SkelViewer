#include "UtilityProvider.h"
#include <QtMath>

UtilityProvider::UtilityProvider(QObject* parent)
    : QObject(parent)
{
}

//
// ---------- Vector math ------------------------------------------------------
//

QQuaternion UtilityProvider::quaternionFromTo(const QVector3D& from,
                                              const QVector3D& to) const
{
    QVector3D f = from.normalized();
    QVector3D t = to.normalized();

    float dot = QVector3D::dotProduct(f, t);
    dot = clamp(dot, -1.0f, 1.0f);

    // Already aligned
    if (qFabs(dot - 1.0f) < 1e-6f)
        return QQuaternion(1, 0, 0, 0);

    // Opposite direction
    if (qFabs(dot + 1.0f) < 1e-6f)
    {
        QVector3D perp = QVector3D::crossProduct(QVector3D(1,0,0), f);
        if (perp.lengthSquared() < 1e-4f)
            perp = QVector3D::crossProduct(QVector3D(0,1,0), f);

        perp.normalize();
        return QQuaternion(0, perp.x(), perp.y(), perp.z());
    }

    // General case
    QVector3D axis = QVector3D::crossProduct(f, t).normalized();
    float angle = qAcos(dot);

    float half = angle * 0.5f;
    float s = qSin(half);

    return QQuaternion(qCos(half),
                       axis.x() * s,
                       axis.y() * s,
                       axis.z() * s);
}


QVector3D UtilityProvider::midpoint(const QVector3D& a,
                                    const QVector3D& b) const
{
    return QVector3D(
        (a.x() + b.x()) * 0.5f,
        (a.y() + b.y()) * 0.5f,
        (a.z() + b.z()) * 0.5f
        );
}

float UtilityProvider::length(const QVector3D& v) const
{
    return qSqrt(v.x()*v.x() + v.y()*v.y() + v.z()*v.z());
}

//
// ---------- Color maps -------------------------------------------------------
//

QColor UtilityProvider::magmaColor(float t) const
{
    t = clamp(t, 0.f, 1.f);

    float r = 0.987f * t + 0.002f*t*t - 0.004f*t*t*t;
    float g = 0.001f + 2.20f*t*t*t - 1.72f*t*t + 0.33f*t;
    float b = 0.138f + 1.47f*t*t - 1.57f*t + 0.64f*t;

    return QColor::fromRgbF(clamp(r,0,1), clamp(g,0,1), clamp(b,0,1), 1.0f);
}

QColor UtilityProvider::plasmaColor(float t) const
{
    t = clamp(t, 0.f, 1.f);

    const float c0[3] = {0.050383f, 0.029802f, 0.527975f};
    const float c1[3] = {2.404014f, 0.512255f, -4.425163f};
    const float c2[3] = {-4.01849f, 1.535701f, 2.659336f};
    const float c3[3] = {2.093394f, -2.339124f, 3.007644f};
    const float c4[3] = {-0.298995f, 0.627736f, -1.009949f};

    auto poly = [&](int i) {
        return c0[i] + t*(c1[i] + t*(c2[i] + t*(c3[i] + t*c4[i])));
    };

    return QColor::fromRgbF(clamp(poly(0),0,1),
                            clamp(poly(1),0,1),
                            clamp(poly(2),0,1),
                            1.0f);
}

QColor UtilityProvider::viridisColor(float t) const
{
    t = clamp(t, 0.f, 1.f);

    const float c0[3] = {0.277727f, 0.005407f, 0.334099f};
    const float c1[3] = {0.105094f, 1.404613f, 1.38459f};
    const float c2[3] = {0.065f, 0.708036f, 0.182466f};
    const float c3[3] = {0.019f, -1.316135f, -1.497103f};
    const float c4[3] = {0.f, 1.386688f, 0.734795f};

    auto poly = [&](int i) {
        return c0[i] + t*(c1[i] + t*(c2[i] + t*(c3[i] + t*c4[i])));
    };

    return QColor::fromRgbF(clamp(poly(0),0,1),
                            clamp(poly(1),0,1),
                            clamp(poly(2),0,1),
                            1.0f);
}
