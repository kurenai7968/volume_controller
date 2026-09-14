package com.kurenai7968.volume_controller

import android.media.AudioManager
import android.os.Build
import kotlin.test.Test
import kotlin.test.assertFalse
import kotlin.test.assertTrue
import org.mockito.Mockito

internal class VolumeControllerTest {
    @Test
    fun setMuteOnApi23UsesStreamMute() {
        val audioManager = Mockito.mock(AudioManager::class.java)
        Mockito.`when`(audioManager.isStreamMute(AudioManager.STREAM_MUSIC)).thenReturn(true)

        val controller = VolumeController(audioManager, sdkInt = Build.VERSION_CODES.M)
        controller.setMute(true, false)

        Mockito.verify(audioManager).adjustStreamVolume(
            AudioManager.STREAM_MUSIC,
            AudioManager.ADJUST_MUTE,
            0,
        )
        assertTrue(controller.isMute())
    }

    @Test
    fun setMuteOnLegacyApiSetsVolumeToZero() {
        val audioManager = Mockito.mock(AudioManager::class.java)
        Mockito.`when`(audioManager.getStreamMaxVolume(AudioManager.STREAM_MUSIC)).thenReturn(10)
        Mockito.`when`(audioManager.getStreamVolume(AudioManager.STREAM_MUSIC)).thenReturn(5)

        val controller = VolumeController(audioManager, sdkInt = Build.VERSION_CODES.LOLLIPOP)
        controller.setMute(true, false)

        Mockito.verify(audioManager).setStreamVolume(AudioManager.STREAM_MUSIC, 0, 0)
    }

    @Test
    fun isMuteOnLegacyApiUsesZeroVolume() {
        val audioManager = Mockito.mock(AudioManager::class.java)
        Mockito.`when`(audioManager.getStreamMaxVolume(AudioManager.STREAM_MUSIC)).thenReturn(10)
        Mockito.`when`(audioManager.getStreamVolume(AudioManager.STREAM_MUSIC)).thenReturn(0)

        val controller = VolumeController(audioManager, sdkInt = Build.VERSION_CODES.LOLLIPOP)

        assertTrue(controller.isMute())
        Mockito.`when`(audioManager.getStreamVolume(AudioManager.STREAM_MUSIC)).thenReturn(4)
        assertFalse(controller.isMute())
    }
}
