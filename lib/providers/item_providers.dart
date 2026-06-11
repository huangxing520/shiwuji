import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/item.dart';

part 'item_providers.g.dart';

@riverpod
class Items extends _$Items {
  @override
  List<Item> build() => _seedData();

  void addItem(Item item) {
    state = [...state, item];
  }

  void removeItem(String id) {
    state = state.where((item) => item.id != id).toList();
  }

  static List<Item> _seedData() {
    return [
      Item.create(
        name: 'AirPods Pro',
        price: 1899,
        category: '电子产品',
        location: '书桌',
        purchaseDate: DateTime.now().subtract(const Duration(days: 362)),
        warrantyDays: 365,
      ),
      Item.create(
        name: '耳机',
        price: 799,
        category: '电子产品',
        location: '书桌',
        purchaseDate: DateTime.now().subtract(const Duration(days: 358)),
        warrantyDays: 365,
      ),
      Item.create(
        name: 'MacBook Pro',
        price: 12999,
        category: '电子产品',
        location: '书桌',
        purchaseDate: DateTime(2024, 1, 15),
        warrantyDays: 365,
      ),
      Item.create(
        name: '咖啡机',
        price: 499,
        category: '厨房',
        location: '厨房',
        purchaseDate: DateTime(2024, 3, 20),
        warrantyDays: 730,
      ),
      Item.create(
        name: '背包',
        price: 299,
        category: '服饰',
        location: '衣柜',
        purchaseDate: DateTime(2024, 5, 10),
        warrantyDays: 365,
      ),
    ];
  }
}

@riverpod
int itemCount(Ref ref) {
  return ref.watch(itemsProvider).length;
}

@riverpod
int pendingCount(Ref ref) {
  return ref.watch(itemsProvider).where((i) => i.isWarrantyExpiringSoon).length;
}

@riverpod
int warrantyCount(Ref ref) {
  return ref.watch(itemsProvider).where((i) => i.isUnderWarranty).length;
}

@riverpod
List<Item> pendingItems(Ref ref) {
  return ref.watch(itemsProvider).where((i) => i.isWarrantyExpiringSoon).toList();
}

@riverpod
List<Item> recentItems(Ref ref) {
  final items = ref.watch(itemsProvider);
  final sorted = [...items]..sort((a, b) => b.purchaseDate.compareTo(a.purchaseDate));
  return sorted;
}

@riverpod
int totalValue(Ref ref) {
  final items = ref.watch(itemsProvider);
  return items.fold<int>(0, (sum, item) => sum + item.price.toInt());
}

@riverpod
int idleCount(Ref ref) {
  final items = ref.watch(itemsProvider);
  return items.where((i) => i.isWarrantyExpired).length;
}

@riverpod
Item? itemById(Ref ref, String id) {
  final items = ref.watch(itemsProvider);
  try {
    return items.firstWhere((item) => item.id == id);
  } catch (_) {
    return null;
  }
}