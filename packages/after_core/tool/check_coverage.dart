#!/usr/bin/env dart
// Coverage gate — Usage: dart tool/check_coverage.dart [min_percent] [lcov_path]
import 'dart:io';

const _defaultMinPercent = 50.0;

bool _shouldExcludeFromGate(String sourcePath) {
  final normalized = sourcePath.replaceAll(r'\', '/').toLowerCase();
  if (!normalized.startsWith('lib/') && !normalized.contains('/lib/')) {
    return true;
  }
  if (normalized.endsWith('.g.dart')) return true;
  return false;
}

({int found, int hit}) _parseLcov(String contents, {required bool applyExclusions}) {
  var linesFound = 0;
  var linesHit = 0;
  var excludeCurrent = false;
  for (final rawLine in contents.split('\n')) {
    final line = rawLine.trim();
    if (line.startsWith('SF:')) {
      excludeCurrent =
          applyExclusions && _shouldExcludeFromGate(line.substring(3));
      continue;
    }
    if (excludeCurrent) continue;
    if (line.startsWith('LF:')) {
      linesFound += int.parse(line.substring(3));
    } else if (line.startsWith('LH:')) {
      linesHit += int.parse(line.substring(3));
    }
  }
  return (found: linesFound, hit: linesHit);
}

void main(List<String> args) {
  final minPercent =
      args.isNotEmpty ? double.parse(args[0]) : _defaultMinPercent;
  final lcovPath = args.length > 1 ? args[1] : 'coverage/lcov.info';
  final file = File(lcovPath);
  if (!file.existsSync()) {
    stderr.writeln('Coverage file not found: $lcovPath');
    exit(1);
  }
  final gated = _parseLcov(file.readAsStringSync(), applyExclusions: true);
  if (gated.found == 0) {
    stderr.writeln('No gated line coverage data');
    exit(1);
  }
  final percent = (gated.hit / gated.found) * 100;
  stdout.writeln(
    'Coverage (gate): ${gated.hit}/${gated.found} (${percent.toStringAsFixed(1)}%)',
  );
  if (percent + 0.0001 < minPercent) {
    stderr.writeln('Below minimum $minPercent%');
    exit(1);
  }
  stdout.writeln('Coverage gate passed (>= $minPercent%).');
}
