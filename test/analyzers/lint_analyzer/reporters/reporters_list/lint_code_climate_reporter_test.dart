import 'dart:io';

import 'package:dart_code_metrics/src/analyzers/lint_analyzer/reporters/reporters_list/code_climate/lint_code_climate_reporter.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'report_example.dart';

class IOSinkMock extends Mock implements IOSink {}

void main() {
  group('LintCodeClimateReporter.report report about', () {
    late IOSinkMock output; // ignore: close_sinks

    late LintCodeClimateReporter _reporter;

    setUp(() {
      output = IOSinkMock();

      _reporter = LintCodeClimateReporter(output);
    });

    test('empty report', () async {
      await _reporter.report([]);

      verifyNever(() => output.writeln(any()));
    });

    test('complex report', () async {
      await _reporter.report(testReport);

      final captured = verify(
        () => output.writeln(captureAny()),
      ).captured.cast<String>();

      expect(
        captured,
        equals(
          [
            '{"type":"issue","check_name":"id","description":"metric comment","categories":["Complexity"],"location":{"path":"test/resources/abstract_class.dart","positions":{"begin":{"line":0,"column":0},"end":{"line":0,"column":16}}},"severity":"info","fingerprint":"661469706d480a46dfeea856182f339f"}\x00',
            '{"type":"issue","check_name":"id","description":"simple message","categories":["Bug Risk"],"location":{"path":"test/resources/class_with_factory_constructors.dart","positions":{"begin":{"line":0,"column":0},"end":{"line":0,"column":20}}},"severity":"critical","fingerprint":"f25e877a3578c5d4433dfe131b9f98d0"}\x00',
            '{"type":"issue","check_name":"designId","description":"simple design message","categories":["Style"],"location":{"path":"test/resources/class_with_factory_constructors.dart","positions":{"begin":{"line":0,"column":0},"end":{"line":0,"column":20}}},"severity":"minor","fingerprint":"4eb25898669ab2a1c20db5d70e2edfb8"}\x00',
            '{"type":"issue","check_name":"id","description":"metric comment","categories":["Complexity"],"location":{"path":"test/resources/class_with_factory_constructors.dart","positions":{"begin":{"line":0,"column":0},"end":{"line":0,"column":20}}},"severity":"info","fingerprint":"b1abfce3f198adb690f6d40fc2aea6a5"}\x00',
          ],
        ),
      );
    });
  });
}
