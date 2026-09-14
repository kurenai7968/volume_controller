package com.kurenai7968.volume_controller

import android.media.AudioManager
import android.os.Build
import kotlin.math.round

class VolumeController(
    private val audioManager: AudioManager,
    private val sdkInt: Int = Build.VERSION.SDK_INT,
) {
    private var tempMuteVolume: Double? = null

    fun setVolume(volume: Double, showSystemUI: Boolean) {
        val clampedVolume = volume.coerceIn(0.0, 1.0)
        val maxVolume = audioManager.getStreamMaxVolume(AudioManager.STREAM_MUSIC)
        val adjustedVolume = (round(clampedVolume * maxVolume)).toInt()
        val flag = uiFlag(showSystemUI)

        if (clampedVolume != 0.0) {
            tempMuteVolume = null
        }

        audioManager.setStreamVolume(AudioManager.STREAM_MUSIC, adjustedVolume, flag)
    }

    fun getVolume(): Double {
        return audioManager.getVolume()
    }

    fun isMute(): Boolean {
        if (supportsStreamMute()) {
            return audioManager.isStreamMute(AudioManager.STREAM_MUSIC)
        }
        return getVolume() == 0.0
    }

    fun setMute(isMute: Boolean, showSystemUI: Boolean) {
        val flag = uiFlag(showSystemUI)
        if (supportsStreamMute()) {
            val direction = if (isMute) {
                AudioManager.ADJUST_MUTE
            } else {
                AudioManager.ADJUST_UNMUTE
            }
            audioManager.adjustStreamVolume(AudioManager.STREAM_MUSIC, direction, flag)
            return
        }

        if (isMute) {
            tempMuteVolume = getVolume()
            setVolume(0.0, showSystemUI)
        } else {
            val previousVolume = tempMuteVolume ?: return
            setVolume(previousVolume, showSystemUI)
            tempMuteVolume = null
        }
    }

    private fun supportsStreamMute(): Boolean {
        return sdkInt >= Build.VERSION_CODES.M
    }

    private fun uiFlag(showSystemUI: Boolean): Int {
        return if (showSystemUI) AudioManager.FLAG_SHOW_UI else 0
    }
}
