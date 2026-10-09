import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shi_wu_ji/database/database.dart';

/// 迁移回归测试：验证「老版本数据库升级上来后结构完整」（A1）。
///
/// 背景（见 docs/CODE_REVIEW-2026-10-09.md 的 A1）：
/// 历史上 schemaVersion 被回退过（4 → 9 → 1 → 2），而且同一数字对应过
/// 多套不同结构，所以线上存在各种「半吊子」数据库。修复方案刻意不依赖
/// 版本号，而是打开时按**实际结构**补齐缺失的表/列。因此这里用
/// 「按历史结构建库 + 设 user_version」来模拟每一代老库。
void main() {
  /// 某表的实际列名（来自 sqlite 自身，而不是代码定义）。
  Future<Set<String>> columnsOf(AppDatabase db, String table) async {
    final rows = await db.customSelect('PRAGMA table_info("$table")').get();
    return {for (final row in rows) row.read<String>('name')};
  }

  Future<Set<String>> tablesOf(AppDatabase db) async {
    final rows = await db
        .customSelect("SELECT name FROM sqlite_master WHERE type = 'table'")
        .get();
    return {for (final row in rows) row.read<String>('name')};
  }

  /// 内存库 + 老结构。
  ///
  /// [setup] 回调的调用时机已确认早于 drift 读取 user_version，
  /// 因此可以在其中把库造成老版本形态，drift 会把它当作「已存在的旧库」。
  AppDatabase memoryDbFromOldSchema(
    List<String> schemaSql, {
    required int userVersion,
  }) {
    return AppDatabase(
      NativeDatabase.memory(
        setup: (db) {
          for (final sql in schemaSql) {
            db.execute(sql);
          }
          db.execute('PRAGMA user_version = $userVersion');
        },
      ),
    );
  }

  /// 文件库 + 老结构，用于「关闭后重新打开」的场景。
  AppDatabase fileDbFromOldSchema(
    File file,
    List<String> schemaSql, {
    required int userVersion,
  }) {
    return AppDatabase(
      NativeDatabase(
        file,
        setup: (db) {
          for (final sql in schemaSql) {
            db.execute(sql);
          }
          db.execute('PRAGMA user_version = $userVersion');
        },
      ),
    );
  }

  // ── 历史结构定义 ────────────────────────────────

  /// v1.0.0 时代的 items：12 列，缺 photos/brand/note/templateKey/templateData
  /// 以及后续所有新增列。
  const v100Items = '''
    CREATE TABLE items (
      id TEXT NOT NULL PRIMARY KEY,
      name TEXT NOT NULL,
      price REAL NOT NULL,
      emoji TEXT NOT NULL DEFAULT '',
      category TEXT NOT NULL DEFAULT '未分类',
      location TEXT NOT NULL DEFAULT '未知',
      purchase_date INTEGER NOT NULL,
      warranty_days INTEGER NOT NULL DEFAULT 365,
      status TEXT NOT NULL DEFAULT 'safe',
      category_key TEXT NOT NULL DEFAULT '',
      cabinet_id TEXT,
      slot_id TEXT
    );
  ''';

  /// v1.0.0 时代的其余各表（cabinets 无 photo_path、slots 无 expected_items）。
  const v100Rest = [
    '''
      CREATE TABLE rooms (
        id TEXT NOT NULL PRIMARY KEY, name TEXT NOT NULL,
        emoji TEXT NOT NULL, color INTEGER NOT NULL);
    ''',
    '''
      CREATE TABLE cabinets (
        id TEXT NOT NULL PRIMARY KEY, name TEXT NOT NULL,
        emoji TEXT NOT NULL, color INTEGER NOT NULL,
        room_id TEXT NOT NULL, has_photo INTEGER NOT NULL DEFAULT 0);
    ''',
    '''
      CREATE TABLE slots (
        id TEXT NOT NULL PRIMARY KEY, name TEXT NOT NULL,
        emoji TEXT NOT NULL, color INTEGER NOT NULL,
        cabinet_id TEXT NOT NULL);
    ''',
    '''
      CREATE TABLE space_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT, emoji TEXT NOT NULL,
        name TEXT NOT NULL, meta TEXT NOT NULL, slot_id TEXT NOT NULL);
    ''',
    '''
      CREATE TABLE import_history (
        id TEXT NOT NULL PRIMARY KEY, platform_key TEXT NOT NULL,
        emoji TEXT NOT NULL, title TEXT NOT NULL, meta TEXT NOT NULL,
        count INTEGER NOT NULL, icon_bg INTEGER NOT NULL,
        imported_at INTEGER NOT NULL);
    ''',
    '''
      CREATE TABLE categories (
        id TEXT NOT NULL PRIMARY KEY, label TEXT NOT NULL,
        emoji TEXT NOT NULL, is_built_in INTEGER NOT NULL DEFAULT 0,
        sort_order INTEGER NOT NULL DEFAULT 0);
    ''',
    '''
      CREATE TABLE settings (
        key TEXT NOT NULL PRIMARY KEY, value TEXT NOT NULL);
    ''',
  ];

  /// v1.0.4 时代的 items：已有 photos/brand/note/templateKey/templateData，
  /// 但没有 shelfLifeDays/source/*ReminderOn/maintenanceCycle/isBorrowed。
  const v104Items = '''
    CREATE TABLE items (
      id TEXT NOT NULL PRIMARY KEY, name TEXT NOT NULL,
      price REAL NOT NULL, emoji TEXT NOT NULL DEFAULT '',
      category TEXT NOT NULL DEFAULT '未分类',
      location TEXT NOT NULL DEFAULT '未知',
      purchase_date INTEGER NOT NULL,
      warranty_days INTEGER NOT NULL DEFAULT 365,
      status TEXT NOT NULL DEFAULT 'safe',
      category_key TEXT NOT NULL DEFAULT '',
      cabinet_id TEXT, slot_id TEXT,
      photos TEXT NOT NULL DEFAULT '[]', brand TEXT NOT NULL DEFAULT '',
      note TEXT NOT NULL DEFAULT '',
      template_key TEXT NOT NULL DEFAULT 'none',
      template_data TEXT NOT NULL DEFAULT '{}');
  ''';

  group('A1 老库升级：结构必须补齐且不丢数据', () {
    test('v1.0.0 形态（db=4）升级后补齐全部缺失列', () async {
      final db = memoryDbFromOldSchema([
        v100Items,
        ...v100Rest,
        "INSERT INTO items (id, name, price, purchase_date) "
            "VALUES ('i1', '老物品', 100.0, 1700000000000);",
      ], userVersion: 4);
      addTearDown(db.close);

      final cols = await columnsOf(db, 'items');
      // v1.0.3 引入的 5 列
      for (final c in [
        'photos',
        'brand',
        'note',
        'template_key',
        'template_data',
      ]) {
        expect(cols.contains(c), isTrue, reason: 'items 缺列未补: $c');
      }
      // v1.0.6 起引入的列
      for (final c in [
        'shelf_life_days',
        'source',
        'warranty_reminder_on',
        'shelf_life_reminder_on',
        'maintenance_reminder_on',
        'maintenance_cycle',
      ]) {
        expect(cols.contains(c), isTrue, reason: 'items 缺列未补: $c');
      }
      // v1.0.8 引入
      expect(cols.contains('is_borrowed'), isTrue, reason: 'items 缺 is_borrowed');

      // 其它表在后续版本新增的列
      expect((await columnsOf(db, 'cabinets')).contains('photo_path'), isTrue);
      expect((await columnsOf(db, 'slots')).contains('expected_items'), isTrue);

      // 老数据保留
      final items = await db.select(db.items).get();
      expect(items.length, 1);
      expect(items.single.name, '老物品');
    });

    test('v1.0.4 形态（db=1，历史回退值）也能补齐并建出缺表', () async {
      final db = memoryDbFromOldSchema([v104Items], userVersion: 1);
      addTearDown(db.close);

      final cols = await columnsOf(db, 'items');
      expect(cols.contains('is_borrowed'), isTrue);
      expect(cols.contains('shelf_life_days'), isTrue);

      // 缺失的整张表应被建出来
      final tables = await tablesOf(db);
      for (final t in [
        'rooms',
        'cabinets',
        'slots',
        'categories',
        'settings',
      ]) {
        expect(tables.contains(t), isTrue, reason: '缺表未建: $t');
      }
      // 新建的 categories 应有内置分类种子（不能是空表）
      expect(await db.select(db.categories).get(), isNotEmpty);
    });

    test('修复幂等：老库关闭后重新打开不报错、结构稳定', () async {
      final dir = Directory.systemTemp.createTempSync('wupin_mig_');
      final file = File('${dir.path}/shiwuji.sqlite');

      const oldSchema = '''
        CREATE TABLE items (
          id TEXT NOT NULL PRIMARY KEY, name TEXT NOT NULL,
          price REAL NOT NULL, purchase_date INTEGER NOT NULL);
      ''';

      // 第一次打开：触发 onUpgrade → 结构修复
      final db1 = fileDbFromOldSchema(file, [oldSchema], userVersion: 2);
      final first = await columnsOf(db1, 'items');
      expect(first.contains('is_borrowed'), isTrue);
      await db1.close();

      // 第二次打开：同版本打开，走 beforeOpen 自检，必须不报错
      final db2 = AppDatabase(NativeDatabase(file));
      final second = await columnsOf(db2, 'items');
      expect(second, first, reason: '重复打开不应改变结构');
      await db2.close();
      // 关闭后再删临时目录，避免 Windows 上「文件被占用」删不掉
      try {
        dir.deleteSync(recursive: true);
      } catch (_) {}
    });
  });

  group('全新安装与种子数据', () {
    test('onCreate 会写入分类/设置/房间，且不预置物品', () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);

      expect(await db.select(db.categories).get(), isNotEmpty);
      expect(await db.select(db.settings).get(), isNotEmpty);
      expect(await db.select(db.rooms).get(), isNotEmpty);
      expect(await db.select(db.items).get(), isEmpty);
    });

    test('用户删光房间后重开不会被种子数据复活', () async {
      // 守护 _repairSchema 的种子策略：只在「本次新建表」时补种子，
      // 绝不因「表为空」而补，否则用户主动删除的数据会复活。
      final dir = Directory.systemTemp.createTempSync('wupin_seed_');
      final file = File('${dir.path}/shiwuji.sqlite');

      final db1 = AppDatabase(NativeDatabase(file));
      expect(await db1.select(db1.rooms).get(), isNotEmpty);
      // 删除顺序必须子 → 父：开启 PRAGMA foreign_keys 后，
      // 仍有子行时删父行会触发 FK 约束失败。
      await db1.delete(db1.slots).go();
      await db1.delete(db1.cabinets).go();
      await db1.delete(db1.rooms).go();
      await db1.close();

      final db2 = AppDatabase(NativeDatabase(file));
      expect(
        await db2.select(db2.rooms).get(),
        isEmpty,
        reason: '用户删除的房间不应在下次启动被重新写入',
      );
      await db2.close();
      // 关闭后再删临时目录，避免 Windows 上「文件被占用」删不掉
      try {
        dir.deleteSync(recursive: true);
      } catch (_) {}
    });
  });
}
