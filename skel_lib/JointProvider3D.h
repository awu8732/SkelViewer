#pragma once

#include <QObject>
#include <QVector>
#include <QVector3D>
#include "skel_lib/DataLoaderBinary.h"
#include <iostream>

class JointProvider3D : public QObject {
    Q_OBJECT
    Q_PROPERTY(int frameCount READ frameCount CONSTANT)
    Q_PROPERTY(QVector<QVector3D> joints READ joints NOTIFY jointsChanged)

public:
    explicit JointProvider3D(DataLoaderBinary* dlb, QObject* parent = nullptr);

    Q_INVOKABLE QVector<QVector3D> joints() const { return joints_; }
    int frameCount() const { std::cout << dlb_->get_frame_count() << std::endl; return dlb_->get_frame_count(); }
    Q_INVOKABLE int getFPS() const {
        return dlb_->get_fps();
    }
    Q_INVOKABLE QVector3D getJoint(int index) const {
        if (index < 0 || index >= joints_.size())
            return QVector3D(0, 0, 0);
        return joints_[index];
    }
    Q_INVOKABLE QVector3D getVelocity(int index) const {
        Eigen::Vector3f v = dlb_->get_root_velocity_sg(index);
        return QVector3D(v.x(), v.y(), v.z());
    }
    Q_INVOKABLE QVector3D getAcceleration(int index) const {
        Eigen::Vector3f v = dlb_->get_root_acceleration_sg(index);
        return QVector3D(v.x(), v.y(), v.z());
    }
    Q_INVOKABLE QVector<QVector2D> getSMPLEdgesQML() const {
        QVector<QVector2D> qmlEdges;
        for (auto &e : dlb_->get_SMPL_edges()) {
            qmlEdges.push_back(QVector2D(float(e.first), float(e.second)));
        }
        return qmlEdges;
    }
    Q_INVOKABLE void updateJoints(int frame);
    Q_INVOKABLE JointProvider3D* clone() const {
        auto* jp = new JointProvider3D(dlb_, nullptr);
        jp->joints_ = joints_;
        return jp;
    }

signals:
    void jointsChanged();

private:
    DataLoaderBinary* dlb_;
    QVector<QVector3D> joints_;
};
