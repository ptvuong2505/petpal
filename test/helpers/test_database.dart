import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void initializeTestDatabase() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
}

Future<Directory> createTemporaryDatabaseDirectory() {
  return Directory.systemTemp.createTemp('petpal_database_test_');
}

String temporaryDatabasePath(Directory directory) {
  return p.join(directory.path, 'petpal_test.db');
}
