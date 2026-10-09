import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shi_wu_ji/models/item.dart';
import 'package:shi_wu_ji/providers/item_providers.dart';

/// 测试用物品列表。
///
/// 日期一律相对 `DateTime.now()` 构造，避免断言随真实时间漂移：
/// - id 1：购买 1 天前，保修 365 天 → 在保
/// - id 2：购买 2 天前，保修 3 天   → 即将到期（≤7 天）且在保
/// - id 3：购买 3 天前，未设保修   → 既不在保也未过保
/// - id 4：购买 400 天前，保修 30 天 → 已过保
List<Item> createTestItems() {
  final now = DateTime.now();
  return [
    Item(
      id: '1',
      name: '笔记本',
      price: 5999,
      category: '数码',
      location: '书房',
      purchaseDate: now.subtract(const Duration(days: 1)),
      warrantyDays: 365,
    ),
    Item(
      id: '2',
      name: '耳机',
      price: 1299,
      category: '数码',
      location: '办公桌',
      purchaseDate: now.subtract(const Duration(days: 2)),
      warrantyDays: 3,
    ),
    Item(
      id: '3',
      name: '面霜',
      price: 299,
      category: '护肤',
      location: '浴室',
      purchaseDate: now.subtract(const Duration(days: 3)),
    ),
    Item(
      id: '4',
      name: '旧手机',
      price: 1000,
      category: '数码',
      location: '抽屉',
      purchaseDate: now.subtract(const Duration(days: 400)),
      warrantyDays: 30,
    ),
  ];
}

/// 只替换数据源：把 itemsProvider 指向内存中的固定列表，
/// 让 itemCount / totalValue 等**真实**派生 provider 跑各自的逻辑。
///
/// 旧写法把待测的派生 provider 也用 overrideWith 重写了一遍，
/// 断言等于在验证测试自己抄的那份逻辑，恒真且无法发现回归。
class _FakeItems extends Items {
  _FakeItems(this._items);

  final List<Item> _items;

  @override
  Future<List<Item>> build() async => _items;
}

ProviderContainer createTestContainer() {
  return ProviderContainer(
    overrides: [itemsProvider.overrideWith(() => _FakeItems(createTestItems()))],
  );
}

/// 读取派生 provider 前先把异步数据源跑完。
///
/// itemsProvider 是 autoDispose，必须先挂一个 listener 保持其存活，
/// 否则 await 之后会被回收，派生 provider 再读到的又是 loading（→ 0）。
Future<ProviderContainer> bootstrappedContainer() async {
  final container = createTestContainer();
  container.listen(itemsProvider, (_, __) {});
  await container.read(itemsProvider.future);
  return container;
}

void main() {
  group('Derived providers', () {
    test('itemCount returns total count', () async {
      final container = await bootstrappedContainer();
      expect(container.read(itemCountProvider), 4);
    });

    test('totalValue sums all item prices', () async {
      final container = await bootstrappedContainer();
      // 5999 + 1299 + 299 + 1000 = 8597
      expect(container.read(totalValueProvider), 8597);
    });

    test('pendingCount counts expiring items', () async {
      final container = await bootstrappedContainer();
      expect(container.read(pendingCountProvider), 1);
    });

    test('warrantyCount counts items under warranty', () async {
      final container = await bootstrappedContainer();
      // id 1（365 天）与 id 2（即将到期但仍在保）都算在保
      expect(container.read(warrantyCountProvider), 2);
    });

    test('idleCount counts expired warranty items', () async {
      final container = await bootstrappedContainer();
      // 仅 id 4 已过保；id 3 未设保修，不算过保
      expect(container.read(idleCountProvider), 1);
    });

    test('pendingItems filters expiring-soon items', () async {
      final container = await bootstrappedContainer();
      final pending = container.read(pendingItemsProvider);
      expect(pending.map((i) => i.id).toList(), ['2']);
      for (final item in pending) {
        expect(item.isWarrantyExpiringSoon, true);
      }
    });

    test('recentItems is sorted by purchaseDate descending', () async {
      final container = await bootstrappedContainer();
      final recent = container.read(recentItemsProvider);
      expect(recent.map((i) => i.id).toList(), ['1', '2', '3', '4']);
      for (var i = 0; i < recent.length - 1; i++) {
        expect(
          recent[i].purchaseDate.compareTo(recent[i + 1].purchaseDate),
          greaterThanOrEqualTo(0),
        );
      }
    });

    test('itemById returns null for non-existent id', () async {
      final container = await bootstrappedContainer();
      expect(container.read(itemByIdProvider('nonexistent')), isNull);
    });

    test('itemById returns item for valid id', () async {
      final container = await bootstrappedContainer();
      final found = container.read(itemByIdProvider('1'));
      expect(found, isNotNull);
      expect(found!.id, '1');
      expect(found.name, '笔记本');
    });
  });
}
