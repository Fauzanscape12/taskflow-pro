import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';
import 'database.dart';

/// Open database connection for Web
LazyDatabase _openWebConnection() {
  return LazyDatabase(() async {
    // Use drift WASM database for web
    final database = await WasmDatabase.open(
      databaseName: 'taskflow_pro',
      sqlite3Uri: Uri.base.resolve('sqlite3.wasm'),
      driftWorkerUri: Uri.base.resolve('drift_worker.js'),
    );
    return database.resolvedExecutor;
  });
}

/// Create AppDatabase for Web
AppDatabase createAppDatabase() => AppDatabase(_openWebConnection());
