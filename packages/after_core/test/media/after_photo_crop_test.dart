import 'dart:typed_data';

import 'package:after_core/after_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AfterPhotoCropScreen', () {
    test('profileAspectRatio is square', () {
      expect(AfterPhotoCropScreen.profileAspectRatio, 1);
    });

    testWidgets('mounts with title and save action', (tester) async {
      final png = Uint8List.fromList(<int>[
        0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
        0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
        0x08, 0x02, 0x00, 0x00, 0x00, 0x90, 0x77, 0x53, 0xDE, 0x00, 0x00, 0x00,
        0x0C, 0x49, 0x44, 0x41, 0x54, 0x08, 0xD7, 0x63, 0xF8, 0xCF, 0xC0, 0x00,
        0x00, 0x00, 0x03, 0x00, 0x01, 0x00, 0x05, 0xFE, 0x02, 0xFE, 0x00, 0x00,
        0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
      ]);

      await tester.pumpWidget(
        MaterialApp(
          home: AfterPhotoCropScreen(
            imageBytes: png,
            aspectRatio: AfterPhotoCropScreen.profileAspectRatio,
            copy: AfterPhotoCropCopy.english(),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Adjust photo'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
      expect(find.byType(AfterPhotoCropScreen), findsOneWidget);
    });
  });
}
