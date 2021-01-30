package com.kurenai7968.volume_controller

import android.content.Context
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class VolumeControllerPlugin: FlutterPlugin, MethodCallHandler {
  private val CHANNEL = "com.kurenai7968.volume_controller."
  private lateinit var context:Context
  private lateinit var volumeObserver: VolumeObserver
  private lateinit var methodChannel:MethodChannel
  private lateinit var volumeListenerEventChannel: EventChannel
  private lateinit var volumeListenerStreamHandler: VolumeListener



  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    context = flutterPluginBinding.applicationContext
    volumeObserver = VolumeObserver(context)

    volumeListenerEventChannel = EventChannel(flutterPluginBinding.binaryMessenger, CHANNEL + "volume_listener_event")
    volumeListenerStreamHandler = VolumeListener(context)
    volumeListenerEventChannel.setStreamHandler(volumeListenerStreamHandler)

    methodChannel = MethodChannel(flutterPluginBinding.binaryMessenger, CHANNEL + "method")
    methodChannel.setMethodCallHandler(this)
  }


  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when (call.method) {
      "setVolume" -> {
        var volume:Double? = call.argument("volume")
        volumeObserver.setVolumeByPercentage(volume!!)
      }
      "getVolume" -> result.success(volumeObserver.getVolume())
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    methodChannel.setMethodCallHandler(null)
    volumeListenerEventChannel.setStreamHandler(null)
  }

}
