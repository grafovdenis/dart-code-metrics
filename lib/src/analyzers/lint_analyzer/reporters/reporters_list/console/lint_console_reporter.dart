import 'dart:io';

import '../../../../../reporters/models/console_reporter.dart';
import '../../../metrics/metric_utils.dart';
import '../../../metrics/models/metric_value.dart';
import '../../../metrics/models/metric_value_level.dart';
import '../../../models/issue.dart';
import '../../../models/lint_file_report.dart';
import '../../../models/report.dart';
import 'lint_console_reporter_helper.dart';

class LintConsoleReporter extends ConsoleReporter<LintFileReport> {
  /// If true will report info about all files even if they're not above warning threshold
  final bool reportAll;

  final _helper = LintConsoleReporterHelper();

  LintConsoleReporter(IOSink output, {this.reportAll = false}) : super(output);

  @override
  Future<void> report(Iterable<LintFileReport> records) async {
    if (records.isEmpty) {
      return;
    }

    for (final file in records) {
      final lines = [
        ..._reportIssues([...file.issues, ...file.antiPatternCases]),
        ..._reportMetrics({...file.classes, ...file.functions}),
      ];

      if (lines.isNotEmpty) {
        output.writeln('${file.relativePath}:');
        lines.forEach(output.writeln);
        output.writeln('');
      }
    }
  }

  Iterable<String> _reportIssues(Iterable<Issue> issues) => (issues.toList()
        ..sort((a, b) =>
            a.location.start.offset.compareTo(b.location.start.offset)))
      .map(_helper.getIssueMessage);

  Iterable<String> _reportMetrics(Map<String, Report> reports) =>
      (reports.entries.toList()
            ..sort((a, b) => a.value.location.start.offset
                .compareTo(b.value.location.start.offset)))
          .expand((entry) {
        final source = entry.key;
        final report = entry.value;

        final reportLevel = report.metricsLevel;
        if (reportAll || isReportLevel(reportLevel)) {
          final violations = [
            for (final metric in report.metrics)
              if (reportAll || _isNeedToReport(metric))
                _helper.getMetricReport(metric),
          ];

          return [
            _helper.getMetricMessage(reportLevel, source, violations),
          ];
        }

        return [];
      });

  bool _isNeedToReport(MetricValue metric) =>
      metric.level > MetricValueLevel.none;
}
