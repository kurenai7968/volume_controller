package com.kurenai7968.volume_controller

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Context.AUDIO_SERVICE
import android.content.Intent
import android.content.IntentFilter
import android.media.AudioManager
import android.media.AudioManager.FLAG_SHOW_UI
import io.flutter.plugin.common.EventChannel
import kotlin.math.round


class VolumeObserver(private val context:Context){
    private var audioManager: AudioManager = context.getSystemService(AUDIO_SERVICE) as AudioManager

    fun setVolumeByPercentage(volume:Double, showSystemUI:Boolean) {
        var volumePercentage:Double = volume
        var _volume:Int = 0
        if (volume > 1) {
            volumePercentage = 1.0
        }
        if (volume < 0) {
            volumePercentage = 0.0
        }
        var maxVolume:Int = audioManager.getStreamMaxVolume(AudioManager.STREAM_MUSIC)
        _volume = (round(volumePercentage * maxVolume)).toInt()

        audioManager.setStreamVolume(AudioManager.STREAM_MUSIC, _volume, if (showSystemUI) FLAG_SHOW_UI else 0)
    }

    fun getVolume():Double {
        var currentVolume:Int = audioManager.getStreamVolume(AudioManager.STREAM_MUSIC)
        var maxVolume:Int = audioManager.getStreamMaxVolume(AudioManager.STREAM_MUSIC)
        return round((currentVolume / maxVolume.toDouble()) * 10000) / 10000
    }
}


class VolumeListener(private val context: Context): EventChannel.StreamHandler {
    private val VOLUME_CHANGED_ACTION = "android.media.VOLUME_CHANGED_ACTION"
    private lateinit var volumeBroadcastReceiver:VolumeBroadcastReceiver
    private lateinit var audioManager: AudioManager
    private var eventSink:EventChannel.EventSink? = null


    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
        audioManager = context.getSystemService(AUDIO_SERVICE) as AudioManager
        volumeBroadcastReceiver = VolumeBroadcastReceiver(eventSink)
        registerReceiver()
        eventSink?.success(volume())
    }

    override fun onCancel(arguments: Any?) {
        context.unregisterReceiver(volumeBroadcastReceiver)
        eventSink = null
    }

    private fun registerReceiver() {
        val filter = IntentFilter(VOLUME_CHANGED_ACTION)
        context.registerReceiver(volumeBroadcastReceiver, filter)
    }

    private fun volume():Double {
        var currentVolume:Int = audioManager.getStreamVolume(AudioManager.STREAM_MUSIC)
        var maxVolume:Int = audioManager.getStreamMaxVolume(AudioManager.STREAM_MUSIC)
        return round((currentVolume / maxVolume.toDouble()) * 10000) / 10000
    }
}

class VolumeBroadcastReceiver(private val events: EventChannel.EventSink?): BroadcastReceiver() {
    private lateinit var audioManager: AudioManager
    private var volumePercentage: Double = 0.0
    private var currentVolume:Int = 0
    private var maxVolume:Int = 0
    override fun onReceive(context: Context, intent: Intent?) {
        audioManager= context!!.getSystemService(AUDIO_SERVICE) as AudioManager;
        currentVolume = audioManager.getStreamVolume(AudioManager.STREAM_MUSIC)
        maxVolume = audioManager.getStreamMaxVolume(AudioManager.STREAM_MUSIC)
        volumePercentage = round((currentVolume / maxVolume.toDouble()) * 10000) / 10000
        events?.success(volumePercentage)
    }
}

