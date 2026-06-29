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

  Future<bool> updateRoom(RoomsCompanion room) =>
      update(rooms).replace(room);

  Future<int> deleteRoom(String id) =>
      (delete(rooms)..where((t) => t.id.equals(id))).go();

  /// 统计某个房间下的柜子数量
  Future<int> cabinetCount(String roomId) async {
    final result = await customSelect(
      'SELECT COUNT(*) AS total FROM cabinets WHERE room_id = ?',
      variables: [Variable.withString(roomId)],
    ).get();
    return result.first.read<int>('total');
  }

  /// 统计某个房间下的物品数量（通过 space_items 聚合）
  Future<int> itemCount(String roomId) async {
    final result = await customSelect(
      'SELECT COUNT(*) AS total FROM space_items '
      'INNER JOIN slots ON space_items.slot_id = slots.id '
      'INNER JOIN cabinets ON slots.cabinet_id = cabinets.id '
      'WHERE cabinets.room_id = ?',
      variables: [Variable.withString(roomId)],
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
