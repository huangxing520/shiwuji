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

  /// 数据库结构版本。
  ///
  /// 注意：历史上这个数字被回退过（曾出现过 4 → 9 → 1 → 2），而且同一数字
  /// 对应过多套不同结构（`2` 既指 v1.0.5 也指 v1.0.8）。因此**不能**用
  /// `if (from < N)` 那种版本阶梯来判断缺什么列——`from == 2` 时无法区分
  /// 对方到底缺不缺 `shelfLifeDays`。
  ///
  /// 这里取历史最大值以上并只增不减，实际的结构修复由 [_repairSchema]
  /// 按「实际缺什么补什么」完成，不依赖版本号。
  static const int _schemaVersion = 10;

  @override
  int get schemaVersion => _schemaVersion;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
      await _ensureIndexes();
      await _seedDefaultData();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      // 升级/降级都走这里；具体补什么交给 _repairSchema 按实际结构判断。
      await _repairSchema(m);
    },
    beforeOpen: (details) async {
      // SQLite 默认 foreign_keys = OFF，表定义里的 REFERENCES 不生效。
      // 打开时开启，至少让新建库的外键约束（含 ON DELETE CASCADE）真正起作用。
      await customStatement('PRAGMA foreign_keys = ON');

      // 兜底：老版本曾把 schemaVersion 降到 1/2，却删掉了迁移逻辑。
      // 这类库打开时 drift 认为「无需迁移」，列缺失却无人补。
      // 只要不是全新库，就做一次结构自检，确保缺失的表/列/索引被补齐。
      if (!details.wasCreated) {
        await _repairSchema(createMigrator());
      }
    },
  );

  /// 结构自检与修复：对比「当前表定义」与「数据库实际结构」，
  /// 缺表补表、缺列补列、缺索引补索引。对任意历史起点都成立且可重复执行。
  ///
  /// 之所以不用版本号判断：见 [schemaVersion] 的说明——历史版本号来回跳，
  /// 同一数字对应过不同结构，无法据此推断缺哪些列。
  ///
  /// 安全性前提（已核对全部历史 tag）：历代 schema 的列都是当前 schema
  /// 的子集，没有出现过「旧版存在、新版删除」的列，因此本方法只补不删，
  /// 不会破坏既有数据。
  Future<void> _repairSchema(Migrator m) async {
    // 先补齐所有表/列，再补种子。
    // 顺序很重要：seed 默认空间数据会同时写入 rooms/cabinets/slots 三张表，
    // 若边建表边 seed，可能在建出 rooms 时 cabinets 尚不存在而报错。
    final created = <TableInfo>[];
    for (final table in allTables) {
      if (!await _tableExists(table.actualTableName)) {
        // 表不存在 → 整张建出来（更早的未发布结构可能缺表）
        await m.createTable(table);
        created.add(table);
        continue;
      }
      // 表在但缺列 → 逐列 ADD COLUMN
      final existing = await _existingColumns(table.actualTableName);
      for (final column in table.$columns) {
        if (!existing.contains(column.name)) {
          await m.addColumn(table, column);
        }
      }
    }

    await _ensureIndexes();

    // 仅为「本次刚建出来的表」补种子，避免建出来是空表（如分类列表为空）。
    // 默认空间数据需要三张表都在，所以放到全部建表之后统一处理。
    if (created.contains(rooms)) {
      await batch((b) {
        b.insertAll(rooms, SeedData.defaultRooms);
        b.insertAll(cabinets, SeedData.defaultCabinets);
        b.insertAll(slots, SeedData.defaultSlots);
      });
    }
    if (created.contains(categories)) {
      await batch((b) => b.insertAll(categories, SeedData.categories));
    }
    if (created.contains(settings)) {
      await batch((b) => b.insertAll(settings, SeedData.settings));
    }
  }

  /// 判断表是否已存在（sqlite_master 为准）。
  Future<bool> _tableExists(String name) async {
    final rows = await customSelect(
      "SELECT 1 FROM sqlite_master WHERE type = 'table' AND name = ? LIMIT 1",
      variables: [Variable.withString(name)],
    ).get();
    return rows.isNotEmpty;
  }

  /// 读取某表现有列名集合。
  Future<Set<String>> _existingColumns(String tableName) async {
    // PRAGMA 不支持参数绑定；表名来自代码内定义，非用户输入，无注入风险。
    final rows = await customSelect('PRAGMA table_info("$tableName")').get();
    return {for (final row in rows) row.read<String>('name')};
  }

  /// 高频过滤/关联列上的索引。
  ///
  /// 这些列被列表页筛选、空间统计与 getByCabinet/getByRoom 反复扫描，
  /// 物品量到千级后会明显变慢。
  ///
  /// 这里手写 `CREATE INDEX IF NOT EXISTS` 而不是用 `@TableIndex`：
  /// ① drift 为注解生成的 DDL 是不带 `IF NOT EXISTS` 的 `CREATE INDEX`，
  ///    重复执行会报错，因此仍需自行判存在；
  /// ② 一个表需要多个索引，而 `@TableIndex` 不可重复标注。
  /// 手写 SQL 同时覆盖新装库与老库（老库在 [_repairSchema] 中补齐）。
  static const List<String> _indexStatements = [
    'CREATE INDEX IF NOT EXISTS idx_items_cabinet_id '
        'ON items(cabinet_id)',
    'CREATE INDEX IF NOT EXISTS idx_items_slot_id ON items(slot_id)',
    'CREATE INDEX IF NOT EXISTS idx_items_category_key ON items(category_key)',
    'CREATE INDEX IF NOT EXISTS idx_items_purchase_date ON items(purchase_date)',
    'CREATE INDEX IF NOT EXISTS idx_cabinets_room_id ON cabinets(room_id)',
    'CREATE INDEX IF NOT EXISTS idx_slots_cabinet_id ON slots(cabinet_id)',
    'CREATE INDEX IF NOT EXISTS idx_space_items_slot_id ON space_items(slot_id)',
  ];

  /// 幂等地补建索引（`IF NOT EXISTS` 本身保证可重复执行）。
  Future<void> _ensureIndexes() async {
    for (final statement in _indexStatements) {
      await customStatement(statement);
    }
  }

  /// 首次安装时写入默认种子数据：
  /// - 12 个内置分类
  /// - 2 项默认用户设置
  /// - 3 个默认收纳空间（卧室、厨房、客厅），含柜体结构和区域划分
  ///
  /// 不预置任何物品（Items）、空间物品（SpaceItems）或导入历史（ImportHistory）。
  Future<void> _seedDefaultData() async {
    await batch((b) {
      b.insertAll(categories, SeedData.categories);
      b.insertAll(settings, SeedData.settings);
      b.insertAll(rooms, SeedData.defaultRooms);
      b.insertAll(cabinets, SeedData.defaultCabinets);
      b.insertAll(slots, SeedData.defaultSlots);
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
