import AVFoundation
import Flutter
import UIKit

public class VolumeControllerPlugin: NSObject, FlutterPlugin {
  private let audioSession = AVAudioSession.sharedInstance()
  private lazy var volumeController = VolumeController(audioSession: audioSession)
  private lazy var volumeListener = VolumeListener(audioSession: audioSession)

  private func invalidArgumentsResult() -> FlutterError {
    FlutterError(
      code: "invalid_arguments",
      message: "Missing or invalid method arguments.",
      details: nil)
  }

  public static func register(with registrar: FlutterPluginRegistrar) {
    let methodChannel = FlutterMethodChannel(
      name: ChannelName.methodChannel, binaryMessenger: registrar.messenger())
    let instance = VolumeControllerPlugin()
    registrar.addMethodCallDelegate(instance, channel: methodChannel)

    let eventChannel = FlutterEventChannel(
      name: ChannelName.eventChannel,
      binaryMessenger: registrar.messenger())
    eventChannel.setStreamHandler(instance.volumeListener)

    registrar.addApplicationDelegate(instance)
    if #available(iOS 13.0, *) {
      registrar.addSceneDelegate(instance)
    }
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case MethodName.getVolume:
      result(volumeController.getVolume())
    case MethodName.setVolume:
      let arg = call.arguments as? [String: Any]
      let volume = arg?[MethodArgument.volume] as? Double
      let showSystemUI = arg?[MethodArgument.showSystemUI] as? Bool

      guard let volume, let showSystemUI else {
        result(invalidArgumentsResult())
        return
      }

      volumeController.setVolume(volume: Float(volume), showSystemUI: showSystemUI) { error in
        result(error)
      }
    case MethodName.isMuted:
      result(volumeController.isMuted())
    case MethodName.setMute:
      let arg = call.arguments as? [String: Any]
      let isMute = arg?[MethodArgument.isMute] as? Bool
      let showSystemUI = arg?[MethodArgument.showSystemUI] as? Bool

      guard let isMute, let showSystemUI else {
        result(invalidArgumentsResult())
        return
      }

      volumeController.setMute(isMute: isMute, showSystemUI: showSystemUI) { error in
        result(error)
      }
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}

extension VolumeControllerPlugin: FlutterApplicationLifeCycleDelegate {
  public func applicationWillEnterForeground(_ application: UIApplication) {
    if #available(iOS 13.0, *) {
      return
    }

    volumeListener.resumeVolumeObservation()
  }
}

@available(iOS 13.0, *)
extension VolumeControllerPlugin: FlutterSceneLifeCycleDelegate {
  public func sceneWillEnterForeground(_ scene: UIScene) {
    volumeListener.resumeVolumeObservation()
  }
}
