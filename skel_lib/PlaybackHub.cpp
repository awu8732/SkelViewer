#include "PlaybackHub.h"

PlaybackHub* PlaybackHub::instance()
{
    static PlaybackHub hub;
    return &hub;
}

PlaybackHub::PlaybackHub(QObject* parent)
    : QObject(parent)
{
}

bool PlaybackHub::playing() const
{
    return playing_;
}

double PlaybackHub::playbackRate() const
{
    return playbackRate_;
}

void PlaybackHub::setPlaying(bool p)
{
    if (playing_ == p)
        return;

    playing_ = p;

    if (playing_) {
        emit playRequested();
    } else {
        emit pauseRequested();
    }

    emit playingChanged(playing_);
}


void PlaybackHub::setPlaybackRate(double rate)
{
    if (qFuzzyCompare(playbackRate_, rate))
        return;

    playbackRate_ = rate;
    emit playbackRateChanged(playbackRate_);
}
