#include "SkeletonInstance.h"
#include "SkeletonPlayback.h"
#include "SkeletonViewModel.h"

SkeletonInstance::SkeletonInstance(MotionDataPtr motion, QObject* parent)
    : QObject(parent)
    , motion_(std::move(motion))
{
    Q_ASSERT(motion_);

    playback_ = new SkeletonPlayback(
        motion_->get_frame_count(),
        this
        );

    viewModel_ = new SkeletonViewModel(
        motion_.get(),
        playback_,
        this
        );
}

SkeletonViewModel* SkeletonInstance::viewModel() const {
    return viewModel_;
}

SkeletonPlayback* SkeletonInstance::playback() const {
    return playback_;
}

MotionDataPtr SkeletonInstance::motionData() const {
    return motion_;
}
