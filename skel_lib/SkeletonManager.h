#pragma once

#include <QQmlListProperty>
#include <QObject>
#include "skel_lib/SkeletonInstance.h"
#include "skel_lib/MotionTypes.h"

class SkeletonManager : public QObject {
    Q_OBJECT
    Q_PROPERTY(QQmlListProperty<SkeletonInstance> skeletons READ skeletons NOTIFY skeletonsChanged)

public:
    explicit SkeletonManager(QObject* parent = nullptr);

    Q_INVOKABLE void addSkeleton(MotionDataPtr motion);
    Q_INVOKABLE void duplicateSkeleton(int index);
    Q_INVOKABLE void removeSkeleton(int index);

    QQmlListProperty<SkeletonInstance> skeletons();

signals:
    void skeletonsChanged();

private:
    static qsizetype skeletonCount(QQmlListProperty<SkeletonInstance>* prop);
    static SkeletonInstance* skeletonAt(
        QQmlListProperty<SkeletonInstance>* prop,
        qsizetype index
        );
    static constexpr int kMaxSkeletons = 5;
    QVector<SkeletonInstance*> skeletons_;
};
