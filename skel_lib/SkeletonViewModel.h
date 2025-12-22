#pragma once

#include <QObject>
#include <QVector>
#include <QVector3D>

#include "skel_lib/MotionData.h"
#include "skel_lib/SkeletonPlayback.h"

class SkeletonViewModel : public QObject {
    Q_OBJECT

    Q_PROPERTY(int frameCount READ frameCount CONSTANT)
    Q_PROPERTY(QVector<QVector3D> joints READ joints NOTIFY jointsChanged)

public:
    explicit SkeletonViewModel(
        const MotionData* motion,
        SkeletonPlayback* playback,
        QObject* parent = nullptr
        );

    // --- data access ---
    QVector<QVector3D> joints() const;
    int frameCount() const;
    int fps() const;

    Q_INVOKABLE QVector3D getJoint(int index) const;
    Q_INVOKABLE QVector3D getVelocity(int frame) const;
    Q_INVOKABLE QVector3D getAcceleration(int frame) const;
    Q_INVOKABLE QVector<QVector2D> getSMPLEdgesQML() const;

signals:
    void jointsChanged();

private slots:
    void onFrameChanged(int frame);

private:
    void updateJointsInternal(int frame);

    const MotionData* motion_;                  // read-only
    SkeletonPlayback* playback_;          // not owned
    QVector<QVector3D> joints_;
};
