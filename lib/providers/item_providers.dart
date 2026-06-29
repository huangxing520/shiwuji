import 'dart:convert';
import 'package:drift/drift.dart' hide Column;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../database/database.dart' as db;
import '../daos/item_dao.dart';
import '../models/item.dart';
import 'database_provider.dart';

part 'generated/item_providers.g.dart';

/// 跨页面共享的"待选分类"——例如从分类管理页跳转到物品库时，传递需要选中的分类 key。
/// 读取方应用后应清空，避免下次进入时重复生效。
/// 使用 keepAlive 是因为：设置方（来源页）只用 ref.read 写入、不监听，
/// autoDispose 会在写入后立即销毁 provider，导致目标页 initState 读到 null。
@Riverpod(keepAlive: true)
class PendingCategory extends _$PendingCategory {
  @override
  String? build() => null;

  void set(String? value) => state = value;
}

/// 跨页面共享的"待选状态筛选"——从首页待处理事项跳转到物品库时，传递需要筛选的状态。
/// 使用 keepAlive 是因为：设置方（首页）只用 ref.read 写入、不监听，
/// autoDispose 会在写入后立即销毁 provider，导致目标页 initState 读到 null。
@Riverpod(keepAlive: true)
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
    return rows.map<Item>(toModel).toList();
  }

  Future<void> addItem(Item item) async {
    await _dao.insertItem(_toCompanion(item));
    ref.invalidateSelf();
  }

  /// 编辑模式下全量更新物品
  Future<void> updateItem(Item item) async {
    await _dao.updateItem(_toCompanion(item, forUpdate: true));
    ref.invalidateSelf();
  }

  Future<void> removeItem(String id) async {
    await _dao.deleteItem(id);
    ref.invalidateSelf();
  }

  /// 批量添加物品（订单导入用）
  Future<void> addItems(List<Item> newItems) async {
    final companions = newItems.map(_toCompanion).toList();
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

  /// 将 drift 行记录转换为 Item 模型（公开方法，供备份恢复等场景使用）
  static Item toModel(db.Item row) => Item(
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
    photos: _decodeList(row.photos),
    brand: row.brand,
    note: row.note,
    templateKey: row.templateKey,
    templateData: _decodeMap(row.templateData),
  );

  /// Item → drift Companion（insert/update 复用）
  static db.ItemsCompanion _toCompanion(Item item, {bool forUpdate = false}) {
    return db.ItemsCompanion(
      id: Value(item.id),
      name: Value(item.name),
      price: Value(item.price),
      emoji: Value(item.emoji),
      category: Value(item.category),
      location: Value(item.location),
      purchaseDate: Value(item.purchaseDate),
      warrantyDays: Value(item.warrantyDays),
      status: Value(item.status),
      categoryKey: Value(item.categoryKey),
      cabinetId: Value(item.cabinetId),
      slotId: Value(item.slotId),
      photos: Value(jsonEncode(item.photos)),
      brand: Value(item.brand),
      note: Value(item.note),
      templateKey: Value(item.templateKey),
      templateData: Value(jsonEncode(item.templateData)),
    );
  }

  static List<String> _decodeList(String raw) {
    if (raw.isEmpty) return const [];
    try {
      final l = jsonDecode(raw);
      if (l is List) return l.map((e) => e.toString()).toList();
    } catch (_) {}
    return const [];
  }

  static Map<String, String> _decodeMap(String raw) {
    if (raw.isEmpty) return const {};
    try {
      final m = jsonDecode(raw);
      if (m is Map) {
        return m.map((k, v) => MapEntry(k.toString(), v.toString()));
      }
    } catch (_) {}
    return const {};
  }
}

// ─── 派生 Providers ───────────────────────────────────

@riverpod
int itemCount(Ref ref) {
  return ref
      .watch(itemsProvider)
      .maybeWhen(data: (items) => items.length, orElse: () => 0);
}

@riverpod
int pendingCount(Ref ref) {
  return ref
      .watch(itemsProvider)
      .maybeWhen(
        data: (items) => items.where((i) => i.isWarrantyExpiringSoon).length,
        orElse: () => 0,
      );
}

@riverpod
int warrantyCount(Ref ref) {
  return ref
      .watch(itemsProvider)
      .maybeWhen(
        data: (items) => items.where((i) => i.isUnderWarranty).length,
        orElse: () => 0,
      );
}

@riverpod
List<Item> pendingItems(Ref ref) {
  return ref
      .watch(itemsProvider)
      .maybeWhen(
        data: (items) => items.where((i) => i.isWarrantyExpiringSoon).toList(),
        orElse: () => [],
      );
}

@riverpod
List<Item> recentItems(Ref ref) {
  return ref
      .watch(itemsProvider)
      .maybeWhen(
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
  return ref
      .watch(itemsProvider)
      .maybeWhen(
        data: (items) =>
            items.fold<int>(0, (sum, item) => sum + item.price.toInt()),
        orElse: () => 0,
      );
}

@riverpod
int idleCount(Ref ref) {
  return ref
      .watch(itemsProvider)
      .maybeWhen(
        data: (items) => items.where((i) => i.isWarrantyExpired).length,
        orElse: () => 0,
      );
}

/// 本周新增物品数量（周一 00:00 至今）
/// 数据口径：Items.purchaseDate >= 本周一，与 drift 表 purchase_date 字段一致。
@riverpod
int weeklyNewCount(Ref ref) {
  return ref
      .watch(itemsProvider)
      .maybeWhen(
        data: (items) {
          final now = DateTime.now();
          final monday = DateTime(
            now.year,
            now.month,
            now.day - (now.weekday - DateTime.monday),
          );
          return items.where((i) => !i.purchaseDate.isBefore(monday)).length;
        },
        orElse: () => 0,
      );
}

/// 本月新增物品总价值（1 日 00:00 至今）
/// 数据口径：Items.purchaseDate >= 本月 1 日，price 求和，与 drift 表字段一致。
@riverpod
double monthlyGrowth(Ref ref) {
  return ref
      .watch(itemsProvider)
      .maybeWhen(
        data: (items) {
          final now = DateTime.now();
          final firstOfMonth = DateTime(now.year, now.month, 1);
          return items
              .where((i) => !i.purchaseDate.isBefore(firstOfMonth))
              .fold<double>(0, (sum, i) => sum + i.price);
        },
        orElse: () => 0,
      );
}

@riverpod
Item? itemById(Ref ref, String id) {
  return ref
      .watch(itemsProvider)
      .maybeWhen(
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
