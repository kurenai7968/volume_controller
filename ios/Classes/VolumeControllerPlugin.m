#import "VolumeControllerPlugin.h"
#if __has_include(<volume_controller/volume_controller-Swift.h>)
#import <volume_controller/volume_controller-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "volume_controller-Swift.h"
#endif

@implementation VolumeControllerPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftVolumeControllerPlugin registerWithRegistrar:registrar];
}
@end
