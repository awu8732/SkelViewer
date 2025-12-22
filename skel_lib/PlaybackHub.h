#pragma once
#include <QObject>

class PlaybackHub : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool playing READ playing WRITE setPlaying NOTIFY playingChanged)
    Q_PROPERTY(double playbackRate READ playbackRate WRITE setPlaybackRate NOTIFY playbackRateChanged)

public:
    static PlaybackHub* instance();

    bool playing() const;
    double playbackRate() const;
    void setPlaying(bool playing);
    void setPlaybackRate(double rate);

signals:
    void playRequested();
    void pauseRequested();
    void playingChanged(bool playing);
    void playbackRateChanged(double rate);

private:
    explicit PlaybackHub(QObject* parent = nullptr);

    bool playing_ = false;
    double playbackRate_ = 1.0;
};
