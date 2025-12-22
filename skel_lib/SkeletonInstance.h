#pragma once

#include <QObject>
#include "skel_lib/MotionTypes.h"
#include "SkeletonPlayback.h"
#include "SkeletonViewModel.h"

class SkeletonInstance : public QObject {
    Q_OBJECT
    Q_PROPERTY(SkeletonViewModel* viewModel READ viewModel CONSTANT)
    Q_PROPERTY(SkeletonPlayback* playback READ playback CONSTANT)

public:
    explicit SkeletonInstance(MotionDataPtr motion, QObject* parent = nullptr);

    SkeletonViewModel* viewModel() const;
    SkeletonPlayback* playback() const;
    MotionDataPtr motionData() const;

private:
    MotionDataPtr motion_;
    SkeletonPlayback* playback_ = nullptr;
    SkeletonViewModel* viewModel_ = nullptr;
};
