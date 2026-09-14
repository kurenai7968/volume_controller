import Cocoa
import FlutterMacOS

public class VolumeControllerPlugin: NSObject, FlutterPlugin {
  private let volumeController = VolumeController()

  private func invalidArgumentsResult() -> FlutterError {
    FlutterError(
      code: "invalid_arguments",
      message: "Missing or invalid method arguments.",
      details: nil)
  }

  public static func register(with registrar: FlutterPluginRegistrar) {
    let methodChannel = FlutterMethodChannel(
      name: ChannelName.methodChannel, binaryMessenger: registrar.messenger)
    let instance = VolumeControllerPlugin()
    registrar.addMethodCallDelegate(instance, channel: methodChannel)

    let eventChannel = FlutterEventChannel(
      name: ChannelName.eventChannel, binaryMessenger: registrar.messenger)
    eventChannel.setStreamHandler(VolumeListener())
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case MethodName.getVolume:
      result(volumeController.getVolume())
    case MethodName.setVolume:
      let arg = call.arguments as? [String: Any]
      guard let volume = arg?[MethodArgument.volume] as? Double else {
        result(invalidArgumentsResult())
        return
      }

      volumeController.setVolume(volume: Float(volume))
      result(nil)
    case MethodName.isMuted:
      result(volumeController.isMuted())
    case MethodName.setMute:
      let arg = call.arguments as? [String: Any]
      guard let isMute = arg?[MethodArgument.isMute] as? Bool else {
        result(invalidArgumentsResult())
        return
      }

      volumeController.setMute(isMute: isMute)
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
