package com.kurenai7968.volume_controller

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.database.ContentObserver
import android.media.AudioManager
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import io.flutter.plugin.common.EventChannel

class VolumeListener(
    private val context: Context,
    private val audioManager: AudioManager,
) : EventChannel.StreamHandler {
    private var volumeBroadcastReceiver: VolumeBroadcastReceiver? = null
    private var volumeContentObserver: VolumeContentObserver? = null
    private var lastEmittedVolume: Double? = null

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        val args = arguments as? Map<*, *>
        val fetchInitialVolume = args?.get(EventArgument.FETCH_INITIAL_VOLUME) as? Boolean ?: false

        unregister()

        val emitter = VolumeEmitter(audioManager) { volume, force ->
            if (force || lastEmittedVolume != volume) {
                lastEmittedVolume = volume
                events?.success(volume)
            }
        }

        volumeBroadcastReceiver = VolumeBroadcastReceiver(emitter)
        registerVolumeReceiver(volumeBroadcastReceiver!!)

        volumeContentObserver = VolumeContentObserver(emitter)
        context.contentResolver.registerContentObserver(
            Settings.System.CONTENT_URI,
            true,
            volumeContentObserver!!,
        )

        if (fetchInitialVolume) {
            emitter.emit(force = true)
        }
    }

    override fun onCancel(arguments: Any?) {
        unregister()
        lastEmittedVolume = null
    }

    private fun registerVolumeReceiver(receiver: VolumeBroadcastReceiver) {
        val filter = IntentFilter(VOLUME_CHANGED_ACTION)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            context.registerReceiver(receiver, filter, Context.RECEIVER_EXPORTED)
        } else {
            @Suppress("UnspecifiedRegisterReceiverFlag")
            context.registerReceiver(receiver, filter)
        }
    }

    private fun unregister() {
        volumeBroadcastReceiver?.let {
            try {
                context.unregisterReceiver(it)
            } catch (_: IllegalArgumentException) {
                // Receiver was not registered.
            }
            volumeBroadcastReceiver = null
        }
        volumeContentObserver?.let {
            context.contentResolver.unregisterContentObserver(it)
            volumeContentObserver = null
        }
    }
}

internal class VolumeEmitter(
    private val audioManager: AudioManager,
    private val onEmit: (volume: Double, force: Boolean) -> Unit,
) {
    fun emit(force: Boolean = false) {
        onEmit(audioManager.getVolume(), force)
    }
}

internal class VolumeBroadcastReceiver(
    private val emitter: VolumeEmitter,
) : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent?) {
        if (intent?.action != VOLUME_CHANGED_ACTION) {
            return
        }

        val streamType = intent.getIntExtra(EXTRA_VOLUME_STREAM_TYPE, AudioManager.STREAM_MUSIC)
        if (streamType != AudioManager.STREAM_MUSIC) {
            return
        }

        emitter.emit()
    }
}

internal class VolumeContentObserver(
    private val emitter: VolumeEmitter,
) : ContentObserver(Handler(Looper.getMainLooper())) {
    override fun onChange(selfChange: Boolean) {
        emitter.emit()
    }
}
