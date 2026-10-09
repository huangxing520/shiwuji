import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shi_wu_ji/daos/cabinet_dao.dart';
import 'package:shi_wu_ji/daos/room_dao.dart';
import 'package:shi_wu_ji/daos/slot_dao.dart';
import 'package:shi_wu_ji/database/database.dart';

/// A2/A3 回归测试：
/// - A2：删除房间/柜体/格子必须级联清掉其下的子结构与物品，不留孤儿行。
/// - A3：高频过滤/关联列上必须存在索引。
///
/// 见 docs/CODE_REVIEW-2026-10-09.md 的 A2 / A3。
void main() {
  /// 用内存库建一个「房间 → 柜体 → 格子 → 物品」的完整链路。
  ///
  /// 注意：onCreate 会写入种子数据（3 个默认房间及其柜体/格子），
  /// 因此断言必须基于「相对变化」，不能假设库里只有我们建的那几个。
  Future<AppDatabase> buildTree({bool withSpaceItem = true}) async {
    final db = AppDatabase(NativeDatabase.memory());
    await db.customStatement('PRAGMA foreign_keys = ON');
    // 触发打开（跑 onCreate + 索引）
    await db.select(db.rooms).get();

    // 清掉种子数据，让断言可以精确计数
    await db.delete(db.spaceItems).go();
    await db.delete(db.items).go();
    await db.delete(db.slots).go();
    await db.delete(db.cabinets).go();
    await db.delete(db.rooms).go();

    await db.into(db.rooms).insert(
      RoomsCompanion.insert(id: 'r1', name: '书房', emoji: '📚', color: 1),
    );
    await db.into(db.cabinets).insert(
      CabinetsCompanion.insert(
        id: 'c1',
        name: '木柜',
        emoji: '🗄️',
        color: 1,
        roomId: 'r1',
      ),
    );
    await db.into(db.slots).insert(
      SlotsCompanion.insert(
        id: 's1',
        name: '第一格',
        emoji: '📦',
        color: 1,
        cabinetId: 'c1',
      ),
    );
    // 主物品：一格挂在格子上，一条只挂在柜体上
    await db.into(db.items).insert(
      ItemsCompanion.insert(
        id: 'i1',
        name: '格内物品',
        price: 10,
        purchaseDate: DateTime(2024, 1, 1),
        cabinetId: const Value('c1'),
        slotId: const Value('s1'),
      ),
    );
    await db.into(db.items).insert(
      ItemsCompanion.insert(
        id: 'i2',
        name: '柜内物品',
        price: 20,
        purchaseDate: DateTime(2024, 1, 1),
        cabinetId: const Value('c1'),
      ),
    );
    if (withSpaceItem) {
      await db.into(db.spaceItems).insert(
        SpaceItemsCompanion.insert(
          emoji: '🔖',
          name: '格位物品',
          meta: 'meta',
          slotId: 's1',
        ),
      );
    }
    return db;
  }

  Future<Map<String, int>> rowCounts(AppDatabase db) async {
    Future<int> count(TableInfo t) async {
      final row = await db
          .customSelect('SELECT COUNT(*) AS c FROM ${t.actualTableName}')
          .getSingle();
      return row.read<int>('c');
    }

    return {
      'rooms': await count(db.rooms),
      'cabinets': await count(db.cabinets),
      'slots': await count(db.slots),
      'items': await count(db.items),
      'space_items': await count(db.spaceItems),
    };
  }

  group('A2 级联删除：不留下孤儿行', () {
    test('删除房间会级联清掉柜体/格子/物品/格位物品', () async {
      final db = await buildTree();
      addTearDown(db.close);

      final before = await rowCounts(db);
      expect(before['rooms'], 1);
      expect(before['items'], 2, reason: '准备数据：应有 2 条物品');

      final dao = RoomDao(db);
      await dao.deleteRoom('r1');

      final after = await rowCounts(db);
      expect(after['rooms'], 0);
      expect(after['cabinets'], 0, reason: '房间删除后柜体成了孤儿');
      expect(after['slots'], 0, reason: '房间删除后格子成了孤儿');
      expect(after['items'], 0, reason: '房间删除后物品成了孤儿');
      expect(after['space_items'], 0, reason: '房间删除后格位物品成了孤儿');
    });

    test('删除柜体只清它自己的子树，不动其他柜体', () async {
      final db = await buildTree();
      addTearDown(db.close);
      // 另建一个不受影响的柜体（同房间）
      await db.into(db.cabinets).insert(
        CabinetsCompanion.insert(
          id: 'c2',
          name: '铁柜',
          emoji: '🗄️',
          color: 1,
          roomId: 'r1',
        ),
      );
      await db.into(db.slots).insert(
        SlotsCompanion.insert(
          id: 's2',
          name: '第二格',
          emoji: '📦',
          color: 1,
          cabinetId: 'c2',
        ),
      );

      await CabinetDao(db).deleteCabinet('c1');

      final after = await rowCounts(db);
      expect(after['rooms'], 1, reason: '房间不应被删除');
      expect(after['cabinets'], 1, reason: 'c2 应保留');
      expect(after['slots'], 1, reason: 's2 应保留');
      expect(after['items'], 0, reason: 'c1 下的物品应被清掉');
      expect(after['space_items'], 0);
    });

    test('删除格子清掉格内物品与格位物品，保留所属柜体', () async {
      final db = await buildTree();
      addTearDown(db.close);

      await SlotDao(db).deleteSlot('s1');

      final after = await rowCounts(db);
      expect(after['cabinets'], 1, reason: '柜体应保留');
      expect(after['slots'], 0);
      expect(after['space_items'], 0);
      // 只有挂在 s1 的 i1 被删；只挂柜体的 i2 仍在
      expect(after['items'], 1, reason: '仅柜体归属的物品不应被删');
    });
  });

  group('A3 索引', () {
    Future<Set<String>> indexNames(AppDatabase db) async {
      final rows = await db
          .customSelect(
            "SELECT name FROM sqlite_master WHERE type = 'index' "
            "AND name LIKE 'idx_%'",
          )
          .get();
      return {for (final row in rows) row.read<String>('name')};
    }

    test('新建库具备全部高频列索引', () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      await db.select(db.rooms).get(); // 触发打开

      final indexes = await indexNames(db);
      for (final expected in [
        'idx_items_cabinet_id',
        'idx_items_slot_id',
        'idx_items_category_key',
        'idx_items_purchase_date',
        'idx_cabinets_room_id',
        'idx_slots_cabinet_id',
        'idx_space_items_slot_id',
      ]) {
        expect(indexes.contains(expected), isTrue, reason: '缺索引 $expected');
      }
    });

    test('老库升级后同样补齐索引（幂等，可重复执行）', () async {
      final dir = Directory.systemTemp.createTempSync('wupin_idx_');
      final file = File('${dir.path}/shiwuji.sqlite');

      // 第一次打开：结构自检补建索引。
      // setup 参数类型由 NativeDatabase 推导，无需引入 sqlite3 的 Database 类型。
      final db1 = AppDatabase(
        NativeDatabase(
          file,
          setup: (raw) {
            raw.execute('''
              CREATE TABLE items (
                id TEXT NOT NULL PRIMARY KEY, name TEXT NOT NULL,
                price REAL NOT NULL, purchase_date INTEGER NOT NULL);
            ''');
            raw.execute('''
              CREATE TABLE rooms (
                id TEXT NOT NULL PRIMARY KEY, name TEXT NOT NULL,
                emoji TEXT NOT NULL, color INTEGER NOT NULL);
            ''');
            raw.execute('''
              CREATE TABLE cabinets (
                id TEXT NOT NULL PRIMARY KEY, name TEXT NOT NULL,
                emoji TEXT NOT NULL, color INTEGER NOT NULL,
                room_id TEXT NOT NULL, has_photo INTEGER NOT NULL DEFAULT 0);
            ''');
            raw.execute('''
              CREATE TABLE slots (
                id TEXT NOT NULL PRIMARY KEY, name TEXT NOT NULL,
                emoji TEXT NOT NULL, color INTEGER NOT NULL,
                cabinet_id TEXT NOT NULL);
            ''');
            raw.execute('''
              CREATE TABLE space_items (
                id INTEGER PRIMARY KEY AUTOINCREMENT, emoji TEXT NOT NULL,
                name TEXT NOT NULL, meta TEXT NOT NULL, slot_id TEXT NOT NULL);
            ''');
            raw.execute('''
              CREATE TABLE settings (
                key TEXT NOT NULL PRIMARY KEY, value TEXT NOT NULL);
            ''');
            raw.execute('PRAGMA user_version = 1');
          },
        ),
      );
      await db1.select(db1.rooms).get();
      final first = await indexNames(db1);
      expect(first.contains('idx_items_cabinet_id'), isTrue);
      expect(first.contains('idx_items_purchase_date'), isTrue);
      expect(first.contains('idx_space_items_slot_id'), isTrue);
      await db1.close();

      // 第二次打开：重复执行同样的 CREATE INDEX IF NOT EXISTS 不应报错
      final db2 = AppDatabase(NativeDatabase(file));
      await db2.select(db2.rooms).get();
      expect(await indexNames(db2), first, reason: '重复打开不应改变索引集合');
      await db2.close();
      // 关闭后再删临时目录，避免 Windows 上「文件被占用」删不掉
      try {
        dir.deleteSync(recursive: true);
      } catch (_) {}
    });
  });
}
