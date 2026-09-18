## 3.7.1

* Reuse the volume EventChannel stream and await `removeListener` so
  listeners can be re-attached
  ([#58](https://github.com/kurenai7968/volume_controller/issues/58))
* Keep a same-turn `addListener` after an unawaited `removeListener`

## 3.7.0

* Android: Mute `STREAM_MUSIC` with `isStreamMute` / `ADJUST_MUTE` on API 23+
* Android: Observe music volume via `ContentObserver` and ignore other stream broadcasts
* iOS: Retry `MPVolumeView` writes on the main queue and report failure if the slider is missing
* iOS: Stop deactivating the shared audio session when the volume listener is cancelled
* Dart: Document mute semantics
* Dart: Treat a null `isMuted` result as unmuted instead of throwing
* macOS: Avoid force-unwraps; fall back to per-channel volume/mute; follow default-output changes
* Windows: Share COM/device lifetime, rebind on default-device change, and reject invalid arguments
* Windows: Keep the volume callback if rebind notification registration fails so later device changes can restore events
* Linux: Fall back across mixer elements, poll ALSA descriptors, and reject invalid arguments
* Refresh the example app to show mute separately from volume, and platform HUD
* Android: Build with Gradle 9.3.1 and AGP 9.1.0 so JDK 25 can assemble the example

## 3.6.1

* Windows: Release the volume callback when notification registration fails because no audio endpoint is available
* Windows: Send volume listener events on the Flutter platform thread
* Windows: Update GoogleTest so plugin tests configure with CMake 4
* Windows: Dispatch volume events through a message-only window created on the Flutter platform thread

## 3.6.0

* Update minimum supported SDKs to Flutter 3.44 and Dart 3.12
* Android: Migrates to built-in Kotlin

## 3.5.0

* Improve iOS/Android arguments parsing for volume change listener

## 3.4.4

* Fix iOS 12 support issue

## 3.4.3

* Fixed key window lookup on iOS when using the Scene-based lifecycle.

## 3.4.2

* Add UIScene life cycle support

## 3.4.1

* Fix iOS audio session handling to prevent background music from pausing

## 3.4.0

* Support Linux

## 3.3.3

* Downgrade the android compileSdk version to 34

## 3.3.2

* Fix the audio session cannot be activated after background resume on iOS

## 3.3.1

* Update README.md

## 3.3.0

* Support Windows

## 3.2.0

* Add `isMuted` and `setMute` functions

## 3.1.0

* Support MacOS

## 3.0.2

* Remove method `maxVolume` and `muteVolume`

## 3.0.1

* iOS: Fix music stops when opening the app.

## 3.0.0

* Change the singleton to instance
* Rename listener to addListener
* iOS: Improve the performance of volume change listener

## 2.0.8

* iOS: Update removeObserver may crash issue

## 2.0.7

* Android: Update build.gradle

## 2.0.6

* iOS can hide the system UI by showSystemUI

## 2.0.5

* Android: Update Versions of Kotlin, Gradle, Gradle Android Plugin

## 2.0.4

* Fix iOS Audio mute after resume from background

## 2.0.3

* Android: Migrate maven repository from jcenter to mavenCentral

## 2.0.2

* VolumeController class change to singleton
* Add "removeListener" function
* Add show/hide volume system UI (only for android now)

## 2.0.1

* Fix iOS Bug

## 2.0.0

* Fix iOS Bug
* Migrate to null safety

## 1.0.1+1

* Update Comment

## 1.0.1

* Add maxVolume function and muteVolume function
* Update README.md
* Update example

## 1.0.0

* Android: Support get/set/volume
* iOS: Support get/set/volume
