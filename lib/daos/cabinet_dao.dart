import 'package:drift/drift.dart';
import '../database/database.dart';

part 'generated/cabinet_dao.g.dart';

@DriftAccessor(tables: [Cabinets])
class CabinetDao extends DatabaseAccessor<AppDatabase>
    with _$CabinetDaoMixin {
  CabinetDao(super.db);

  Future<List<Cabinet>> getByRoom(String roomId) =>
      (select(cabinets)..where((t) => t.roomId.equals(roomId))).get();

  Stream<List<Cabinet>> watchByRoom(String roomId) =>
      (select(cabinets)..where((t) => t.roomId.equals(roomId))).watch();

  Future<List<Cabinet>> getAllCabinets() => select(cabinets).get();

  Future<Cabinet?> getById(String id) =>
      (select(cabinets)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<int> insertCabinet(CabinetsCompanion cabinet) =>
      into(cabinets).insert(cabinet);

  Future<bool> updateCabinet(CabinetsCompanion cabinet) async {
    final rows = await (update(cabinets)
          ..where((t) => t.id.equals(cabinet.id.value)))
        .write(cabinet);
    return rows > 0;
  }

  Future<int> deleteCabinet(String id) =>
      (delete(cabinets)..where((t) => t.id.equals(id))).go();

  /// 统计某个柜子下的格位数量
  Future<int> slotCount(String cabinetId) async {
    final result = await customSelect(
      'SELECT COUNT(*) AS total FROM slots WHERE cabinet_id = ?',
      variables: [Variable.withString(cabinetId)],
    ).get();
    return result.first.read<int>('total');
  }

  /// 统计某个柜子下的物品数量（主物品 items + space_items）
  Future<int> itemCount(String cabinetId) async {
    final result = await customSelect(
      'SELECT (SELECT COUNT(*) FROM items WHERE cabinet_id = ?) '
      '+ (SELECT COUNT(*) FROM space_items WHERE slot_id IN '
      '(SELECT id FROM slots WHERE cabinet_id = ?)) AS total',
      variables: [Variable.withString(cabinetId), Variable.withString(cabinetId)],
    ).get();
    return result.first.read<int>('total');
  }
}
