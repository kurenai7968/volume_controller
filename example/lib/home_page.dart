import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:volume_controller/volume_controller.dart';
import 'package:volume_controller_example/theme/tokens.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.themeMode,
    required this.onToggleTheme,
  });

  final ThemeMode themeMode;
  final VoidCallback onToggleTheme;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final VolumeController _controller = VolumeController.instance;
  StreamSubscription<double>? _subscription;

  double _volume = 0;
  bool _isMuted = false;
  bool _showSystemUi = false;
  bool _dragging = false;
  String? _lastError;

  @override
  void initState() {
    super.initState();
    _controller.showSystemUI = _showSystemUi;
    _subscription = _controller.addListener(
      _onVolumeEvent,
      fetchInitialVolume: false,
    );
    unawaited(_readNow(silent: true));
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final platform = theme.platform;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final width = MediaQuery.sizeOf(context).width;
    final narrow = width < Layout.narrowWidth;
    final gutter = narrow ? Insets.lg : Insets.xl;
    final supportsHud = _supportsSystemUi(platform);
    final percent = (_volume * 100).round();

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: MediaQuery.withClampedTextScaling(
          maxScaleFactor: 1.4,
          child: const Text(
            'Volume Controller',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        actions: [
          IconButton(
            tooltip: Theme.of(context).brightness == Brightness.dark
                ? 'Use light theme'
                : 'Use dark theme',
            onPressed: widget.onToggleTheme,
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: Layout.maxContentWidth),
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                gutter,
                Insets.lg,
                gutter,
                Insets.xxl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _StatusCard(
                    volume: _volume,
                    percent: percent,
                    isMuted: _isMuted,
                    reduceMotion: reduceMotion,
                  ),
                  const SizedBox(height: Insets.xl),
                  Text('Set volume', style: theme.textTheme.titleMedium),
                  const SizedBox(height: Insets.sm),
                  Text(
                    'Drag to preview, then release to call setVolume.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  Slider(
                    padding: const EdgeInsets.symmetric(vertical: Insets.md),
                    value: _volume.clamp(0.0, 1.0),
                    onChangeStart: _onSliderChangeStart,
                    onChanged: _onSliderChanged,
                    onChangeEnd: _onSliderChangeEnd,
                    semanticFormatterCallback: (value) =>
                        '${(value * 100).round()} percent',
                  ),
                  const SizedBox(height: Insets.lg),
                  Text('Set mute', style: theme.textTheme.titleMedium),
                  const SizedBox(height: Insets.sm),
                  Text(
                    _muteFootnote(platform),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: Insets.md),
                  OverflowBar(
                    spacing: Insets.sm,
                    overflowSpacing: Insets.sm,
                    children: [
                      FilledButton(
                        onPressed: _isMuted ? _unmute : _mute,
                        child: Text(_isMuted ? 'Unmute' : 'Mute'),
                      ),
                      OutlinedButton(
                        onPressed: () => unawaited(_readNow()),
                        child: const Text('Read now'),
                      ),
                    ],
                  ),
                  if (supportsHud) ...[
                    const SizedBox(height: Insets.xl),
                    Text('System HUD', style: theme.textTheme.titleMedium),
                    const SizedBox(height: Insets.sm),
                    Text(
                      'Android and iOS only. Off by default so the HUD does not cover this screen while you drag.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: Insets.sm),
                    _SystemUiToggle(
                      value: _showSystemUi,
                      onChanged: _setShowSystemUi,
                    ),
                  ],
                  if (_lastError != null) ...[
                    const SizedBox(height: Insets.xl),
                    Text(
                      _lastError!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.error,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onVolumeEvent(double volume) {
    if (_dragging) {
      return;
    }
    setState(() => _volume = volume.clamp(0.0, 1.0));
    unawaited(_refreshMute());
  }

  void _onSliderChangeStart(double value) {
    setState(() {
      _dragging = true;
      _volume = value;
      _lastError = null;
    });
  }

  void _onSliderChanged(double value) {
    setState(() => _volume = value);
  }

  Future<void> _onSliderChangeEnd(double value) async {
    try {
      await _controller.setVolume(value);
      await _refreshMute();
    } on PlatformException catch (error) {
      _handleError(error.message ?? 'Could not set volume.');
    } finally {
      if (mounted) {
        setState(() => _dragging = false);
      }
    }
  }

  Future<void> _mute() => _setMuted(true);

  Future<void> _unmute() => _setMuted(false);

  Future<void> _setMuted(bool mute) async {
    setState(() => _lastError = null);
    try {
      await _controller.setMute(mute);
      await _readNow(silent: true);
    } on PlatformException catch (error) {
      _handleError(error.message ?? 'Could not change mute.');
    }
  }

  void _setShowSystemUi(bool value) {
    _controller.showSystemUI = value;
    setState(() => _showSystemUi = value);
  }

  Future<void> _readNow({bool silent = false}) async {
    try {
      final volume = await _controller.getVolume();
      final isMuted = await _controller.isMuted();
      if (!mounted) {
        return;
      }
      setState(() {
        _volume = volume.clamp(0.0, 1.0);
        _isMuted = isMuted;
        if (!silent) {
          _lastError = null;
        }
      });
    } on PlatformException catch (error) {
      if (!silent) {
        _handleError(error.message ?? 'Could not read volume.');
      }
    }
  }

  Future<void> _refreshMute() async {
    try {
      final isMuted = await _controller.isMuted();
      if (!mounted) {
        return;
      }
      setState(() => _isMuted = isMuted);
    } on PlatformException {
      // Keep the last known mute state if a hardware event races the read.
    }
  }

  void _handleError(String message) {
    if (!mounted) {
      return;
    }
    setState(() => _lastError = message);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  bool _supportsSystemUi(TargetPlatform platform) {
    return platform == TargetPlatform.android || platform == TargetPlatform.iOS;
  }

  String _muteFootnote(TargetPlatform platform) {
    switch (platform) {
      case TargetPlatform.iOS:
        return 'iOS has no system media mute. Mute sets volume to 0. Unmute restores the last level this example saved.';
      case TargetPlatform.android:
        return 'On Android 6 and later, mute is a stream flag. Volume can stay above 0 while muted.';
      default:
        return 'This platform uses the system mute switch. Volume can stay above 0 while muted.';
    }
  }
}

class _SystemUiToggle extends StatelessWidget {
  const _SystemUiToggle({
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MergeSemantics(
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Show system UI',
                style: theme.textTheme.titleMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: Insets.sm),
            Switch.adaptive(
              value: value,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.volume,
    required this.percent,
    required this.isMuted,
    required this.reduceMotion,
  });

  final double volume;
  final int percent;
  final bool isMuted;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final duration = reduceMotion ? Duration.zero : Motion.base;
    final stacked =
        MediaQuery.sizeOf(context).width < Layout.compactWidth;

    return Semantics(
      liveRegion: true,
      label:
          isMuted ? 'Muted, volume $percent percent' : 'Volume $percent percent',
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLow,
          borderRadius: Radii.card,
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.all(Insets.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Live output',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: Insets.sm),
              _StatusHeader(
                percent: percent,
                isMuted: isMuted,
                duration: duration,
                stacked: stacked,
                textStyle: theme.textTheme.displayMedium,
                chipStyle: theme.textTheme.labelLarge?.copyWith(
                  color: isMuted
                      ? scheme.onSecondaryContainer
                      : scheme.onSurface,
                ),
                chipColor: isMuted
                    ? scheme.secondaryContainer
                    : scheme.surfaceContainerHighest,
              ),
              const SizedBox(height: Insets.lg),
              _VolumeBar(
                volume: volume,
                isMuted: isMuted,
                duration: duration,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusHeader extends StatelessWidget {
  const _StatusHeader({
    required this.percent,
    required this.isMuted,
    required this.duration,
    required this.stacked,
    required this.textStyle,
    required this.chipStyle,
    required this.chipColor,
  });

  final int percent;
  final bool isMuted;
  final Duration duration;
  final bool stacked;
  final TextStyle? textStyle;
  final TextStyle? chipStyle;
  final Color chipColor;

  @override
  Widget build(BuildContext context) {
    final percentLabel = FittedBox(
      fit: BoxFit.scaleDown,
      alignment: AlignmentDirectional.centerStart,
      child: Text(
        '$percent%',
        maxLines: 1,
        style: textStyle,
      ),
    );

    final chip = Align(
      alignment: AlignmentDirectional.centerStart,
      child: AnimatedContainer(
        duration: duration,
        curve: Curves.easeInOutCubicEmphasized,
        padding: const EdgeInsets.symmetric(
          horizontal: Insets.md,
          vertical: Insets.sm,
        ),
        decoration: BoxDecoration(
          color: chipColor,
          borderRadius: Radii.pill,
        ),
        child: Text(
          isMuted ? 'Muted' : 'Audible',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: chipStyle,
        ),
      ),
    );

    if (stacked) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          percentLabel,
          const SizedBox(height: Insets.sm),
          chip,
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: percentLabel),
        const SizedBox(width: Insets.sm),
        Flexible(child: chip),
      ],
    );
  }
}

class _VolumeBar extends StatelessWidget {
  const _VolumeBar({
    required this.volume,
    required this.isMuted,
    required this.duration,
  });

  final double volume;
  final bool isMuted;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          height: Insets.sm,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: Radii.pill,
            ),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: AnimatedContainer(
                duration: duration,
                curve: Curves.easeInOutCubicEmphasized,
                width: constraints.maxWidth * volume.clamp(0.0, 1.0),
                decoration: BoxDecoration(
                  color: isMuted ? scheme.outline : scheme.primary,
                  borderRadius: Radii.pill,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
