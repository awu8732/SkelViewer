#pragma once

#include <QObject>
#include <QVector3D>
#include <QQuaternion>
#include <QColor>

class UtilityProvider : public QObject
{
    Q_OBJECT

public:
    explicit UtilityProvider(QObject* parent = nullptr);

    // --- Vector math ---
    Q_INVOKABLE QQuaternion quaternionFromTo(const QVector3D& from,
                                             const QVector3D& to) const;

    Q_INVOKABLE QVector3D midpoint(const QVector3D& a,
                                   const QVector3D& b) const;

    Q_INVOKABLE float length(const QVector3D& v) const;

    // --- Colormap methods ---
    Q_INVOKABLE QColor magmaColor(float t) const;
    Q_INVOKABLE QColor plasmaColor(float t) const;
    Q_INVOKABLE QColor viridisColor(float t) const;

private:
    float clamp(float v, float lo, float hi) const {
        return std::max(lo, std::min(v, hi));
    }
};
