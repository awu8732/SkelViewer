// PlaybackHub.qml
pragma Singleton
import QtQuick 2.15

QtObject {
    id: hub

    property bool playing: false
    property double playbackRate: 1.0

    signal playRequested()
    signal pauseRequested()
    signal playbackRateChanged(double rate)

    function play() {
        if (playing)
            return
        playing = true
        playRequested()
    }

    function pause() {
        if (!playing)
            return
        playing = false
        pauseRequested()
    }

    function setPlaybackRate(rate) {
        if (playbackRate === rate)
            return
        playbackRate = rate
        playbackRateChanged(rate)
    }
}
