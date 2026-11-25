import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pin_shutter/core/glass.dart';
import 'package:pin_shutter/core/theme.dart';
import 'package:pin_shutter/screens/settings/app_settings.dart';
import 'package:pin_shutter/screens/templates/templates_screen.dart';
import 'package:pin_shutter/state/prefs.dart';
import 'package:pin_shutter/state/settings_controller.dart';
import 'package:pin_shutter/state/template_controller.dart';

void main() {
  setUp(() {
    final prefs = Prefs.memory();
    SettingsController.instance.attach(prefs);
    TemplateController.instance.attach(prefs);
  });

  testWidgets('small squircle icons retain 48dp keyboard accessible targets', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: Scaffold(
          body: Center(
            child: GlassIconButton(
              icon: Icons.settings_outlined,
              label: 'Settings',
              size: 32,
              onTap: () => taps++,
            ),
          ),
        ),
      ),
    );
    expect(tester.getSize(find.byType(GlassIconButton)), const Size(48, 48));
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(taps, 1);
  });

  for (final size in [const Size(375, 812), const Size(812, 375)]) {
    for (final scale in [1.0, 2.0, 3.2]) {
      for (final category in SettingsCat.values) {
        testWidgets('${category.name} popup fits $size at $scale', (
          tester,
        ) async {
          await tester.binding.setSurfaceSize(size);
          addTearDown(() => tester.binding.setSurfaceSize(null));
          await tester.pumpWidget(
            MaterialApp(
              theme: AppTheme.dark(),
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(scale),
                  disableAnimations: true,
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                ),
                child: child!,
              ),
              home: Scaffold(
                body: Builder(
                  builder: (context) => TextButton(
                    onPressed: () => showSettingsCategory(context, category),
                    child: const Text('Open'),
                  ),
                ),
              ),
            ),
          );
          await tester.tap(find.text('Open'));
          await tester.pumpAndSettle();
          expect(find.byTooltip('Close ${category.label}'), findsOneWidget);
          expect(tester.takeException(), isNull);
          await tester.tap(find.byTooltip('Close ${category.label}'));
          await tester.pumpAndSettle();
          expect(find.byTooltip('Close ${category.label}'), findsNothing);
        });
      }
    }
    testWidgets('stamp designs fit $size with large text', (tester) async {
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark(),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(2)),
            child: child!,
          ),
          home: const TemplatesScreen(),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
