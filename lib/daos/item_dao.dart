import 'package:drift/drift.dart';
import '../database/database.dart';

part 'generated/item_dao.g.dart';

@DriftAccessor(tables: [Items])
class ItemDao extends DatabaseAccessor<AppDatabase> with _$ItemDaoMixin {
  ItemDao(super.db);

  Future<List<Item>> getAllItems() => select(items).get();

  Stream<List<Item>> watchAllItems() => select(items).watch();

  Future<Item?> getById(String id) =>
      (select(items)..where((t) => t.id.equals(id))).getSingleOrNull();

  Stream<Item?> watchById(String id) =>
      (select(items)..where((t) => t.id.equals(id))).watchSingleOrNull();

  Future<int> insertItem(ItemsCompanion item) => into(items).insert(item);

  Future<bool> updateItem(ItemsCompanion item) => update(items).replace(item);

  Future<int> deleteItem(String id) =>
      (delete(items)..where((t) => t.id.equals(id))).go();

  /// 更新物品的收纳位置（柜体/格子）
  Future<int> updateLocation({
    required String id,
    String? cabinetId,
    String? slotId,
    required String locationLabel,
  }) {
    return (update(items)..where((t) => t.id.equals(id))).write(
      ItemsCompanion(
        cabinetId: Value(cabinetId),
        slotId: Value(slotId),
        location: Value(locationLabel),
      ),
    );
  }

  Future<int> countAll() async {
    final result = await customSelect(
      'SELECT COUNT(*) AS total FROM items',
    ).get();
    return result.first.read<int>('total');
  }

  Future<double> totalValue() async {
    final result = await customSelect(
      'SELECT COALESCE(SUM(price), 0) AS total FROM items',
    ).get();
    return result.first.read<double>('total');
  }

  /// 统计本周（周一 00:00 起）新增的物品数量。
  /// 使用 drift customSelect，确保查询口径与 Items.purchaseDate 字段一致。
  Future<int> countWeeklyNew() async {
    final monday = _startOfWeek();
    final result = await customSelect(
      'SELECT COUNT(*) AS cnt FROM items WHERE purchase_date >= ?',
      variables: [Variable.withDateTime(monday)],
    ).get();
    return result.first.read<int>('cnt');
  }

  /// 统计本月（1 日 00:00 起）新增物品的总价值（price 求和）。
  /// 使用 drift customSelect，确保口径与 Items.price 字段一致。
  Future<double> sumMonthlyGrowth() async {
    final firstOfMonth = _startOfMonth();
    final result = await customSelect(
      'SELECT COALESCE(SUM(price), 0) AS total FROM items WHERE purchase_date >= ?',
      variables: [Variable.withDateTime(firstOfMonth)],
    ).get();
    return result.first.read<double>('total');
  }

  /// 本周一 00:00:00
  static DateTime _startOfWeek() {
    final now = DateTime.now();
    final weekdayOffset = now.weekday - DateTime.monday;
    final monday = DateTime(now.year, now.month, now.day - weekdayOffset);
    return monday;
  }

  /// 本月 1 日 00:00:00
  static DateTime _startOfMonth() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, 1);
  }
}
