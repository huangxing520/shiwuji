import 'dart:ui';

import 'package:drift/drift.dart' hide Column;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../database/database.dart' as db;
import '../models/storage.dart' as model;
import 'database_provider.dart';

part 'generated/storage_providers.g.dart';

// ─── Rooms ───────────────────────────────────────────

@riverpod
Future<List<model.Room>> rooms(Ref ref) async {
  final dao = ref.watch(roomDaoProvider);
  final rows = await dao.getAllRooms();

  final result = <model.Room>[];
  for (final row in rows) {
    final cabinetCount = await dao.cabinetCount(row.id);
    final itemCount = await dao.itemCount(row.id);
    final expectedTotal = await dao.sumExpectedItems(row.id);
    final occupation = expectedTotal > 0
        ? (itemCount * 100 ~/ expectedTotal)
        : 0;
    result.add(
      model.Room(
        id: row.id,
        name: row.name,
        emoji: row.emoji,
        color: Color(row.color),
        items: itemCount,
        storageCount: cabinetCount,
        occupation: occupation,
      ),
    );
  }
  return result;
}

/// 新增房间
@riverpod
class RoomActions extends _$RoomActions {
  @override
  Future<void> build() async {}

  Future<void> addRoom({
    required String id,
    required String name,
    required String emoji,
    required Color color,
  }) async {
    final dao = ref.read(roomDaoProvider);
    await dao.insertRoom(
      db.RoomsCompanion.insert(
        id: id,
        name: name,
        emoji: emoji,
        color: color.toARGB32(),
      ),
    );
    ref.invalidate(roomsProvider);
  }

  /// 更新房间
  Future<void> updateRoom({
    required String id,
    required String name,
    required String emoji,
  }) async {
    final dao = ref.read(roomDaoProvider);
    await dao.updateRoom(
      db.RoomsCompanion(id: Value(id), name: Value(name), emoji: Value(emoji)),
    );
    ref.invalidate(roomsProvider);
  }

  /// 删除房间（级联删除其下柜体/格子/物品）
  Future<void> deleteRoom(String id) async {
    final dao = ref.read(roomDaoProvider);
    await dao.deleteRoom(id);
    ref.invalidate(roomsProvider);
  }
}

// ─── Cabinets ────────────────────────────────────────

@riverpod
Future<List<model.Cabinet>> cabinetsByRoom(Ref ref, String roomId) async {
  final dao = ref.watch(cabinetDaoProvider);
  final slotDao = ref.watch(slotDaoProvider);
  final rows = await dao.getByRoom(roomId);

  final result = <model.Cabinet>[];
  for (final row in rows) {
    final itemCount = await dao.itemCount(row.id);
    final expectedTotal = await slotDao.sumExpectedItems(row.id);
    final occupation = expectedTotal > 0
        ? (itemCount * 100 ~/ expectedTotal)
        : 0;
    result.add(
      model.Cabinet(
        id: row.id,
        name: row.name,
        emoji: row.emoji,
        color: Color(row.color),
        items: itemCount,
        occupation: occupation,
        hasPhoto: row.hasPhoto,
        expectedItems: expectedTotal,
        photoPath: row.photoPath,
      ),
    );
  }
  return result;
}

/// 新增柜子
@riverpod
class CabinetActions extends _$CabinetActions {
  @override
  Future<void> build() async {}

  Future<void> addCabinet({
    required String id,
    required String name,
    required String emoji,
    required Color color,
    required String roomId,
    String? photoPath,
  }) async {
    final dao = ref.read(cabinetDaoProvider);
    final hasPhoto = photoPath != null && photoPath.isNotEmpty;
    await dao.insertCabinet(
      db.CabinetsCompanion.insert(
        id: id,
        name: name,
        emoji: emoji,
        color: color.toARGB32(),
        roomId: roomId,
        photoPath: photoPath != null ? Value(photoPath) : const Value.absent(),
        hasPhoto: hasPhoto ? const Value(true) : const Value.absent(),
      ),
    );
    ref.invalidate(cabinetsByRoomProvider(roomId));
    ref.invalidate(roomsProvider);
  }

  /// 更新柜体
  Future<void> updateCabinet({
    required String id,
    required String roomId,
    required String name,
    required String emoji,
  }) async {
    final dao = ref.read(cabinetDaoProvider);
    await dao.updateCabinet(
      db.CabinetsCompanion(
        id: Value(id),
        name: Value(name),
        emoji: Value(emoji),
      ),
    );
    ref.invalidate(cabinetsByRoomProvider(roomId));
    ref.invalidate(roomsProvider);
  }

  /// 删除柜体（级联删除其下格子/物品）
  Future<void> deleteCabinet(String id, String roomId) async {
    final dao = ref.read(cabinetDaoProvider);
    await dao.deleteCabinet(id);
    ref.invalidate(cabinetsByRoomProvider(roomId));
    ref.invalidate(roomsProvider);
  }
}

// ─── Slots ───────────────────────────────────────────

@riverpod
Future<List<model.Slot>> slotsByCabinet(Ref ref, String cabinetId) async {
  final dao = ref.watch(slotDaoProvider);
  final rows = await dao.getByCabinet(cabinetId);

  final result = <model.Slot>[];
  for (final row in rows) {
    final itemCount = await dao.itemCount(row.id);
    final expected = row.expectedItems;
    final occupation = expected > 0 ? (itemCount * 100 ~/ expected) : 0;
    result.add(
      model.Slot(
        id: row.id,
        name: row.name,
        emoji: row.emoji,
        color: Color(row.color),
        items: itemCount,
        occupation: occupation,
        expectedItems: expected,
      ),
    );
  }
  return result;
}

/// 新增格位
@riverpod
class SlotActions extends _$SlotActions {
  @override
  Future<void> build() async {}

  Future<void> addSlot({
    required String id,
    required String name,
    required String emoji,
    required Color color,
    required String cabinetId,
    int expectedItems = 1,
  }) async {
    final dao = ref.read(slotDaoProvider);
    await dao.insertSlot(
      db.SlotsCompanion.insert(
        id: id,
        name: name,
        emoji: emoji,
        color: color.toARGB32(),
        cabinetId: cabinetId,
        expectedItems: Value(expectedItems),
      ),
    );
    ref.invalidate(slotsByCabinetProvider(cabinetId));
    ref.invalidate(roomsProvider);
  }

  /// 更新格子
  Future<void> updateSlot({
    required String id,
    required String cabinetId,
    required String name,
    required String emoji,
    int? expectedItems,
  }) async {
    final dao = ref.read(slotDaoProvider);
    await dao.updateSlot(
      db.SlotsCompanion(
        id: Value(id),
        name: Value(name),
        emoji: Value(emoji),
        expectedItems: expectedItems != null
            ? Value(expectedItems)
            : const Value.absent(),
      ),
    );
    ref.invalidate(slotsByCabinetProvider(cabinetId));
    ref.invalidate(roomsProvider);
  }

  /// 删除格子（级联删除其下物品）
  Future<void> deleteSlot(String id, String cabinetId) async {
    final dao = ref.read(slotDaoProvider);
    await dao.deleteSlot(id);
    ref.invalidate(slotsByCabinetProvider(cabinetId));
    ref.invalidate(roomsProvider);
  }
}

// ─── Space Items ─────────────────────────────────────

@riverpod
Future<List<model.SpaceItem>> spaceItemsBySlot(Ref ref, String slotId) async {
  final dao = ref.watch(spaceItemDaoProvider);
  final rows = await dao.getBySlot(slotId);
  return rows
      .map(
        (row) => model.SpaceItem(
          id: row.id,
          emoji: row.emoji,
          name: row.name,
          meta: row.meta,
        ),
      )
      .toList();
}

/// 格位物品操作
@riverpod
class SpaceItemActions extends _$SpaceItemActions {
  @override
  Future<void> build() async {}

  Future<void> addItem({
    required String emoji,
    required String name,
    required String meta,
    required String slotId,
  }) async {
    final dao = ref.read(spaceItemDaoProvider);
    await dao.insertSpaceItem(
      db.SpaceItemsCompanion.insert(
        emoji: emoji,
        name: name,
        meta: meta,
        slotId: slotId,
      ),
    );
    ref.invalidate(spaceItemsBySlotProvider(slotId));
    ref.invalidate(roomsProvider);
  }

  Future<void> migrateItems(List<int> itemIds, String newSlotId) async {
    final dao = ref.read(spaceItemDaoProvider);
    await dao.migrateToSlot(itemIds, newSlotId);
    ref.invalidate(roomsProvider);
  }

  /// 批量删除物品
  Future<void> deleteItems(List<int> itemIds, String slotId) async {
    final dao = ref.read(spaceItemDaoProvider);
    await dao.deleteItems(itemIds);
    ref.invalidate(spaceItemsBySlotProvider(slotId));
    ref.invalidate(roomsProvider);
  }
}

// ─── 全局统计 ─────────────────────────────────────────

@riverpod
Future<Map<String, int>> storageStats(Ref ref) async {
  final roomDao = ref.watch(roomDaoProvider);
  final rooms = await roomDao.getAllRooms();
  int totalRooms = rooms.length;
  int totalCabinets = 0;
  int totalItems = 0;

  for (final room in rooms) {
    totalCabinets += await roomDao.cabinetCount(room.id);
    totalItems += await roomDao.itemCount(room.id);
  }

  return {'rooms': totalRooms, 'cabinets': totalCabinets, 'items': totalItems};
}

// ─── 收纳位置选择树（供新增/编辑物品选位置用） ─────────

/// 收纳位置节点（柜体或格子）
class StorageLocationNode {
  final String id;
  final String name;
  final String emoji;
  final bool isSlot; // false = 柜体, true = 格子
  final String cabinetId; // 所属柜体 id（slot 才有）
  final String cabinetName; // 所属柜体名（slot 才有）
  final String roomName; // 所属房间名

  const StorageLocationNode({
    required this.id,
    required this.name,
    required this.emoji,
    required this.isSlot,
    required this.cabinetId,
    required this.cabinetName,
    required this.roomName,
  });

  /// 显示用路径标签：柜体 → "房间 / 柜体"；格子 → "房间 / 柜体 / 格子"
  String get pathLabel =>
      isSlot ? '$roomName / $cabinetName / $name' : '$roomName / $name';
}

/// 查询所有柜体+格子，扁平化为节点列表（供选择器使用）
@riverpod
Future<List<StorageLocationNode>> storageLocationTree(Ref ref) async {
  final roomDao = ref.watch(roomDaoProvider);
  final cabinetDao = ref.watch(cabinetDaoProvider);
  final slotDao = ref.watch(slotDaoProvider);

  final rooms = await roomDao.getAllRooms();
  final nodes = <StorageLocationNode>[];

  for (final room in rooms) {
    final cabinets = await cabinetDao.getByRoom(room.id);
    for (final cab in cabinets) {
      // 柜体节点
      nodes.add(
        StorageLocationNode(
          id: cab.id,
          name: cab.name,
          emoji: cab.emoji,
          isSlot: false,
          cabinetId: cab.id,
          cabinetName: cab.name,
          roomName: room.name,
        ),
      );
      // 格子节点
      final slots = await slotDao.getByCabinet(cab.id);
      for (final slot in slots) {
        nodes.add(
          StorageLocationNode(
            id: slot.id,
            name: slot.name,
            emoji: slot.emoji,
            isSlot: true,
            cabinetId: cab.id,
            cabinetName: cab.name,
            roomName: room.name,
          ),
        );
      }
    }
  }
  return nodes;
}
