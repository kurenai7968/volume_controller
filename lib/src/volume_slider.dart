// ignore_for_file: must_be_immutable

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:volume_controller/volume_controller.dart';

/// A customizable widget for volume control with various display options.
///
/// The [VolumeSlider] widget allows users to control volume settings within a specified range.
/// It provides options for customizing the appearance and behavior of the volume control widget.
class VolumeSlider extends StatefulWidget {
  /// Determines the display orientation of the slider (vertical or horizontal).
  final Display display;

  /// The color of the active portion of the slider.
  final Color sliderActiveColor;

  /// The color of the inactive portion of the slider.
  final Color sliderInActiveColor;

  /// The icon used for muting the volume.
  final IconData muteIcon;

  /// The size of the mute icon.
  final double? muteIconSize;

  /// The color of the mute icon.
  final Color muteIconColor;

  /// The icon used for increasing the volume.
  final IconData upVolumeIcon;

  /// The size of the volume increase icon.
  final double? upVolumeIconSize;

  /// The color of the volume increase icon.
  final Color upVolumeIconColor;

  /// Determines the initial visibility of the widget.
  ///
  /// When `visibleWidget` is set to `false`, the widget is initially hidden.
  late bool visibleWidget;

  /// Determines the visibility of the system UI elements related to volume control.
  ///
  /// If `visibleUiDevice` is set to `true`, the system's UI elements for volume control will be displayed.
  final bool visibleUiDevice;

  /// The size of the slider widget.
  final double sliderSize;

  /// The number of divisions/markers on the slider track.
  final int? sliderDivisions;

  VolumeSlider({
    super.key,
    this.display = Display.VERTICAL,
    this.sliderActiveColor = Colors.blueAccent,
    this.sliderInActiveColor = Colors.grey,
    this.muteIcon = CupertinoIcons.volume_mute,
    this.muteIconSize = 25.0,
    this.muteIconColor = Colors.blueAccent,
    this.upVolumeIcon = CupertinoIcons.volume_up,
    this.upVolumeIconSize = 25.0,
    this.upVolumeIconColor = Colors.blueAccent,
    this.visibleWidget = true,
    this.visibleUiDevice = false,
    this.sliderSize = 175,
    this.sliderDivisions = 100,
  });

  @override
  State<VolumeSlider> createState() => _VolumeSliderState();
}

class _VolumeSliderState extends State<VolumeSlider>
    with SingleTickerProviderStateMixin {
  double _volumeListenerValue = 0;
  double _getVolume = 0;
  double _setVolumeValue = 0;
  double _opacity = 0;

  void show(bool visibleUiDevice) {
    setState(() {
      VolumeController().showSystemUI = visibleUiDevice;
    });
  }

  @override
  void initState() {
    super.initState();
    show(widget.visibleUiDevice);
    // Listen to system volume change
    VolumeController().listener((volume) {
      setState(() => _volumeListenerValue = volume);
    });
    VolumeController().getVolume().then((volume) {
      setState(() {
        _setVolumeValue = volume; // Set the initial value of the slider
        _getVolume = volume; // Display the current volume in the Text widget
      });
    });
  }

  @override
  void dispose() {
    VolumeController().removeListener();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onDoubleTap: () {
        if (_opacity == 0) {
          _opacity = 1;
          setState(() {});
          Future.delayed(Duration(seconds: 5), () {
            if (_opacity == 1) {
              _opacity = 0;
              setState(() {});
            }
          });
        }
      },
      child: widget.visibleWidget
          ? SizedBox(
              width: size.width,
              child: widget.display == Display.VERTICAL
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        IconButton(
                          onPressed: () {
                            VolumeController().maxVolume();
                          },
                          icon: Icon(
                            widget.upVolumeIcon,
                            size: widget.upVolumeIconSize,
                            color: widget.upVolumeIconColor,
                          ),
                        ),
                        SizedBox(
                          height: widget.sliderSize,
                          child: Transform.rotate(
                            angle: -90 * 3.141592653589793 / 180,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: widget.sliderSize,
                                  child: Slider(
                                    activeColor: widget.sliderActiveColor,
                                    inactiveColor: widget.sliderInActiveColor,
                                    value: _setVolumeValue,
                                    divisions: 10,
                                    min: 0,
                                    max: 1,
                                    onChanged: (value) {
                                      _setVolumeValue = value;
                                      VolumeController()
                                          .setVolume(_setVolumeValue);
                                      setState(() {});
                                    },
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            VolumeController().muteVolume();
                          },
                          icon: Icon(
                            widget.muteIcon,
                            size: widget.muteIconSize,
                            color: widget.muteIconColor,
                          ),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () {
                            VolumeController().muteVolume();
                          },
                          icon: Icon(
                            widget.muteIcon,
                            size: widget.muteIconSize,
                            color: widget.muteIconColor,
                          ),
                        ),
                        SizedBox(
                          height: widget.sliderSize,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: widget.sliderSize,
                                child: Slider(
                                  activeColor: widget.sliderActiveColor,
                                  inactiveColor: widget.sliderInActiveColor,
                                  value: _setVolumeValue,
                                  divisions: 10,
                                  min: 0,
                                  max: 1,
                                  onChanged: (value) {
                                    _setVolumeValue = value;
                                    VolumeController()
                                        .setVolume(_setVolumeValue);
                                    setState(() {});
                                  },
                                ),
                              )
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            VolumeController().maxVolume();
                          },
                          icon: Icon(
                            widget.upVolumeIcon,
                            size: widget.upVolumeIconSize,
                            color: widget.upVolumeIconColor,
                          ),
                        ),
                      ],
                    ),
            )
          : AnimatedOpacity(
              opacity: _opacity,
              duration: Duration(milliseconds: 700),
              child: SizedBox(
                child: widget.display == Display.VERTICAL
                    ? SizedBox(
                        width: size.width,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            IconButton(
                              onPressed: () {
                                VolumeController().maxVolume();
                              },
                              icon: Icon(
                                widget.upVolumeIcon,
                                size: widget.upVolumeIconSize,
                                color: widget.upVolumeIconColor,
                              ),
                            ),
                            SizedBox(
                              height: widget.sliderSize,
                              child: Transform.rotate(
                                angle: -90 * 3.141592653589793 / 180,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: widget.sliderSize,
                                      child: Slider(
                                        activeColor: widget.sliderActiveColor,
                                        inactiveColor:
                                            widget.sliderInActiveColor,
                                        value: _setVolumeValue,
                                        divisions: 10,
                                        min: 0,
                                        max: 1,
                                        onChanged: (value) {
                                          _setVolumeValue = value;
                                          VolumeController()
                                              .setVolume(_setVolumeValue);
                                          setState(() {});
                                        },
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                VolumeController().muteVolume();
                              },
                              icon: Icon(
                                widget.muteIcon,
                                size: widget.muteIconSize,
                                color: widget.muteIconColor,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: () {
                              VolumeController().muteVolume();
                            },
                            icon: Icon(
                              widget.muteIcon,
                              size: widget.muteIconSize,
                              color: widget.muteIconColor,
                            ),
                          ),
                          SizedBox(
                            height: widget.sliderSize,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: widget.sliderSize,
                                  child: Slider(
                                    activeColor: widget.sliderActiveColor,
                                    inactiveColor: widget.sliderInActiveColor,
                                    value: _setVolumeValue,
                                    divisions: 10,
                                    min: 0,
                                    max: 1,
                                    onChanged: (value) {
                                      _setVolumeValue = value;
                                      VolumeController()
                                          .setVolume(_setVolumeValue);
                                      setState(() {});
                                    },
                                  ),
                                )
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              VolumeController().maxVolume();
                            },
                            icon: Icon(
                              widget.upVolumeIcon,
                              size: widget.muteIconSize,
                              color: widget.muteIconColor,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
    );
  }
}

enum Display {
  HORIZONTAL,
  VERTICAL,
}
