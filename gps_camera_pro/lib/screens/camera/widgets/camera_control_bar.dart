import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../core/design/palette.dart';
import '../../../core/design/tokens.dart';
import '../../../core/glass.dart';
import '../../../core/widgets/stash_dial.dart';
import '../../../core/widgets/pressable.dart';

enum CameraMode { video, photo, pro }

class CameraControlBar extends StatelessWidget {
  static const height = 160.0;
  final CameraMode mode;
  final bool busy;
  final Uint8List? lastShot;
  final bool recording;
  final bool lockCameraChanges;
  final ValueChanged<CameraMode> onMode;
  final VoidCallback? onShutter;
  final VoidCallback onFlip;
  final VoidCallback onGallery;
  final VoidCallback? onTools;
  final bool toolsOpen;

  const CameraControlBar({
    super.key,
    required this.mode,
    required this.busy,
    required this.lastShot,
    required this.recording,
    this.lockCameraChanges = false,
    required this.onMode,
    required this.onShutter,
    required this.onFlip,
    required this.onGallery,
    this.onTools,
    this.toolsOpen = false,
  });

  @override
  Widget build(BuildContext context) {
    final thumb = lastShot;
    final video = mode == CameraMode.video;
    final action = busy ? null : onShutter;
    return SizedBox(
      height: height,
      child: Column(
        children: [
          SizedBox(
            height: 88,
            child: Row(
              children: [
                const Spacer(),
                Tooltip(
                  message: video
                      ? (recording ? 'Stop recording' : 'Start recording')
                      : 'Take photo',
                  excludeFromSemantics: true,
                  child: Semantics(
                    label: video
                        ? (recording ? 'Stop recording' : 'Start recording')
                        : 'Take photo',
                    button: true,
                    enabled: action != null,
                    child: Pressable(
                      onTap: action,
                      scale: 0.94,
                      child: SizedBox.square(
                        dimension: 76,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Palette.glassFillStrong,
                            border: Border.all(
                              color: Palette.glassStroke,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: busy
                                ? const CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Palette.accentMuted,
                                  )
                                : AnimatedContainer(
                                    duration: Motion.fast,
                                    curve: Motion.emphasized,
                                    width: recording ? 27 : 64,
                                    height: recording ? 27 : 64,
                                    decoration: BoxDecoration(
                                      color: action == null
                                          ? Palette.textLo
                                          : (video
                                                ? Palette.danger
                                                : Colors.white),
                                      borderRadius: BorderRadius.circular(
                                        recording ? 7 : 32,
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: GlassIconButton(
                      icon: Icons.apps_rounded,
                      label: toolsOpen
                          ? 'Close quick camera tools'
                          : 'Open quick camera tools',
                      size: 48,
                      active: toolsOpen,
                      onTap: onTools,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                if (thumb == null)
                  GlassIconButton(
                    icon: Icons.photo_library_outlined,
                    label: 'Open gallery',
                    size: 48,
                    onTap: onGallery,
                  )
                else
                  Semantics(
                    label: 'Open gallery',
                    button: true,
                    child: Pressable(
                      onTap: onGallery,
                      child: SizedBox.square(
                        dimension: 48,
                        child: Center(
                          child: ClipOval(
                            child: Image.memory(
                              thumb,
                              width: 36,
                              height: 36,
                              fit: BoxFit.cover,
                              gaplessPlayback: true,
                              cacheWidth: 96,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                Expanded(
                  child: Stack(
                    children: [
                      const Positioned.fill(
                        child: GlassSurface(
                          radius: Corners.pill,
                          blur: Blurs.chip,
                          child: SizedBox.expand(),
                        ),
                      ),
                      StashDial(
                        labels: const ['Video', 'Photo', 'Pro'],
                        icons: const [
                          Icons.videocam_outlined,
                          Icons.photo_camera_outlined,
                          Icons.tune_rounded,
                        ],
                        selected: mode.index,
                        onChanged: (index) => onMode(CameraMode.values[index]),
                        isEnabled: (index) =>
                            !lockCameraChanges || index == mode.index,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                GlassIconButton(
                  icon: Icons.cameraswitch_outlined,
                  label: 'Switch camera',
                  size: 48,
                  onTap: lockCameraChanges ? null : onFlip,
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}
