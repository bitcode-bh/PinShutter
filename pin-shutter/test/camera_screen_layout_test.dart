import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pin_shutter/state/prefs.dart';
import 'package:pin_shutter/screens/camera/camera_screen.dart';
import 'package:pin_shutter/screens/camera/widgets/camera_layer.dart';
import 'package:pin_shutter/screens/camera/widgets/camera_control_bar.dart';
import 'package:pin_shutter/models/capture_options.dart';
import 'package:pin_shutter/state/settings_controller.dart';
import 'package:pin_shutter/state/template_controller.dart';
import 'package:pin_shutter/models/location_integrity.dart';

void main() {
  for (final size in [
    const Size(320, 568),
    const Size(390, 844),
    const Size(600, 960),
  ]) {
    testWidgets('stamp settings fit ${size.width.toInt()} dp', (tester) async {
      final directory = Directory.systemTemp.createTempSync(
        'next-camera-test-',
      );
      addTearDown(() => directory.deleteSync(recursive: true));
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final preferences = Prefs.memory();
      SettingsController.instance.attach(preferences);
      final mockOmitted = size.width == 320;
      if (mockOmitted) {
        SettingsController.instance.mockLocationPolicy =
            MockLocationPolicy.omitCoordinates;
      }
      TemplateController.instance.attach(preferences);
      final messenger = tester.binding.defaultBinaryMessenger;
      for (final name in [
        'com.gpscamera.pin_shutter/heading',
        'com.gpscamera.pin_shutter/gravity',
        'com.gpscamera.pin_shutter/gallery',
        'com.gpscamera.pin_shutter/positions',
        'com.gpscamera.pin_shutter/location_switch',
      ]) {
        messenger.setMockMethodCallHandler(
          MethodChannel(name),
          (_) async => null,
        );
      }
      messenger.setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/camera'),
        (_) async => [],
      );
      messenger.setMockMethodCallHandler(
        const MethodChannel('com.gpscamera.pin_shutter/location'),
        (call) async => call.method == 'status'
            ? {'service': mockOmitted, 'permission': 'granted'}
            : false,
      );
      messenger.setMockMethodCallHandler(
        const MethodChannel('com.gpscamera.pin_shutter/platform'),
        (call) async => call.method == 'dirs'
            ? {'support': directory.path, 'documents': directory.path}
            : null,
      );
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(padding: const EdgeInsets.only(top: 24, bottom: 24)),
            child: child!,
          ),
          home: const CameraScreen(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));
      for (final ratio in CaptureRatio.values) {
        SettingsController.instance.update(
          () => SettingsController.instance.captureRatio = ratio,
        );
        await tester.pump();
        final preview = tester.getRect(find.byType(CameraLayer));
        expect(preview.top, 24 + 64, reason: ratio.name);
        expect(
          preview.bottom,
          lessThanOrEqualTo(size.height - 24 - 8 - CameraControlBar.height),
          reason: ratio.name,
        );
        if (ratio.portraitWH != null) {
          expect(
            preview.width / preview.height,
            closeTo(ratio.portraitWH!, .001),
          );
        }
      }
      if (mockOmitted) {
        tester.binding.channelBuffers.push(
          'com.gpscamera.pin_shutter/positions',
          const StandardMethodCodec().encodeSuccessEnvelope({
            'lat': 12.0,
            'lon': 77.0,
            'accuracy': 5.0,
            'time': DateTime.now().millisecondsSinceEpoch,
            'isMock': true,
          }),
          (_) {},
        );
        await tester.pump();
      }
      expect(tester.takeException(), isNull);
      expect(
        tester.getCenter(find.bySemanticsLabel('GPS stamp settings')).dx,
        greaterThan(tester.getCenter(find.bySemanticsLabel('Take photo')).dx),
      );
      await tester.tap(find.bySemanticsLabel('GPS stamp settings'));
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('Burn into capture'), findsOneWidget);
      if (mockOmitted) {
        expect(find.text('Mock location detected'), findsOneWidget);
        expect(find.text('GPS omitted'), findsOneWidget);
        expect(find.text('Weak GPS signal'), findsNothing);
      }
      await tester.tap(find.text('Template'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Stamp designs'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Advanced'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.tap(find.bySemanticsLabel('GPS stamp settings'));
      await tester.pump(const Duration(milliseconds: 200));
      await tester.tap(find.text('Burn into capture'));
      await tester.pump();
      expect(SettingsController.instance.stampEnabled, isFalse);
      await tester.tap(find.bySemanticsLabel('Close camera menu'));
      await tester.pump();
      expect(find.text('Burn into capture'), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    });
  }
}
