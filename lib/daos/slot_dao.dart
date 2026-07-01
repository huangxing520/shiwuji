import 'package:drift/drift.dart';
import '../database/database.dart';

part 'generated/slot_dao.g.dart';

@DriftAccessor(tables: [Slots])
class SlotDao extends DatabaseAccessor<AppDatabase> with _$SlotDaoMixin {
  SlotDao(super.db);

  Future<List<Slot>> getByCabinet(String cabinetId) =>
      (select(slots)..where((t) => t.cabinetId.equals(cabinetId))).get();

  Stream<List<Slot>> watchByCabinet(String cabinetId) =>
      (select(slots)..where((t) => t.cabinetId.equals(cabinetId))).watch();

  Future<Slot?> getById(String id) =>
      (select(slots)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<int> insertSlot(SlotsCompanion slot) => into(slots).insert(slot);

  Future<bool> updateSlot(SlotsCompanion slot) async {
    final rows = await (update(
      slots,
    )..where((t) => t.id.equals(slot.id.value))).write(slot);
    return rows > 0;
  }

  Future<int> deleteSlot(String id) =>
      (delete(slots)..where((t) => t.id.equals(id))).go();

  /// 统计某个格位下的物品数量（主物品 items + space_items）
  Future<int> itemCount(String slotId) async {
    final result = await customSelect(
      'SELECT (SELECT COUNT(*) FROM items WHERE slot_id = ?) '
      '+ (SELECT COUNT(*) FROM space_items WHERE slot_id = ?) AS total',
      variables: [Variable.withString(slotId), Variable.withString(slotId)],
    ).get();
    return result.first.read<int>('total');
  }

  /// 统计某个柜体下所有格位的预期物品数总和
  Future<int> sumExpectedItems(String cabinetId) async {
    final result = await customSelect(
      'SELECT COALESCE(SUM(expected_items), 0) AS total FROM slots WHERE cabinet_id = ?',
      variables: [Variable.withString(cabinetId)],
    ).get();
    return result.first.read<int>('total');
  }
}
