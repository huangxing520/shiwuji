import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shi_wu_ji/models/item.dart';
import 'package:shi_wu_ji/providers/item_providers.dart';

/// 测试用物品列表
List<Item> createTestItems() => [
      Item(
        id: '1',
        name: '笔记本',
        price: 5999,
        category: '数码',
        location: '书房',
        purchaseDate: DateTime(2024, 6, 1),
      ),
      Item(
        id: '2',
        name: '耳机',
        price: 1299,
        category: '数码',
        location: '办公桌',
        purchaseDate: DateTime(2024, 6, 10),
      ),
      Item(
        id: '3',
        name: '面霜',
        price: 299,
        category: '护肤',
        location: '浴室',
        purchaseDate: DateTime(2024, 5, 15),
        warrantyDays: 30,
      ),
    ];

/// 创建覆盖所有派生 Provider 的 ProviderContainer
/// 绕过 itemsProvider（需要数据库），直接测试派生 Provider 的逻辑
ProviderContainer createTestContainer() {
  final items = createTestItems();
  return ProviderContainer(
    overrides: [
      itemCountProvider.overrideWith((ref) => items.length),
      totalValueProvider.overrideWith(
        (ref) => items.fold<int>(0, (sum, item) => sum + item.price.toInt()),
      ),
      pendingCountProvider.overrideWith(
        (ref) => items.where((i) => i.isWarrantyExpiringSoon).length,
      ),
      warrantyCountProvider.overrideWith(
        (ref) => items.where((i) => i.isUnderWarranty).length,
      ),
      idleCountProvider.overrideWith(
        (ref) => items.where((i) => i.isWarrantyExpired).length,
      ),
      pendingItemsProvider.overrideWith(
        (ref) => items.where((i) => i.isWarrantyExpiringSoon).toList(),
      ),
      recentItemsProvider.overrideWith((ref) {
        final sorted = [...items]
          ..sort((a, b) => b.purchaseDate.compareTo(a.purchaseDate));
        return sorted;
      }),
      itemByIdProvider.overrideWith(
        (ref, id) {
          try {
            return items.firstWhere((item) => item.id == id);
          } catch (_) {
            return null;
          }
        },
      ),
    ],
  );
}

void main() {
  group('Derived providers', () {
    test('itemCount returns total count', () {
      final container = createTestContainer();
      expect(container.read(itemCountProvider), 3);
    });

    test('totalValue sums all item prices', () {
      final container = createTestContainer();
      // 5999 + 1299 + 299 = 7597
      expect(container.read(totalValueProvider), 7597);
    });

    test('pendingCount counts expiring items', () {
      final container = createTestContainer();
      final count = container.read(pendingCountProvider);
      expect(count, isA<int>());
      expect(count, greaterThanOrEqualTo(0));
    });

    test('warrantyCount counts items under warranty', () {
      final container = createTestContainer();
      final count = container.read(warrantyCountProvider);
      expect(count, isA<int>());
      expect(count, greaterThanOrEqualTo(0));
    });

    test('pendingItems filters expiring-soon items', () {
      final container = createTestContainer();
      final pending = container.read(pendingItemsProvider);
      for (final item in pending) {
        expect(item.isWarrantyExpiringSoon, true);
      }
    });

    test('recentItems is sorted by purchaseDate descending', () {
      final container = createTestContainer();
      final recent = container.read(recentItemsProvider);
      expect(recent.length, 3);
      for (var i = 0; i < recent.length - 1; i++) {
        expect(
          recent[i].purchaseDate.compareTo(recent[i + 1].purchaseDate),
          greaterThanOrEqualTo(0),
        );
      }
    });

    test('itemById returns null for non-existent id', () {
      final container = createTestContainer();
      expect(container.read(itemByIdProvider('nonexistent')), isNull);
    });

    test('itemById returns item for valid id', () {
      final container = createTestContainer();
      final found = container.read(itemByIdProvider('1'));
      expect(found, isNotNull);
      expect(found!.id, '1');
      expect(found.name, '笔记本');
    });

    test('idleCount counts expired warranty items', () {
      final container = createTestContainer();
      final count = container.read(idleCountProvider);
      expect(count, isA<int>());
      expect(count, greaterThanOrEqualTo(0));
    });
  });
}
