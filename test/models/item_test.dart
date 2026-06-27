import 'package:flutter_test/flutter_test.dart';
import 'package:shi_wu_ji/models/item.dart';

void main() {
  group('Item', () {
    final fixedDate = DateTime(2024, 6, 15);

    test('Item.create generates unique IDs', () {
      final item1 = Item.create(name: 'Test', price: 100);
      final item2 = Item.create(name: 'Test', price: 100);
      expect(item1.id, isNot(equals(item2.id)));
    });

    test('Item.create uses default values', () {
      final item = Item.create(name: 'Test', price: 100);
      expect(item.category, '未分类');
      expect(item.location, '未知');
      expect(item.warrantyDays, 365);
      expect(item.emoji, '');
      expect(item.status, 'safe');
      expect(item.categoryKey, '');
    });

    test('Item.create accepts custom values', () {
      final item = Item.create(
        name: '笔记本电脑',
        price: 9999,
        category: '电子产品',
        location: '办公室',
        purchaseDate: fixedDate,
        warrantyDays: 730,
      );
      expect(item.name, '笔记本电脑');
      expect(item.price, 9999);
      expect(item.category, '电子产品');
      expect(item.location, '办公室');
      expect(item.purchaseDate, fixedDate);
      expect(item.warrantyDays, 730);
    });

    test('copyWith creates a new instance with updated fields', () {
      final item = Item(
        id: '1',
        name: 'Old',
        price: 100,
        purchaseDate: fixedDate,
      );
      final updated = item.copyWith(name: 'New', price: 200);
      expect(updated.id, '1');
      expect(updated.name, 'New');
      expect(updated.price, 200);
      expect(updated.purchaseDate, fixedDate);
      expect(updated, isNot(same(item)));
    });

    test('value equality: same values == equal', () {
      final a = Item(
        id: '1',
        name: 'Same',
        price: 100,
        purchaseDate: fixedDate,
      );
      final b = Item(
        id: '1',
        name: 'Same',
        price: 100,
        purchaseDate: fixedDate,
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('value equality: different values != equal', () {
      final a = Item(
        id: '1',
        name: 'A',
        price: 100,
        purchaseDate: fixedDate,
      );
      final b = Item(
        id: '2',
        name: 'B',
        price: 200,
        purchaseDate: fixedDate,
      );
      expect(a, isNot(equals(b)));
    });

    test('toString includes field values', () {
      final item = Item(
        id: '1',
        name: 'Test',
        price: 100,
        purchaseDate: fixedDate,
      );
      final str = item.toString();
      expect(str, contains('Test'));
      expect(str, contains('100'));
    });

    test('warrantyEndDate = purchaseDate + warrantyDays', () {
      final item = Item(
        id: '1',
        name: 'Test',
        price: 100,
        purchaseDate: fixedDate,
        warrantyDays: 30,
      );
      expect(item.warrantyEndDate, DateTime(2024, 7, 15));
    });

    test('isUnderWarranty: warranty not expired', () {
      final item = Item(
        id: '1',
        name: 'Test',
        price: 100,
        purchaseDate: DateTime.now().subtract(const Duration(days: 10)),
        warrantyDays: 30,
      );
      expect(item.isUnderWarranty, true);
      expect(item.isWarrantyExpired, false);
    });

    test('isWarrantyExpired: past warranty end date', () {
      final item = Item(
        id: '1',
        name: 'Test',
        price: 100,
        purchaseDate: DateTime.now().subtract(const Duration(days: 400)),
        warrantyDays: 365,
      );
      expect(item.isWarrantyExpired, true);
      expect(item.isUnderWarranty, false);
    });

    test('isWarrantyExpiringSoon: 5 days left', () {
      final item = Item(
        id: '1',
        name: 'Test',
        price: 100,
        purchaseDate: DateTime.now().subtract(const Duration(days: 360)),
        warrantyDays: 365,
      );
      expect(item.isWarrantyExpiringSoon, true);
      expect(item.isWarrantyExpired, false);
    });

    test('isWarrantyExpiringSoon: 8 days left (false)', () {
      final item = Item(
        id: '1',
        name: 'Test',
        price: 100,
        purchaseDate: DateTime.now().subtract(const Duration(days: 357)),
        warrantyDays: 365,
      );
      expect(item.isWarrantyExpiringSoon, false);
    });

    test('isWarrantyExpiringSoon: expired (false)', () {
      final item = Item(
        id: '1',
        name: 'Test',
        price: 100,
        purchaseDate: DateTime.now().subtract(const Duration(days: 400)),
        warrantyDays: 365,
      );
      expect(item.isWarrantyExpiringSoon, false);
    });

    test('daysUntilWarrantyExpiry: returns a positive integer', () {
      final item = Item(
        id: '1',
        name: 'Test',
        price: 100,
        purchaseDate: DateTime.now().subtract(const Duration(days: 358)),
        warrantyDays: 365,
      );
      expect(item.daysUntilWarrantyExpiry, greaterThanOrEqualTo(6));
      expect(item.daysUntilWarrantyExpiry, lessThanOrEqualTo(8));
    });
  });
}