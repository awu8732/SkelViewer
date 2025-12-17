#include "JointProvider3D.h"
#include <QDebug>
#include <QElapsedTimer>

JointProvider3D::JointProvider3D(DataLoaderBinary* dlb, QObject* parent)
    : QObject(parent), dlb_(dlb)
{
    updateJoints(0);
}

Q_INVOKABLE void JointProvider3D::updateJoints(int frame)
{
    QElapsedTimer timer;
    timer.start();
    auto mat = dlb_->get_joints(frame);
    const int rowCount = mat.rows();

    // Resize only if needed (avoids reallocation every frame)
    if (joints_.size() != rowCount)
        joints_.resize(rowCount);

    // Write directly into existing QVector entries
    for (int i = 0; i < rowCount; ++i) {
        joints_[i].setX(mat(i, 0));
        joints_[i].setY(mat(i, 1));
        joints_[i].setZ(mat(i, 2));
    }

    emit jointsChanged();
    //qDebug() << "updateJoints time:" << timer.elapsed() << "ms";
}
