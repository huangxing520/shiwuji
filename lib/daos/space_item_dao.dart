import 'package:drift/drift.dart';
import '../database/database.dart';

part 'generated/space_item_dao.g.dart';

@DriftAccessor(tables: [SpaceItems])
class SpaceItemDao extends DatabaseAccessor<AppDatabase>
    with _$SpaceItemDaoMixin {
  SpaceItemDao(super.db);

  Future<List<SpaceItem>> getBySlot(String slotId) =>
      (select(spaceItems)..where((t) => t.slotId.equals(slotId))).get();

  Stream<List<SpaceItem>> watchBySlot(String slotId) =>
      (select(spaceItems)..where((t) => t.slotId.equals(slotId))).watch();

  Future<int> insertSpaceItem(SpaceItemsCompanion item) =>
      into(spaceItems).insert(item);

  Future<bool> updateSpaceItem(SpaceItemsCompanion item) =>
      update(spaceItems).replace(item);

  Future<int> deleteSpaceItem(int id) =>
      (delete(spaceItems)..where((t) => t.id.equals(id))).go();

  /// 批量移动物品到新的格位
  Future<int> migrateToSlot(List<int> itemIds, String newSlotId) {
    return (update(spaceItems)..where((t) => t.id.isIn(itemIds)))
        .write(SpaceItemsCompanion(slotId: Value(newSlotId)));
  }

  /// 批量删除物品
  Future<int> deleteItems(List<int> itemIds) {
    return (delete(spaceItems)..where((t) => t.id.isIn(itemIds))).go();
  }
}
