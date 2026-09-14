# Example design contract

Plugin demo for `volume_controller`. Not a consumer product. Keep the plugin API obvious.

## Read

- Kind: developer example
- Audience: Flutter developers
- Surfaces: Android, iOS, macOS, Windows, Linux
- Style: utility, matter-of-fact
- Animation: restrained, state only
- Register: Utility
- Dials: variance 4, motion 3, density 5
- #1 action: set system volume with the slider; mute is the second control

## Voice

Minimal and matter-of-fact. Labels name the plugin method. Never cute, never emoji.

## Theme

- Primary: dark (`ThemeMode.system` with a light/dark toggle)
- Seed: `#1F6F6A` (ink teal)
- Light surface: `#F7F5F1`
- Dark surface: `#141516` (not `#000`)
- One accent. Radius 12. Spacing 4pt scale.
- Platform fonts only. No downloaded typefaces.

## Decisions

- Do not add BLoC, go_router, or l10n. A plugin example should show `VolumeController` in a few files.
- Mute and volume are shown separately so desktop/Android mute-at-70% is visible.
- `addListener` is the live listener; `getVolume` / `isMuted` are explicit "Read now" actions.
- `showSystemUI` only on Android and iOS. The example defaults it off so dragging the slider does not cover the demo with the system HUD.
- Commit volume on slider release (`onChangeEnd`), not on every tick. Keep a Material `Slider` (not adaptive) so the thumb stays a 48dp target on iOS.
- AppBar titles stay start-aligned so they do not collide with the theme toggle. Title text scale is clamped to 1.4.
- Compact width (< 600) stacks the live percent above the mute chip. The page is a `SingleChildScrollView`, not a lazy list.
- The live percent is plain text. Crossfading it with `AnimatedSwitcher` throws when the same percent returns before the last transition ends (slider drag).
- Floor: 320×568 @ 1.3 and 360×640 @ 2.0 must not overflow; landscape 568×320 must scroll, not overflow.
- DESIGN.md lives in `example/` so it is not published with the plugin.
