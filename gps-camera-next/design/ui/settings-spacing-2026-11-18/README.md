# Settings spacing review — 18 November 2026

Reviewed Display & Units, Stamp, About, camera GPS Stamp settings, Custom Template
(including style, layout, custom text and field groups), saved/reorder dialogs,
stamp designs, Privacy, and shared native dialog/control spacing.

The native save/load dialogs, reorder list and stamp-design cards already use
appropriate content and touch spacing; they retain those dimensions. Changes
focus on duplicate surrounding whitespace rather than smaller type or switches.

| Area | Finding | Applied refinement |
| --- | --- | --- |
| Display & Units | Every group had 12dp above and below; label gaps added further spacing | 4dp label gap, 16dp between groups, no duplicate leading/trailing group padding |
| Settings popups | 20dp outer and mixed 16/20dp inner padding | 16dp outer/horizontal gutters, 12dp vertical panel padding, 8dp header gap |
| Stamp | Navigation rows used 18dp vertical padding while switches used a different row rhythm | Navigation rows share the 56dp minimum; added the stamp icon to match the icon column |
| About | Read-only rows carried the same heavy padding as interactive links | 8dp vertical row padding; links retain at least 48dp; long values still stack at large text |
| Template editor | Each group added 32dp vertical wrapper padding | 8dp total vertical wrapper padding; 56dp switch rows retained |
| Editor sections | Standalone reorder action and inconsistent 10/20dp gaps stretched the page | Reorder action sits beside Layout; 8dp label/form gaps and 16dp section gaps |
| Custom text | Collapsed disclosure had excessive surrounding padding | Compact group wrapper; consistent 8dp inset for expanded fields |
| Camera settings | 22dp side/24dp bottom panel spacing differed from settings popups | 16dp side/bottom panel padding; aligned navigation and switch labels retained |
| Privacy | 20dp side/32dp bottom spacing differed from other settings screens | 16dp gutters and section separation, 8dp heading-to-body gaps |
| Large text | Long editor headings and section actions could exhaust available space | Two-line header summaries with full text semantics; section action constrained to available width |

## Result and evidence

At 375×812 and default text scaling, Display & Units measures 579dp high.
The spacing changes remove 80dp of vertical padding from that popup. Editor
switch groups remove 24dp of surrounding padding without shrinking their rows.

Screenshots are actual Flutter widget renders using Roboto and Material icons,
not device captures. They use sample location data and a test-only font override
because Flutter's default test font is Ahem. Device/system insets are verified
separately in regression tests.

- [Display before](display-before.png) / [after](display-after.png)
- [About before](about-before.png) / [after](about-after.png)
- [Editor before](editor-before.png) / [after](editor-after.png)

Validation: 193 Flutter tests passed; analyzer clean; source diff whitespace
check clean. Tests cover 320/375dp density and option touch targets, popup
portrait/landscape and 1×/2×/3.2× text, editor reflow, switch semantics and
persistence, clipped ripple feedback, and camera settings at phone/tablet sizes.

Android guidance: [touch targets at least 48×48dp](https://developer.android.com/guide/topics/ui/accessibility/apps#use-large-simple-controls).
56dp switch rows and their native hit areas remain intact. The UI/UX Pro Max
skill's mobile spacing guidance informed the consistent 4/8dp rhythm.

No new physical-device deployment, TalkBack session or iOS runtime check was
performed for this spacing pass. The app intentionally uses a single dark theme.
