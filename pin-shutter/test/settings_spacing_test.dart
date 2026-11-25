import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pin_shutter/core/theme.dart';
import 'package:pin_shutter/core/widgets/controls.dart';
import 'package:pin_shutter/screens/camera/widgets/camera_design.dart';
import 'package:pin_shutter/screens/settings/app_settings.dart';
import 'package:pin_shutter/screens/templates/custom_template_editor.dart';
import 'package:pin_shutter/state/prefs.dart';
import 'package:pin_shutter/state/settings_controller.dart';
import 'package:pin_shutter/state/template_controller.dart';

void main() {
  setUp(() {
    final prefs = Prefs.memory();
    SettingsController.instance.attach(prefs);
    TemplateController.instance.attach(prefs);
  });

  for (final width in [320.0, 375.0]) {
    testWidgets('display is compact with accessible option targets at $width', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(Size(width, 812));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark(),
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () =>
                    showSettingsCategory(context, SettingsCat.display),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(
        tester.getSize(find.byType(CameraGlass)).height,
        lessThan(width == 320 ? 640 : 600),
      );
      // All options must fit without shrinking their touch regions.
      for (final label in ['Label', '100 m', 'Terrain', 'Plus']) {
        final tap = find
            .ancestor(of: find.text(label), matching: find.byType(SettingsTap))
            .first;
        final size = tester.getSize(tap);
        expect(size.width, greaterThanOrEqualTo(48));
        expect(size.height, greaterThanOrEqualTo(48));
      }
      final titles = [
        'ANDROID MOCK LOCATIONS',
        'PREFERRED GPS ACCURACY',
        'BASE MAP',
        'COORDINATE FORMAT',
      ];
      final left = tester.getTopLeft(find.text(titles.first)).dx;
      for (final title in titles) {
        expect(tester.getTopLeft(find.text(title)).dx, left);
      }
      final switchRow = tester.getRect(find.byType(GlassSwitchTile));
      expect(
        switchRow.bottom,
        lessThanOrEqualTo(tester.getRect(find.byType(CameraGlass)).bottom),
      );
      expect(tester.takeException(), isNull);
    });
  }

  for (final scale in [1.0, 2.0, 3.2]) {
    testWidgets('editor groups remove wrapper space and reflow at $scale', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark(),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(scale)),
            child: child!,
          ),
          home: const CustomTemplateEditor(),
        ),
      );
      await tester.pumpAndSettle();
      final bold = find.widgetWithText(GlassSwitchTile, 'Bold text');
      await tester.scrollUntilVisible(bold, 200);
      await tester.pumpAndSettle();
      final group = find
          .ancestor(of: bold, matching: find.byType(CameraGlass))
          .first;
      final rows = find.descendant(
        of: group,
        matching: find.byType(GlassSwitchTile),
      );
      expect(rows, findsNWidgets(2));
      final rowHeight =
          tester.getSize(rows.first).height + tester.getSize(rows.last).height;
      expect(tester.getSize(group).height - rowHeight, lessThanOrEqualTo(12));
      for (final row in rows.evaluate()) {
        expect(
          tester.getSize(find.byWidget(row.widget)).height,
          greaterThanOrEqualTo(56),
        );
      }
      expect(tester.takeException(), isNull);
    });
  }
}
