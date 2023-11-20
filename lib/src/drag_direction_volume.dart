import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../volume_controller.dart';

class DragDirectionVolume extends StatefulWidget {
  final double width;
  final double height;

  /// Determines the visibility of the system UI elements related to volume control.
  ///
  /// If `visibleUiDevice` is set to `true`, the system's UI elements for volume control will be displayed.
  final bool visibleUiDevice;

  const DragDirectionVolume({
    Key? key,
    this.width = 50,
    this.height = 250,
    this.visibleUiDevice = false,
  }) : super(key: key);

  @override
  _DragDirectionVolumeState createState() => _DragDirectionVolumeState();
}

class _DragDirectionVolumeState extends State<DragDirectionVolume> {
  double _volumeListenerValue = 0;
  double _getVolume = 0;
  double _setVolumeValue = 0;
  double _key = 0;
  double _opacity = 0;
  double _opacityText = 0;

  late Timer _timer;

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

    // Get initial volume and set the slider value
    VolumeController().getVolume().then((volume) {
      setState(() {
        _setVolumeValue = volume;
        _getVolume = volume;
        _timer = Timer(Duration(seconds: 3), () {
          setState(() {
            _opacity = 0; //
            _opacityText = 0;
          });
        });
      });
    });
  }

  @override
  void dispose() {
    VolumeController().removeListener();
    _timer.cancel(); // لغو تایمر در dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return GestureDetector(
      onVerticalDragUpdate: _onVerticalDragUpdateHandler,
      behavior: HitTestBehavior.translucent,
      dragStartBehavior: DragStartBehavior.start,
      onVerticalDragEnd: _onVerticalDragEndHandler,
      child: Column(
        children: [
          AnimatedOpacity(
            opacity: _opacity,
            duration: Duration(milliseconds: 700),
            child: Icon(Icons.volume_up, size: 50),
          ),
          SizedBox(height: 5.0),
          AnimatedOpacity(
            opacity: _opacityText,
            duration: Duration(milliseconds: 300),
            child: AnimatedSwitcher(
              duration: Duration(milliseconds: 300),
              child: Text(
                "${_setVolumeValue.toStringAsFixed(2)}",
                key: ValueKey<double>(_key),
                style: TextStyle(fontSize: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onVerticalDragUpdateHandler(DragUpdateDetails details) {
    double dragPercentage = 1 - (details.localPosition.dy / widget.height);
    _setVolumeValue = dragPercentage.clamp(0.0, 1.0);
    VolumeController().setVolume(_setVolumeValue);
    setState(() {
      _key++;
      _opacity = 1;
      _opacityText = 1;
      _timer.cancel();
      _timer = Timer(Duration(seconds: 3), () {
        setState(() {
          _opacity = 0;
          _opacityText = 0;
        });
      });
    });
  }

  void _onVerticalDragEndHandler(DragEndDetails details) {
    setState(() {
      // ignore: unnecessary_statements
      _setVolumeValue;
    });
  }
}
