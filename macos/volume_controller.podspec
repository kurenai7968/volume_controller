#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint volume_controller.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'volume_controller'
  s.version          = '3.7.0'
  s.summary          = 'A Flutter plugin to control and observe system volume.'
  s.description      = <<-DESC
A Flutter plugin to control and observe system volume on Android, iOS, macOS, Windows, and Linux.
                       DESC
  s.homepage         = 'https://github.com/kurenai7968/volume_controller'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'kurenai7968' => 'email@example.com' }

  s.source           = { :path => '.' }
  s.source_files = 'volume_controller/Sources/volume_controller/**/*'
  s.dependency 'FlutterMacOS'

  s.platform = :osx, '10.11'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
end
