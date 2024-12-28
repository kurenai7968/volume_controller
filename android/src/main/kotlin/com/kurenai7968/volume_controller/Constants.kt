package com.kurenai7968.volume_controller

internal const val VOLUME_CHANGED_ACTION = "android.media.VOLUME_CHANGED_ACTION"

object ChannelName {
    const val METHOD_CHANNEL = "com.kurenai7968.volume_controller.method"
    const val EVENT_CHANNEL = "com.kurenai7968.volume_controller.volume_listener_event"
}

object MethodName {
    const val SET_VOLUME = "setVolume"
    const val GET_VOLUME = "getVolume"
}

object MethodArgument {
    const val VOLUME = "volume"
    const val SHOW_SYSTEM_UI = "showSystemUI"
}