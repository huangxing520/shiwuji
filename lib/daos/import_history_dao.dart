import 'package:drift/drift.dart';
import '../database/database.dart';

part 'generated/import_history_dao.g.dart';

@DriftAccessor(tables: [ImportHistory])
class ImportHistoryDao extends DatabaseAccessor<AppDatabase>
    with _$ImportHistoryDaoMixin {
  ImportHistoryDao(super.db);

  Future<List<ImportHistoryData>> getAll() =>
      (select(importHistory)
            ..orderBy([(t) => OrderingTerm.desc(t.importedAt)]))
          .get();

  Stream<List<ImportHistoryData>> watchAll() =>
      (select(importHistory)
            ..orderBy([(t) => OrderingTerm.desc(t.importedAt)]))
          .watch();

  Future<int> insert(ImportHistoryCompanion record) =>
      into(importHistory).insert(record);

  Future<int> deleteRecord(int id) =>
      (delete(importHistory)..where((t) => t.id.equals(id))).go();

  /// 统计总导入次数
  Future<int> totalCount() async {
    final result = await customSelect(
      'SELECT COUNT(*) AS total FROM import_history',
    ).get();
    return result.first.read<int>('total');
  }

  /// 统计总导入物品数
  Future<int> totalImportedItems() async {
    final result = await customSelect(
      'SELECT COALESCE(SUM(count), 0) AS total FROM import_history',
    ).get();
    return result.first.read<int>('total');
  }
}
