import Flutter
import UIKit
import AVFoundation

public class SwiftVolumeControllerPlugin: NSObject, FlutterPlugin{
    
    private static let CHANNEL = "com.kurenai7968.volume_controller."
    private let volumeObserver = VolumeObserver()
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        // Method Channel
        let methodChannel = FlutterMethodChannel(name:  CHANNEL + "method", binaryMessenger: registrar.messenger())
        let methodChannelInstance = SwiftVolumeControllerPlugin()
        registrar.addMethodCallDelegate(methodChannelInstance, channel: methodChannel)
        
        // Volume Listener Event Channel
        let eventChannel:FlutterEventChannel = FlutterEventChannel(name: CHANNEL + "volume_listener_event", binaryMessenger: registrar.messenger())
        eventChannel.setStreamHandler(VolumeListener())

    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if (call.method == "getVolume") {
            let volume = volumeObserver.getVolume()
            result(volume)
        }
        if (call.method == "setVolume") {
            let arg = call.arguments as? [String:Any]
            let volume = arg?["volume"] as? Double
            volumeObserver.setVolume(volume: Float(volume!))
        }
    }
}

