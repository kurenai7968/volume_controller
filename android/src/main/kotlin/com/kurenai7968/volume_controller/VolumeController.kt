package com.kurenai7968.volume_controller

import android.media.AudioManager
import kotlin.math.round

class VolumeController(private val audioManager: AudioManager){
    fun setVolumeByPercentage(volume:Double, showSystemUI:Boolean) {
        val clampedVolume = volume.coerceIn(0.0, 1.0)
        val maxVolume = audioManager.getStreamMaxVolume(AudioManager.STREAM_MUSIC)
        val adjustedVolume = (round(clampedVolume * maxVolume)).toInt()
        val flag = if (showSystemUI) AudioManager.FLAG_SHOW_UI else 0

        audioManager.setStreamVolume(AudioManager.STREAM_MUSIC, adjustedVolume, flag)
    }

    fun getVolume(): Double {
        return audioManager.getVolume()
    }
}
