#pragma once

#include <QObject>
#include <QTimer>

class SkeletonPlayback : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int frame READ frame NOTIFY frameChanged)
    Q_PROPERTY(int maxFrames READ maxFrames CONSTANT)
    Q_PROPERTY(bool playing READ playing WRITE setPlaying NOTIFY playingChanged)

public:
    explicit SkeletonPlayback(int maxFrames, QObject* parent = nullptr);

    int frame() const;
    int maxFrames() const;
    double playbackRate() const;
    bool playing() const;

public slots:
    void setFrame(int frame);
    void setPlaybackRate(double rate);
    void setPlaying(bool playing);
    void play();
    void pause();

signals:
    void frameChanged(int frame);
    void playingChanged(bool playing);
    void playbackRateChanged(double rate);

private slots:
    void advanceFrame();

private:
    int frame_ = 0;
    int maxFrames_ = 0;
    double playbackRate_ = 1.0;
    bool playing_ = false;

    QTimer timer_;
};
