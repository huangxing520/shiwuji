import 'package:drift/drift.dart' hide Column;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../database/database.dart' as db;
import '../daos/item_dao.dart';
import '../models/item.dart';
import 'database_provider.dart';

part 'generated/item_providers.g.dart';

/// 跨页面共享的"待选分类"——例如从分类管理页跳转到物品库时，传递需要选中的分类 key。
/// 读取方应用后应清空，避免下次进入时重复生效。
@riverpod
class PendingCategory extends _$PendingCategory {
  @override
  String? build() => null;

  void set(String? value) => state = value;
}

/// 跨页面共享的"待选状态筛选"——从首页待处理事项跳转到物品库时，传递需要筛选的状态。
@riverpod
class PendingStatusFilter extends _$PendingStatusFilter {
  @override
  String? build() => null;

  void set(String? value) => state = value;
}

/// 核心 Items Provider —— AsyncNotifier，从数据库读写
@riverpod
class Items extends _$Items {
  late ItemDao _dao;

  @override
  Future<List<Item>> build() async {
    _dao = ref.watch(itemDaoProvider);
    final rows = await _dao.getAllItems();
    return rows.map<Item>(_toModel).toList();
  }

  Future<void> addItem(Item item) async {
    await _dao.insertItem(db.ItemsCompanion.insert(
      id: item.id,
      name: item.name,
      price: item.price,
      emoji: Value(item.emoji),
      category: Value(item.category),
      location: Value(item.location),
      purchaseDate: item.purchaseDate,
      warrantyDays: Value(item.warrantyDays),
      status: Value(item.status),
      categoryKey: Value(item.categoryKey),
      cabinetId: Value(item.cabinetId),
      slotId: Value(item.slotId),
    ));
    ref.invalidateSelf();
  }

  Future<void> removeItem(String id) async {
    await _dao.deleteItem(id);
    ref.invalidateSelf();
  }

  /// 批量添加物品（订单导入用）
  Future<void> addItems(List<Item> newItems) async {
    final companions = newItems
        .map((item) => db.ItemsCompanion.insert(
              id: item.id,
              name: item.name,
              price: item.price,
              emoji: Value(item.emoji),
              category: Value(item.category),
              location: Value(item.location),
              purchaseDate: item.purchaseDate,
              warrantyDays: Value(item.warrantyDays),
              status: Value(item.status),
              categoryKey: Value(item.categoryKey),
              cabinetId: Value(item.cabinetId),
              slotId: Value(item.slotId),
            ))
        .toList();
    await _dao.db.batch((b) {
      b.insertAll(_dao.items, companions);
    });
    ref.invalidateSelf();
  }

  /// 更新物品收纳位置（与收纳页面联动）
  Future<void> updateLocation({
    required String id,
    String? cabinetId,
    String? slotId,
    required String locationLabel,
  }) async {
    await _dao.updateLocation(
      id: id,
      cabinetId: cabinetId,
      slotId: slotId,
      locationLabel: locationLabel,
    );
    ref.invalidateSelf();
  }

  static Item _toModel(db.Item row) => Item(
        id: row.id,
        name: row.name,
        price: row.price,
        emoji: row.emoji,
        category: row.category,
        location: row.location,
        purchaseDate: row.purchaseDate,
        warrantyDays: row.warrantyDays,
        status: row.status,
        categoryKey: row.categoryKey,
        cabinetId: row.cabinetId,
        slotId: row.slotId,
      );
}

// ─── 派生 Providers ───────────────────────────────────

@riverpod
int itemCount(Ref ref) {
  return ref.watch(itemsProvider).maybeWhen(
        data: (items) => items.length,
        orElse: () => 0,
      );
}

@riverpod
int pendingCount(Ref ref) {
  return ref.watch(itemsProvider).maybeWhen(
        data: (items) => items.where((i) => i.isWarrantyExpiringSoon).length,
        orElse: () => 0,
      );
}

@riverpod
int warrantyCount(Ref ref) {
  return ref.watch(itemsProvider).maybeWhen(
        data: (items) => items.where((i) => i.isUnderWarranty).length,
        orElse: () => 0,
      );
}

@riverpod
List<Item> pendingItems(Ref ref) {
  return ref.watch(itemsProvider).maybeWhen(
        data: (items) => items.where((i) => i.isWarrantyExpiringSoon).toList(),
        orElse: () => [],
      );
}

@riverpod
List<Item> recentItems(Ref ref) {
  return ref.watch(itemsProvider).maybeWhen(
        data: (items) {
          final sorted = [...items]
            ..sort((a, b) => b.purchaseDate.compareTo(a.purchaseDate));
          return sorted;
        },
        orElse: () => [],
      );
}

@riverpod
int totalValue(Ref ref) {
  return ref.watch(itemsProvider).maybeWhen(
        data: (items) =>
            items.fold<int>(0, (sum, item) => sum + item.price.toInt()),
        orElse: () => 0,
      );
}

@riverpod
int idleCount(Ref ref) {
  return ref.watch(itemsProvider).maybeWhen(
        data: (items) => items.where((i) => i.isWarrantyExpired).length,
        orElse: () => 0,
      );
}

@riverpod
Item? itemById(Ref ref, String id) {
  return ref.watch(itemsProvider).maybeWhen(
        data: (items) {
          try {
            return items.firstWhere((item) => item.id == id);
          } catch (_) {
            return null;
          }
        },
        orElse: () => null,
      );
}
