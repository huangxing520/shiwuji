import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

// 表定义（part files）
part 'tables/items_table.dart';
part 'tables/rooms_table.dart';
part 'tables/cabinets_table.dart';
part 'tables/slots_table.dart';
part 'tables/space_items_table.dart';
part 'tables/import_history_table.dart';
part 'tables/categories_table.dart';
part 'tables/settings_table.dart';

// 种子数据
part 'seed_data.dart';

// 代码生成
part 'generated/database.g.dart';

@DriftDatabase(tables: [
  Items,
  Rooms,
  Cabinets,
  Slots,
  SpaceItems,
  ImportHistory,
  Categories,
  Settings,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          if (from < 2) {
            await m.createTable(categories);
          }
          if (from < 3) {
            await m.createTable(settings);
          }
          if (from < 4) {
            await m.addColumn(items, items.cabinetId);
            await m.addColumn(items, items.slotId);
          }
        },
        beforeOpen: (details) async {
          if (details.wasCreated) {
            await _seedDatabase();
          }
          // v2 升级时补充内置分类种子
          if (details.hadUpgrade && details.versionBefore! < 2) {
            await _seedCategories();
          }
          // v3 升级时补充默认用户设置
          if (details.hadUpgrade && details.versionBefore! < 3) {
            await _seedSettings();
          }
        },
      );

  Future<void> _seedDatabase() async {
    await batch((b) {
      b.insertAll(items, SeedData.items);
      b.insertAll(rooms, SeedData.rooms);
      b.insertAll(cabinets, SeedData.cabinets);
      b.insertAll(slots, SeedData.slots);
      b.insertAll(spaceItems, SeedData.spaceItems);
      b.insertAll(importHistory, SeedData.importHistory);
      b.insertAll(categories, SeedData.categories);
      b.insertAll(settings, SeedData.settings);
    });
  }

  Future<void> _seedCategories() async {
    await batch((b) {
      b.insertAll(categories, SeedData.categories);
    });
  }

  Future<void> _seedSettings() async {
    await batch((b) {
      b.insertAll(settings, SeedData.settings);
    });
  }

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'shiwuji',
      native: const DriftNativeOptions(
        databaseDirectory: getApplicationSupportDirectory,
      ),
    );
  }
}
