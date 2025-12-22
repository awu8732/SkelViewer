#include "SkeletonViewModel.h"

#include <QElapsedTimer>

SkeletonViewModel::SkeletonViewModel(const MotionData* motion, SkeletonPlayback* playback, QObject* parent)
    : QObject(parent), motion_(motion), playback_(playback)
{
    Q_ASSERT(motion_);
    Q_ASSERT(playback_);

    connect(
        playback_,
        &SkeletonPlayback::frameChanged,
        this,
        &SkeletonViewModel::onFrameChanged
        );

    updateJointsInternal(playback_->frame());
}

QVector<QVector3D> SkeletonViewModel::joints() const {
    return joints_;
}

int SkeletonViewModel::frameCount() const {
    return motion_->get_frame_count();
}

int SkeletonViewModel::fps() const {
    return motion_->get_fps();
}

QVector3D SkeletonViewModel::getJoint(int index) const {
    if (index < 0 || index >= joints_.size())
        return QVector3D();
    return joints_[index];
}

QVector3D SkeletonViewModel::getVelocity(int frame) const {
    const auto v = motion_->get_root_velocity_sg(frame);
    return QVector3D(v.x(), v.y(), v.z());
}

QVector3D SkeletonViewModel::getAcceleration(int frame) const {
    const auto v = motion_->get_root_acceleration_sg(frame);
    return QVector3D(v.x(), v.y(), v.z());
}

QVector<QVector2D> SkeletonViewModel::getSMPLEdgesQML() const {
    QVector<QVector2D> edges;
    for (const auto& e : motion_->get_SMPL_edges())
        edges.emplaceBack(float(e.first), float(e.second));
    return edges;
}

void SkeletonViewModel::onFrameChanged(int frame) {
    updateJointsInternal(frame);
}

void SkeletonViewModel::updateJointsInternal(int frame) {
    QElapsedTimer timer;
    timer.start();

    const auto mat = motion_->get_joints(frame);
    const int jointCount = mat.rows();

    if (joints_.size() != jointCount)
        joints_.resize(jointCount);

    for (int i = 0; i < jointCount; ++i) {
        joints_[i].setX(mat(i, 0));
        joints_[i].setY(mat(i, 1));
        joints_[i].setZ(mat(i, 2));
    }

    emit jointsChanged();
}
