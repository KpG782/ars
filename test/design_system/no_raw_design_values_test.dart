import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('feature code does not use raw colors or font sizes', () {
    final root = Directory('lib');
    final files = root
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'))
        .where((file) => !file.path.startsWith('lib/core/theme/'));

    final forbidden = <String, RegExp>{
      'raw hex color': RegExp(r'Color\(0x[0-9A-Fa-f]{8}\)'),
      'raw semantic Material color': RegExp(
        r'Colors\.(red|green|orange|blue|grey)(\[[0-9]+\])?',
      ),
      'raw numeric font size': RegExp(r'fontSize:\s*[0-9]+(\.[0-9]+)?'),
    };

    final violations = <String>[];
    for (final file in files) {
      final lines = file.readAsLinesSync();
      for (var index = 0; index < lines.length; index++) {
        final line = lines[index];
        for (final entry in forbidden.entries) {
          if (entry.value.hasMatch(line)) {
            violations.add(
              '${file.path}:${index + 1}: ${entry.key}: ${line.trim()}',
            );
          }
        }
      }
    }

    expect(violations, isEmpty, reason: violations.take(80).join('\n'));
  });
}
