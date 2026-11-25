# GPS Camera Pro UI, navigation, and Android audit

**Date** 9 November 2026  
**Device** Motorola Edge 70 over wireless ADB, Android API 37, 1220 × 2712 px, 408 dpi override  
**Build** Signed ARM64 release from the working tree, version 1.0.1+2

## Screen and navigation inventory

| Surface | Entry and available interactions |
|---|---|
| Auto camera | Launch, wake, camera permissions and retry, viewfinder tap focus, long-press lock, double-tap reset, pinch and swipe adjustments, zoom/exposure selector, recording and timer feedback |
| Pro camera | Bottom bar or camera tools → Pro, native preview, lens switch, zoom, exposure, ISO, shutter, white balance, focus, metering, histogram and file-type controls where supported |
| Bottom control bar | Gallery, Auto/Pro, Shutter, Photo, Video, Flip. Horizontal swipe moves focus. Photo and Video select on landing. Action controls run on tap |
| Camera tools | Camera button → horizontally scrollable shortcuts → All camera tools grid. Vertical expand/collapse remains available. Includes flash, HDR, night mode, timer, ratio, resolution, grid, level, histogram, focus lock, exposure, peaking, zebras, original copy, mirror, shutter sound, and GPS metadata where supported |
| GPS stamp and map | Live position, accuracy, address, time, compass, configurable overlay, template and map gestures, expandable map dialog with pan and zoom |
| App settings | Gear → Stamp, Display & Units, or About. Stamp covers visibility, template, fields, and opacity. Display & Units covers base map, coordinates, address length, measurement and temperature units, and clock format |
| Templates | Stamp → Template. Scroll, select a preset, or open Customize |
| Custom Template | Stamp → Customize fields, or Templates → Customize. Preview, style controls, custom text, and grouped field switches |
| In-app photo viewer | Gallery thumbnail → swipeable captures, zoom, share sheet, device gallery, and delete confirmation |
| System surfaces | Android runtime permission dialogs, app settings, share sheet, and external gallery. External apps supply their own navigation and appearance |

## Priority matrix

| Priority | Finding | Disposition |
|---|---|---|
| Critical | A stamped Auto photo could contain the stamp over a black frame. The Flutter raster path attempted to capture an external camera texture | Composite from the camera JPEG, keep the selected viewfinder crop, omit framing guides, and stop with a visible error if the JPEG is unavailable |
| High | Pro offered Video even though its native backend exposes still capture only. On the Motorola, the shutter displayed “Recording needs a camera” | Switch to Auto for Video and to Photo when entering native Pro |
| High | The idle timer could dispose of an active camera during recording. Backgrounding stopped recording and discarded the returned file | Keep the camera open while recording, finalize and save on backgrounding, and wait for camera release before reopening |
| High | Rapid shutter taps and camera changes could overlap recording start/stop or take away the Stop action | Serialize recording transitions and disable incompatible mode, camera, Pro, and resolution changes while recording |
| High | The GPS save control persisted a value but supplied no EXIF coordinates to the output pipeline | Write current GPS coordinates into the output JPEG when enabled. Apply the same policy to optional originals and keep visible stamp configuration independent |
| High | The editor saved Top placement, but the live stamp and JPEG compositor always used Bottom. Pro compositing also attempted to draw into an immutable bitmap | Apply placement in the viewfinder and native JPEG compositor. Decode Pro JPEGs upright into a writable bitmap |
| High | Exposure-assist fidelity is incomplete. Zebra and focus-peaking overlays are drawn as fixed patterns, and histogram has a synthetic fallback before samples arrive | Open. Connect each indicator to real frame data and validate against a controlled scene |
| Medium | The full camera-tools panel relied on an undisclosed vertical swipe. Several tiles exposed identical On/Off names | Add an explicit All camera tools button, feature names for accessibility, and a width-aware tool grid |
| Medium | Back on the main camera could leave the app while a tools strip was expanded. Stamp lacked the close affordance used by other dialogs | Back dismisses expanded strips. Stamp, Display, About, and the tools grid share a labelled 48 dp close button |
| Medium | Native JPEG encoding/compositing and MediaStore work ran on Android's platform thread | Use a background method-channel queue and clean up incomplete MediaStore inserts on failure |
| Medium | Rebuilds from unrelated camera state invalidated unchanged glass filters | Repaint the filter only when its shader inputs or display scale change |
| Medium | The mini-map required a double tap to open, and map close and zoom controls had small touch targets and no spoken names | Open the map with a labelled single tap and use labelled 48 dp glass controls |
| Low | About has a hard-coded 1.0.0 label while the APK reports 1.0.1 | Open. Source the display value from installed package metadata |
| Low | Night mode and shutter sound are persisted controls with no corresponding camera operation in the reviewed paths | Open. Validate hardware support and wire these preferences to actual behavior |

## Implementation and regression coverage

- Camera lifecycle, Photo/Video backend handoff, shutter feedback, JPEG compositing, and Back handling changed in `camera_screen.dart`.
- Camera action locks and accessibility changed in `camera_control_bar.dart`, `camera_tool_strip.dart`, `controls.dart`, and `app_settings.dart`. Existing Stash glass and squircle components are reused.
- Photo geotagging and off-main-thread JPEG/media work changed in `capture_service.dart` and `MainActivity.kt`. The local and gallery copies receive the same output bytes.
- `stash_glass.dart` avoids invalidating unchanged shader uniforms. The camera screen cancels its Pro event subscription on disposal.
- Flutter analysis reported no issues. All nine tests passed, including tap and swipe coverage at 320, 390, and 600 dp and the recording-control lock regression. The release APK built successfully.

## Device validation

| Journey | Result |
|---|---|
| Pro → Video on the original build | **Fail reproduced.** The shutter reported that recording needed a camera |
| Pro → Video → record on audit build | **Pass.** Auto backend recorded and saved a 33.4 s clip, past the 30 s camera idle threshold |
| Record → Home → return | **Pass.** The 3.8 s clip appeared in MediaStore and the app returned to the foreground |
| Settings → About and Display & Units | **Pass.** Both opened on the Motorola |
| Stamp → Templates → Custom Template → Back → Camera | **Pass.** The editor and both Back steps were checked on the Motorola |

| Pro still capture | **Pass.** A fresh Pro JPEG was written to the gallery with GPS EXIF. Full sensor crop and orientation combinations remain unverified |
| Front-camera stamped JPEG → in-app viewer | **Pass.** A new JPEG was saved, and on-device sampling of the viewer detected scene pixels above the stamp. The rear camera faced a nearly dark scene during testing |
| Save GPS metadata On and Off | **Pass.** Fresh JPEGs had GPS EXIF with On and lacked it with Off. The test parsed only presence on-device and restored the setting |
| Editor Top and Bottom → live stamp | **Pass.** The stamp moved to the top of the viewfinder and returned to the bottom when the original selection was restored |
| Viewer paging → delete prompt → Cancel → Back | **Pass.** Swipe moved the counter to page two, Cancel retained the photo, and Back closed the viewer |
| Mini-map → pan/zoom dialog → close | **Pass.** A single tap opened the dialog, both zoom buttons responded, and Close returned to the camera. Pinch/pan were not covered |
| Camera tools → All camera tools | **Pass.** The button opened the full grid, including the GPS metadata tile |
| Switch cameras | **Pass.** Both cameras produced active preview samples and the front-camera client was confirmed through Android camera diagnostics |

## Performance spot check

A SurfaceFlinger sample during two scripted bottom-bar sweeps on the intermediate audit build returned 62 distinct presentation timestamps. The display interval was 11.11 ms (90 Hz), and median and 95th-percentile intervals were 11.14 ms in that buffered sample. The display switched to 60 Hz for the final release sample, which returned 63 timestamps with a 16.71 ms median and 16.71 ms 95th-percentile interval. This covers a short rendered sequence and cannot establish sustained throughput, input-to-display latency, camera FPS, or thermal performance.

## Pending verification

The audit generated test photos and two videos in the device’s GPS Camera album. Existing media was left in place.

Permission denial and permanent denial, backgrounding during native Pro initialization, detailed Pro and HDR output, map and viewer multi-touch gestures, share handoff, confirmed deletion, exhaustive settings persistence, large text, TalkBack traversal, and older Android versions need dedicated device coverage. A short app-surface timing trace is a spot check. Sustained frame pacing, thermal and battery behavior, and comparative performance against other camera apps require a repeatable profiling run.
