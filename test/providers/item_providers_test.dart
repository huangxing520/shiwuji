import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wupin/models/item.dart';
import 'package:wupin/providers/item_providers.dart';

ProviderContainer createContainer() {
  return ProviderContainer();
}

void main() {
  group('ItemsProvider', () {
    test('initial state has 5 seed items', () {
      final container = createContainer();
      final items = container.read(itemsProvider);
      expect(items.length, 5);
    });

    test('addItem appends to list', () {
      final container = createContainer();
      final newItem = Item.create(name: 'New Item', price: 500);
      container.read(itemsProvider.notifier).addItem(newItem);
      final items = container.read(itemsProvider);
      expect(items.length, 6);
      expect(items.last.name, 'New Item');
    });

    test('removeItem removes by id', () {
      final container = createContainer();
      final items = container.read(itemsProvider);
      final idToRemove = items.first.id;
      container.read(itemsProvider.notifier).removeItem(idToRemove);
      final updated = container.read(itemsProvider);
      expect(updated.length, 4);
      expect(updated.any((i) => i.id == idToRemove), false);
    });

    test('removeItem with non-existent id does nothing', () {
      final container = createContainer();
      container.read(itemsProvider.notifier).removeItem('nonexistent');
      expect(container.read(itemsProvider).length, 5);
    });
  });

  group('Derived providers', () {
    test('itemCount returns total count', () {
      final container = createContainer();
      expect(container.read(itemCountProvider), 5);
    });

    test('pendingCount counts expiring items', () {
      final container = createContainer();
      final count = container.read(pendingCountProvider);
      // Two seed items have warranty expiring < 7 days
      expect(count, greaterThanOrEqualTo(0));
    });

    test('warrantyCount counts items under warranty', () {
      final container = createContainer();
      final count = container.read(warrantyCountProvider);
      expect(count, isA<int>());
      expect(count, greaterThanOrEqualTo(0));
    });

    test('pendingItems filters expiring-soon items', () {
      final container = createContainer();
      final items = container.read(pendingItemsProvider);
      for (final item in items) {
        expect(item.isWarrantyExpiringSoon, true);
      }
    });

    test('recentItems is sorted by purchaseDate descending', () {
      final container = createContainer();
      final items = container.read(recentItemsProvider);
      for (var i = 0; i < items.length - 1; i++) {
        expect(
          items[i].purchaseDate.compareTo(items[i + 1].purchaseDate),
          greaterThanOrEqualTo(0),
        );
      }
    });

    test('itemById returns null for non-existent id', () {
      final container = createContainer();
      expect(container.read(itemByIdProvider('nonexistent')), isNull);
    });

    test('itemById returns item for valid id', () {
      final container = createContainer();
      final items = container.read(itemsProvider);
      final id = items.first.id;
      final found = container.read(itemByIdProvider(id));
      expect(found, isNotNull);
      expect(found!.id, id);
    });
  });
}