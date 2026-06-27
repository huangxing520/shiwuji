import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../database/database.dart';
import '../daos/item_dao.dart';
import '../daos/room_dao.dart';
import '../daos/cabinet_dao.dart';
import '../daos/slot_dao.dart';
import '../daos/space_item_dao.dart';
import '../daos/import_history_dao.dart';
import '../daos/category_dao.dart';
import '../daos/settings_dao.dart';

part 'generated/database_provider.g.dart';

/// 数据库实例 Provider
@riverpod
AppDatabase database(Ref ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
}

/// DAO Providers
@riverpod
ItemDao itemDao(Ref ref) => ItemDao(ref.watch(databaseProvider));

@riverpod
RoomDao roomDao(Ref ref) => RoomDao(ref.watch(databaseProvider));

@riverpod
CabinetDao cabinetDao(Ref ref) => CabinetDao(ref.watch(databaseProvider));

@riverpod
SlotDao slotDao(Ref ref) => SlotDao(ref.watch(databaseProvider));

@riverpod
SpaceItemDao spaceItemDao(Ref ref) =>
    SpaceItemDao(ref.watch(databaseProvider));

@riverpod
ImportHistoryDao importHistoryDao(Ref ref) =>
    ImportHistoryDao(ref.watch(databaseProvider));

@riverpod
CategoryDao categoryDao(Ref ref) => CategoryDao(ref.watch(databaseProvider));

@riverpod
SettingsDao settingsDao(Ref ref) => SettingsDao(ref.watch(databaseProvider));
