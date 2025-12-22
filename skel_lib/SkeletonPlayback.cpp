#include "SkeletonInstance.h"
#include "SkeletonPlayback.h"
#include "PlaybackHub.h"

SkeletonPlayback::SkeletonPlayback(int maxFrames, QObject* parent)
    : QObject(parent)
    , frame_(0)
    , playing_(false)
    , maxFrames_(maxFrames)
{
    // Set interval w config fps
    timer_.setParent(this);

    auto instance = qobject_cast<SkeletonInstance*>(parent);
    int cfg_fps = instance ? instance->motionData()->get_fps() : 60;
    timer_.setInterval(1000 / cfg_fps);
    setPlaybackRate(1.0);

    connect(&timer_, &QTimer::timeout,
            this, &SkeletonPlayback::advanceFrame);

    // Subscribe to global playback hub
    auto* hub = PlaybackHub::instance();

    connect(hub, &PlaybackHub::playRequested,
            this, &SkeletonPlayback::play);

    connect(hub, &PlaybackHub::pauseRequested,
            this, &SkeletonPlayback::pause);

    connect(hub, &PlaybackHub::playbackRateChanged,
            this, &SkeletonPlayback::setPlaybackRate);
}

int SkeletonPlayback::frame() const
{
    return frame_;
}

int SkeletonPlayback::maxFrames() const
{
    return maxFrames_;
}

double SkeletonPlayback::playbackRate() const
{
    return playbackRate_;
}

bool SkeletonPlayback::playing() const
{
    return playing_;
}

void SkeletonPlayback::setPlaying(bool p)
{
    if (playing_ == p)
        return;

    playing_ = p;

    if (playing_)
        timer_.start();
    else
        timer_.stop();

    emit playingChanged(playing_);
}

void SkeletonPlayback::play()
{
    setPlaying(true);
}

void SkeletonPlayback::pause()
{
    setPlaying(false);
}

void SkeletonPlayback::advanceFrame()
{
    if (!playing_)
        return;

    if (frame_ + 1 >= maxFrames_) frame_ = -1;

    frame_++;
    emit frameChanged(frame_);
}

void SkeletonPlayback::setFrame(int f)
{
    if (f < 0)
        f = 0;
    else if (f >= maxFrames_)
        f = maxFrames_ - 1;

    if (frame_ == f)
        return;

    frame_ = f;
    emit frameChanged(frame_);
}

void SkeletonPlayback::setPlaybackRate(double rate)
{
    if (rate <= 0.0)
        rate = 0.01; // avoid freeze / divide-by-zero

    if (qFuzzyCompare(playbackRate_, rate))
        return;

    playbackRate_ = rate;

    // Determine base FPS from parent instance
    int baseFps = 60;
    if (auto instance = qobject_cast<SkeletonInstance*>(parent()))
    {
        baseFps = instance->motionData()->get_fps();
    }

    // Adjust timer interval based on FPS and playbackRate
    int intervalMs = int((1000.0 / baseFps) / playbackRate_);
    timer_.setInterval(qMax(1, intervalMs));

    emit playbackRateChanged(playbackRate_);
}
