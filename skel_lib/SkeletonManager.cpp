#include "SkeletonManager.h"

SkeletonManager::SkeletonManager(QObject* parent)
    : QObject(parent)
{
}

QQmlListProperty<SkeletonInstance> SkeletonManager::skeletons()
{
    return QQmlListProperty<SkeletonInstance>(
        this,
        this,
        &SkeletonManager::skeletonCount,
        &SkeletonManager::skeletonAt
        );
}

qsizetype SkeletonManager::skeletonCount(
    QQmlListProperty<SkeletonInstance>* prop)
{
    auto self = static_cast<SkeletonManager*>(prop->data);
    return self->skeletons_.size();
}

SkeletonInstance* SkeletonManager::skeletonAt(
    QQmlListProperty<SkeletonInstance>* prop,
    qsizetype index)
{
    auto self = static_cast<SkeletonManager*>(prop->data);
    return self->skeletons_.at(index);
}

void SkeletonManager::addSkeleton(MotionDataPtr motion)
{
    if (!motion)
        return;

    if (skeletons_.size() >= kMaxSkeletons)
        return;

    auto* instance = new SkeletonInstance(motion, this);
    skeletons_.push_back(instance);

    emit skeletonsChanged();
}

void SkeletonManager::duplicateSkeleton(int index)
{
    if (index < 0 || index >= skeletons_.size())
        return;

    if (skeletons_.size() >= kMaxSkeletons)
        return;

    MotionDataPtr motion = skeletons_[index]->motionData();
    auto* duplicate = new SkeletonInstance(motion, this);

    skeletons_.push_back(duplicate);
    emit skeletonsChanged();
}

void SkeletonManager::removeSkeleton(int index)
{
    if (index < 0 || index >= skeletons_.size())
        return;

    SkeletonInstance* inst = skeletons_.takeAt(index);
    inst->deleteLater();

    emit skeletonsChanged();
}
