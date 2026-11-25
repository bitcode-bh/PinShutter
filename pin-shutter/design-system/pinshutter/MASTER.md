# PinShutter mobile UI

Applies to camera chrome, Library/Map, media viewer, stamp designs, custom
editor, settings, dialogs, map popups and bottom sheets.

Preserve the existing dark canvas and yellow accent. Use the existing Palette,
AppText, Insets, Corners and Motion tokens; no new font or UI dependency.

- Active controls: yellow; destructive actions: danger; label state with native
  selected/toggled semantics in addition to color.
- Screen headings: AppText.h1; panel headings: AppText.title; settings rows:
  AppText.bodyHi; supporting copy: AppText.body; compact controls: AppText.label.
  The captured stamp is document content with its own user-selected typography.
- Use native smooth superellipse borders for surfaces and controls. Preserve
  functional circular elements such as shutters, location points and switches.
- Touch targets: at least 48 logical pixels. Smaller switch paint retains the
  native hit area and full settings row target.
- Keep tap feedback clipped to each control. Use native ink controls for
  keyboard activation and focus whenever possible.
- Use 4/8dp spacing increments, consistent gutters, and SafeArea for system
  insets. Long dialogs and detail sheets must scroll rather than overflow.
- Segment labels wrap at large text sizes, with equal slot widths and an
  indicator whose size remains constant during a selection transition.
- Honor reduced motion for routes, shared press effects and selection changes.
- About rows stack their label and value at large accessibility text sizes.

## Basis and validation

Applied UI/UX Pro Max mobile touch-target guidance and Flutter responsive
layout/text-scaling guidance. The broad generated website pattern and replacement
palette were unsuitable and were not adopted.

Regression coverage includes settings in 375×812 portrait and 812×375 landscape,
text scales 1×/2×/3.2×, nonzero safe insets, keyboard activation, existing native
switch semantics, ripple containment and navigation interruption tests.

The app intentionally provides one dark theme. Physical-device TalkBack,
VoiceOver and iOS runtime checks remain separate from widget validation.

## Settings spacing

Use 16dp screen/popup gutters and section separation. Popups use 12dp vertical
panel padding, an 8dp header-to-content gap, and 4dp between a field label and
its segmented control. Avoid accumulating padding on both sides of adjacent
groups. Editor control groups use 8dp horizontal/4dp vertical padding around
native 56dp switch rows. Read-only About rows use 8dp vertical padding; links
retain 48dp minimum targets. Keep row heights content-driven for larger text.

See `design/ui/settings-spacing-2026-11-18/README.md` for review and previews.
