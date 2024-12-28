package com.kurenai7968.volume_controller

import android.media.AudioManager

internal fun AudioManager.getVolume(): Double {
    val currentVolume = getStreamVolume(AudioManager.STREAM_MUSIC)
    val maxVolume = getStreamMaxVolume(AudioManager.STREAM_MUSIC)

    return (currentVolume / maxVolume.toDouble()).coerceIn(0.0, 1.0)
}