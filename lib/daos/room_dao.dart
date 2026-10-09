import 'package:drift/drift.dart';
import '../database/database.dart';

part 'generated/room_dao.g.dart';

@DriftAccessor(tables: [Rooms])
class RoomDao extends DatabaseAccessor<AppDatabase> with _$RoomDaoMixin {
  RoomDao(super.db);

  Future<List<Room>> getAllRooms() => select(rooms).get();

  Stream<List<Room>> watchAllRooms() => select(rooms).watch();

  Future<Room?> getById(String id) =>
      (select(rooms)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<int> insertRoom(RoomsCompanion room) => into(rooms).insert(room);

  Future<bool> updateRoom(RoomsCompanion room) async {
    final rows = await (update(rooms)..where((t) => t.id.equals(room.id.value)))
        .write(room);
    return rows > 0;
  }

  /// 级联删除房间及其下所有柜体、格子、格位物品与直接归属该房间的物品。
  ///
  /// 用显式事务删除，而不是依赖外键 `ON DELETE CASCADE`：历史版本的
  /// cabinets/slots 表 DDL 里并没有 CASCADE 子句，而 SQLite 无法用
  /// `ALTER TABLE` 给已有表补外键（只能重建整张表），因此外键方案对
  /// 已发布的老库完全无效。显式删除对老库、新库行为一致。
  ///
  /// 删除顺序按依赖从深到浅：space_items → items → slots → cabinets → rooms。
  Future<void> deleteRoom(String id) {
    return transaction(() async {
      await customStatement(
        'DELETE FROM space_items WHERE slot_id IN ('
        'SELECT s.id FROM slots s JOIN cabinets c ON s.cabinet_id = c.id '
        'WHERE c.room_id = ?)',
        [id],
      );
      await customStatement(
        'DELETE FROM items WHERE cabinet_id IN '
        '(SELECT id FROM cabinets WHERE room_id = ?)',
        [id],
      );
      await customStatement(
        'DELETE FROM slots WHERE cabinet_id IN '
        '(SELECT id FROM cabinets WHERE room_id = ?)',
        [id],
      );
      await customStatement('DELETE FROM cabinets WHERE room_id = ?', [id]);
      await customStatement('DELETE FROM rooms WHERE id = ?', [id]);
    });
  }

  /// 统计某个房间下的柜子数量
  Future<int> cabinetCount(String roomId) async {
    final result = await customSelect(
      'SELECT COUNT(*) AS total FROM cabinets WHERE room_id = ?',
      variables: [Variable.withString(roomId)],
    ).get();
    return result.first.read<int>('total');
  }

  /// 统计某个房间下的物品数量（主物品 items + space_items）
  Future<int> itemCount(String roomId) async {
    final result = await customSelect(
      'SELECT (SELECT COUNT(*) FROM items WHERE cabinet_id IN '
      '(SELECT id FROM cabinets WHERE room_id = ?)) '
      '+ (SELECT COUNT(*) FROM space_items WHERE slot_id IN '
      '(SELECT s.id FROM slots s INNER JOIN cabinets c ON s.cabinet_id = c.id '
      'WHERE c.room_id = ?)) AS total',
      variables: [Variable.withString(roomId), Variable.withString(roomId)],
    ).get();
    return result.first.read<int>('total');
  }

  /// 统计某个房间下所有格位的预期物品数总和
  Future<int> sumExpectedItems(String roomId) async {
    final result = await customSelect(
      'SELECT COALESCE(SUM(slots.expected_items), 0) AS total FROM slots '
      'INNER JOIN cabinets ON slots.cabinet_id = cabinets.id '
      'WHERE cabinets.room_id = ?',
      variables: [Variable.withString(roomId)],
    ).get();
    return result.first.read<int>('total');
  }
}
