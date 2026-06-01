import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('data and domain layers do not import presentation layer code', () {
    final featureRoot = Directory('lib/features');
    final files = featureRoot
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'))
        .where(
          (file) =>
              file.path.contains('/data/') || file.path.contains('/domain/'),
        );

    final violations = <String>[];
    for (final file in files) {
      final lines = file.readAsLinesSync();
      for (var index = 0; index < lines.length; index++) {
        final line = lines[index].trim();
        if (!line.startsWith('import ')) continue;
        if (line.contains('/presentation/') ||
            line.contains('../presentation/') ||
            line.contains('../../presentation/')) {
          violations.add('${file.path}:${index + 1}: $line');
        }
      }
    }

    expect(violations, isEmpty, reason: violations.join('\n'));
  });
}
