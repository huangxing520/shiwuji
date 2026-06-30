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
      expect(item.warrantyDays, 0);
      expect(item.shelfLifeDays, 0);
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
      final a = Item(id: '1', name: 'A', price: 100, purchaseDate: fixedDate);
      final b = Item(id: '2', name: 'B', price: 200, purchaseDate: fixedDate);
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

    test('hasWarranty: true when warrantyDays > 0', () {
      final item = Item(
        id: '1',
        name: 'Test',
        price: 100,
        purchaseDate: fixedDate,
        warrantyDays: 365,
        warrantyReminderOn: true,
      );
      expect(item.hasWarranty, true);
    });

    test('hasWarranty: true when warrantyDays > 0 even if reminder off', () {
      // 信息与提醒解耦：warrantyDays > 0 即视为有保修，与 warrantyReminderOn 无关
      final item = Item(
        id: '1',
        name: 'Test',
        price: 100,
        purchaseDate: fixedDate,
        warrantyDays: 730,
        warrantyReminderOn: false,
      );
      expect(item.hasWarranty, true);
    });

    test('hasWarranty defaults to false (reminder off)', () {
      final item = Item.create(name: 'Test', price: 100);
      expect(item.hasWarranty, false);
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

    test('shelfLifeDays defaults to 0 and hasShelfLife is false', () {
      final item = Item.create(name: 'Test', price: 100);
      expect(item.shelfLifeDays, 0);
      expect(item.hasShelfLife, false);
    });

    test('hasShelfLife true when shelfLifeDays > 0', () {
      final item = Item(
        id: '1',
        name: 'Test',
        price: 100,
        purchaseDate: fixedDate,
        shelfLifeDays: 180,
      );
      expect(item.hasShelfLife, true);
    });

    test('shelfLifeEndDate = purchaseDate + shelfLifeDays', () {
      final item = Item(
        id: '1',
        name: 'Test',
        price: 100,
        purchaseDate: fixedDate,
        shelfLifeDays: 30,
      );
      expect(item.shelfLifeEndDate, DateTime(2024, 7, 15));
    });

    test('isShelfLifeExpired: past expiry', () {
      final item = Item(
        id: '1',
        name: 'Test',
        price: 100,
        purchaseDate: DateTime.now().subtract(const Duration(days: 400)),
        shelfLifeDays: 30,
      );
      expect(item.isShelfLifeExpired, true);
      expect(item.isShelfLifeExpiringSoon, false);
    });

    test('isShelfLifeExpiringSoon: 5 days left', () {
      final item = Item(
        id: '1',
        name: 'Test',
        price: 100,
        purchaseDate: DateTime.now().subtract(const Duration(days: 25)),
        shelfLifeDays: 30,
      );
      expect(item.isShelfLifeExpiringSoon, true);
      expect(item.isShelfLifeExpired, false);
    });

    test('shelfLifeDays 0: expiry getters all false even for old purchase', () {
      final item = Item(
        id: '1',
        name: 'Test',
        price: 100,
        purchaseDate: DateTime.now().subtract(const Duration(days: 999)),
        shelfLifeDays: 0,
      );
      expect(item.hasShelfLife, false);
      expect(item.isShelfLifeExpired, false);
      expect(item.isShelfLifeExpiringSoon, false);
    });

    // ─── 定期保养（maintenance）派生属性 ────────────────────
    test('maintenance defaults: empty cycle, reminder off', () {
      // 模型默认 maintenanceCycle = ''（未设置），与表单默认 '每半年' 区分
      final item = Item.create(name: 'Test', price: 100);
      expect(item.maintenanceCycle, '');
      expect(item.maintenanceReminderOn, false);
      expect(item.source, '线下购买');
    });

    test('daysUntilNextMaintenance: purchase today → full cycle (180)', () {
      final item = Item(
        id: '1',
        name: 'Test',
        price: 100,
        purchaseDate: DateTime.now(),
        maintenanceReminderOn: true,
        maintenanceCycle: '每半年',
      );
      expect(item.daysUntilNextMaintenance, 180);
    });

    test(
      'daysUntilNextMaintenance: 10 days elapsed in 30-day cycle → 20 left',
      () {
        final item = Item(
          id: '1',
          name: 'Test',
          price: 100,
          purchaseDate: DateTime.now().subtract(const Duration(days: 10)),
          maintenanceReminderOn: true,
          maintenanceCycle: '每月',
        );
        expect(item.daysUntilNextMaintenance, 20);
      },
    );

    test('daysUntilNextMaintenance: exactly on cycle boundary → 0', () {
      final item = Item(
        id: '1',
        name: 'Test',
        price: 100,
        purchaseDate: DateTime.now().subtract(const Duration(days: 90)),
        maintenanceReminderOn: true,
        maintenanceCycle: '每季度',
      );
      expect(item.daysUntilNextMaintenance, 0);
      expect(item.isMaintenanceDueSoon, true);
    });

    test(
      'daysUntilNextMaintenance: yearly cycle, 100 days elapsed → 265 left',
      () {
        final item = Item(
          id: '1',
          name: 'Test',
          price: 100,
          purchaseDate: DateTime.now().subtract(const Duration(days: 100)),
          maintenanceReminderOn: true,
          maintenanceCycle: '每年',
        );
        expect(item.daysUntilNextMaintenance, 265);
      },
    );

    test('nextMaintenanceDate is in the future for purchase today', () {
      final now = DateTime.now();
      final item = Item(
        id: '1',
        name: 'Test',
        price: 100,
        purchaseDate: now,
        maintenanceReminderOn: true,
        maintenanceCycle: '每月',
      );
      // 购买当天 → 下次保养日 = 购买日 + 30 天
      expect(item.nextMaintenanceDate, now.add(const Duration(days: 30)));
    });
  });
}
