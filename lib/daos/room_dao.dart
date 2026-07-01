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
