import 'dart:io';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class MigrationRunner {
  static Future<void> run(Database db) async {
    final dir = Directory('migrations');
    if (!await dir.exists()) return;

    final files = await dir
        .list()
        .where((f) => f.path.endsWith('.sql'))
        .toList();
    files.sort((a, b) => a.path.compareTo(b.path));

    for (final file in files) {
      final sql = await File(file.path).readAsString();
      for (final stmt in sql.split(';')) {
        final trimmed = stmt.trim();
        if (trimmed.isNotEmpty) {
          await db.execute(trimmed);
        }
      }
    }
  }
}
