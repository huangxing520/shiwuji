import 'package:drift/drift.dart';
import '../database/database.dart';

part 'generated/settings_dao.g.dart';

@DriftAccessor(tables: [Settings])
class SettingsDao extends DatabaseAccessor<AppDatabase>
    with _$SettingsDaoMixin {
  SettingsDao(super.db);

  /// 读取单个设置值
  Future<String?> getValue(String key) async {
    final row = await (select(settings)..where((t) => t.key.equals(key)))
        .getSingleOrNull();
    return row?.value;
  }

  /// 写入/更新单个设置
  Future<void> setValue(String key, String value) async {
    await into(settings).insertOnConflictUpdate(
      SettingsCompanion.insert(key: key, value: Value(value)),
    );
  }

  /// 获取所有设置
  Future<Map<String, String>> getAllSettings() async {
    final rows = await select(settings).get();
    return {for (final r in rows) r.key: r.value};
  }

  /// 批量写入
  Future<void> setAll(Map<String, String> kv) async {
    for (final entry in kv.entries) {
      await setValue(entry.key, entry.value);
    }
  }
}
