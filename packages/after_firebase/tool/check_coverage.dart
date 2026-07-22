#!/usr/bin/env dart
import 'dart:io';

const _defaultMinPercent = 50.0;

bool _shouldExclude(String sourcePath) {
  final n = sourcePath.replaceAll(r'\', '/').toLowerCase();
  if (!n.contains('/lib/') && !n.startsWith('lib/')) return true;
  if (n.endsWith('.g.dart')) return true;
  // Needs live Firebase / Google UI — covered by integration + unavailable-path unit tests.
  if (n.endsWith('firebase_after_auth_repository.dart')) return true;
  if (n.endsWith('firestore_after_user_blob_sync.dart')) return true;
  if (n.endsWith('placeholder_firebase_options.dart')) return true;
  return false;
}

({int found, int hit}) _parse(String contents) {
  var found = 0;
  var hit = 0;
  var exclude = false;
  for (final raw in contents.split('\n')) {
    final line = raw.trim();
    if (line.startsWith('SF:')) {
      exclude = _shouldExclude(line.substring(3));
      continue;
    }
    if (exclude) continue;
    if (line.startsWith('LF:')) found += int.parse(line.substring(3));
    if (line.startsWith('LH:')) hit += int.parse(line.substring(3));
  }
  return (found: found, hit: hit);
}

void main(List<String> args) {
  final min = args.isNotEmpty ? double.parse(args[0]) : _defaultMinPercent;
  final path = args.length > 1 ? args[1] : 'coverage/lcov.info';
  final file = File(path);
  if (!file.existsSync()) {
    stderr.writeln('Missing $path');
    exit(1);
  }
  final g = _parse(file.readAsStringSync());
  if (g.found == 0) {
    stderr.writeln('No coverage data');
    exit(1);
  }
  final pct = (g.hit / g.found) * 100;
  stdout.writeln('Coverage: ${g.hit}/${g.found} (${pct.toStringAsFixed(1)}%)');
  if (pct + 0.0001 < min) {
    stderr.writeln('Below $min%');
    exit(1);
  }
}
