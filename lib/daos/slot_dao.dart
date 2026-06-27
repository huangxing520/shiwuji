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

  Future<bool> updateSlot(SlotsCompanion slot) =>
      update(slots).replace(slot);

  Future<int> deleteSlot(String id) =>
      (delete(slots)..where((t) => t.id.equals(id))).go();

  /// 统计某个格位下的物品数量
  Future<int> itemCount(String slotId) async {
    final result = await customSelect(
      'SELECT COUNT(*) AS total FROM space_items WHERE slot_id = ?',
      variables: [Variable.withString(slotId)],
    ).get();
    return result.first.read<int>('total');
  }
}
