import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

import '../models/emoji_classifier.dart';

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

@DriftDatabase(
  tables: [
    Items,
    Rooms,
    Cabinets,
    Slots,
    SpaceItems,
    ImportHistory,
    Categories,
    Settings,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 9;

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
      if (from < 5) {
        await m.addColumn(items, items.photos);
        await m.addColumn(items, items.brand);
        await m.addColumn(items, items.note);
        await m.addColumn(items, items.templateKey);
        await m.addColumn(items, items.templateData);
      }
    },
    beforeOpen: (details) async {
      if (details.wasCreated) {
        await _seedDatabase();
        // 新建数据库后立即填充物品的柜体/格子关联
        await _migrateItemsToSlots();
      }
      // v2 升级时补充内置分类种子
      if (details.hadUpgrade && details.versionBefore! < 2) {
        await _seedCategories();
      }
      // v3 升级时补充默认用户设置
      if (details.hadUpgrade && details.versionBefore! < 3) {
        await _seedSettings();
      }
      // v8 升级时重新 classify items 表 emoji，修正 emoji 与物品大类不符的问题
      if (details.hadUpgrade && details.versionBefore! < 8) {
        await _reclassifyItemsEmoji();
      }
      // v9 升级时补全物品的柜体/格子关联
      if (details.hadUpgrade && details.versionBefore! < 9) {
        await _migrateItemsToSlots();
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

  /// v8 迁移：重新 classify items 表的 emoji，确保 emoji 符合物品大类。
  ///
  /// 修正历史遗留问题：部分物品 emoji 基于名字联想设置（如"乐高"→积木🧱），
  /// 但物品本质属于其他大类（如书籍），导致 emoji 与分类不符。
  /// 此迁移根据每条记录的 categoryKey 和 name 重新调用 EmojiClassifier.classify，
  /// 生成符合大类的 emoji。
  Future<void> _reclassifyItemsEmoji() async {
    final rows = await select(items).get();
    for (final row in rows) {
      final key = row.categoryKey;
      if (key.isEmpty) continue;
      final newEmoji = EmojiClassifier.classify(
        mainCategoryKey: key,
        content: row.name,
      );
      if (newEmoji != row.emoji) {
        await (items.update()..where((t) => t.id.equals(row.id))).write(
          ItemsCompanion(emoji: Value(newEmoji)),
        );
      }
    }
  }

  /// v9 迁移：补全所有物品的柜体/格子关联，确保收纳位置细分到格子级别。
  ///
  /// 策略：
  /// 1. 保证至少存在一个房间 → 柜体 → 格子的默认链路；
  /// 2. 对于 cabinetId 为 null 的物品，统一挂到默认柜体下；
  /// 3. 对于 slotId 为 null 的物品，在其柜体下创建默认格子并挂载；
  /// 4. 同步更新 location 字段为"房间 / 柜体 / 格子"路径格式。
  Future<void> _migrateItemsToSlots() async {
    // ── 1. 确保默认房间存在 ──
    final existingRooms = await select(rooms).get();
    String defaultRoomId;
    if (existingRooms.isNotEmpty) {
      defaultRoomId = existingRooms.first.id;
    } else {
      defaultRoomId = 'room_default_v9';
      await into(rooms).insert(
        RoomsCompanion.insert(
          id: defaultRoomId,
          name: '默认房间',
          emoji: '🏠',
          color: 0xFFFFE8CC,
        ),
      );
    }

    // ── 2. 收集所有物品，分组处理 ──
    final allItems = await select(items).get();

    // 需要柜体的物品（cabinetId 为 null）
    final itemsNeedCabinet = allItems
        .where((i) => i.cabinetId == null)
        .toList();

    String defaultCabinetId;

    if (itemsNeedCabinet.isNotEmpty) {
      // 创建/复用默认柜体
      defaultCabinetId = 'cabinet_default_v9';
      final existing = await (select(
        cabinets,
      )..where((t) => t.id.equals(defaultCabinetId))).getSingleOrNull();
      if (existing == null) {
        await into(cabinets).insert(
          CabinetsCompanion.insert(
            id: defaultCabinetId,
            name: '默认柜体',
            emoji: '🗄️',
            color: 0xFFFFE8CC,
            roomId: defaultRoomId,
          ),
        );
      }
      // 批量给缺失柜体的物品赋值
      for (final item in itemsNeedCabinet) {
        await (update(items)..where((t) => t.id.equals(item.id))).write(
          ItemsCompanion(cabinetId: const Value('cabinet_default_v9')),
        );
      }
    } else {
      // 所有物品都有 cabinetId，取第一条物品的 cabinetId 作为默认
      defaultCabinetId = allItems.first.cabinetId!;
    }

    // ── 3. 收集所有出现过的柜体，为其无格子的物品创建默认格子 ──
    // 重新获取数据以包含刚赋值的 cabinetId
    final refreshedItems = await select(items).get();
    final cabinetIds = <String>{};
    for (final item in refreshedItems) {
      if (item.cabinetId != null && item.slotId == null) {
        cabinetIds.add(item.cabinetId!);
      }
    }

    for (final cabId in cabinetIds) {
      // 查询该柜体所属房间（用于生成 location 路径）
      final cab = await (select(
        cabinets,
      )..where((t) => t.id.equals(cabId))).getSingleOrNull();
      if (cab == null) continue;

      final room = await (select(
        rooms,
      )..where((t) => t.id.equals(cab.roomId))).getSingleOrNull();

      // 创建/复用该柜体下的默认格子
      final slotId = 'slot_default_$cabId';
      final existingSlot = await (select(
        slots,
      )..where((t) => t.id.equals(slotId))).getSingleOrNull();
      if (existingSlot == null) {
        await into(slots).insert(
          SlotsCompanion.insert(
            id: slotId,
            name: '默认区域',
            emoji: '📦',
            color: cab.color,
            cabinetId: cabId,
          ),
        );
      }

      // 将该柜体下无格子的物品全部挂到此默认格子
      final roomName = room?.name ?? '默认房间';
      final cabName = cab.name;
      final locationLabel = '$roomName / $cabName / 默认区域';

      final itemsInCab = await (select(
        items,
      )..where((t) => t.cabinetId.equals(cabId) & t.slotId.isNull())).get();

      for (final item in itemsInCab) {
        await (update(items)..where((t) => t.id.equals(item.id))).write(
          ItemsCompanion(slotId: Value(slotId), location: Value(locationLabel)),
        );
      }
    }
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
