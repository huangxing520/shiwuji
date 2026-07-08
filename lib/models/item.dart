import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';
import 'enums/item_status.dart';

part 'generated/item.freezed.dart';
part 'generated/item.g.dart';

@freezed
abstract class Item with _$Item {
  const Item._();

  const factory Item({
    required String id,
    required String name,
    required double price,
    @Default('') String emoji,
    @Default('未分类') String category,
    @Default('未知') String location,
    required DateTime purchaseDate,
    @Default(0) int warrantyDays,
    @Default(0) int shelfLifeDays,
    @Default('safe') String status,
    @Default('') String categoryKey,
    String? cabinetId,
    String? slotId,
    @Default([]) List<String> photos,
    @Default('') String brand,
    @Default('') String note,
    @Default('none') String templateKey,
    @Default({}) Map<String, String> templateData,
    @Default('线下购买') String source,
    @Default(false) bool warrantyReminderOn,
    @Default(false) bool shelfLifeReminderOn,
    @Default(false) bool maintenanceReminderOn,
    @Default('') String maintenanceCycle,
    @Default(false) bool isBorrowed,
  }) = _Item;

  factory Item.fromJson(Map<String, dynamic> json) => _$ItemFromJson(json);

  factory Item.create({
    required String name,
    required double price,
    String emoji = '',
    String category = '未分类',
    String location = '未知',
    DateTime? purchaseDate,
    int warrantyDays = 0,
    int shelfLifeDays = 0,
    String status = 'safe',
    String categoryKey = '',
    String? cabinetId,
    String? slotId,
    List<String> photos = const [],
    String brand = '',
    String note = '',
    String templateKey = 'none',
    Map<String, String> templateData = const {},
    String source = '线下购买',
    bool warrantyReminderOn = false,
    bool shelfLifeReminderOn = false,
    bool maintenanceReminderOn = false,
    String maintenanceCycle = '',
    bool isBorrowed = false,
  }) {
    return Item(
      id: const Uuid().v4(),
      name: name,
      price: price,
      emoji: emoji,
      category: category,
      location: location,
      purchaseDate: purchaseDate ?? DateTime.now(),
      warrantyDays: warrantyDays,
      shelfLifeDays: shelfLifeDays,
      status: status,
      categoryKey: categoryKey,
      cabinetId: cabinetId,
      slotId: slotId,
      photos: photos,
      brand: brand,
      note: note,
      templateKey: templateKey,
      templateData: templateData,
      source: source,
      warrantyReminderOn: warrantyReminderOn,
      shelfLifeReminderOn: shelfLifeReminderOn,
      maintenanceReminderOn: maintenanceReminderOn,
      maintenanceCycle: maintenanceCycle,
      isBorrowed: isBorrowed,
    );
  }

  DateTime get warrantyEndDate =>
      purchaseDate.add(Duration(days: warrantyDays));

  int get daysUntilWarrantyExpiry =>
      warrantyEndDate.difference(DateTime.now()).inDays;

  /// 保修期是否被显式设置：warrantyDays > 0 表示用户已设置保修期限。
  /// 与提醒开关（warrantyReminderOn）分离，允许仅记录保修信息而不开启提醒。
  bool get hasWarranty => warrantyDays > 0;

  bool get isWarrantyExpired => hasWarranty && daysUntilWarrantyExpiry < 0;

  bool get isWarrantyExpiringSoon =>
      hasWarranty && !isWarrantyExpired && daysUntilWarrantyExpiry <= 7;

  bool get isUnderWarranty => hasWarranty && !isWarrantyExpired;

  /// 保修状态统一推导：以日期实时计算，作为页面显示的唯一真相源。
  /// 未设置保修 → idle；已过保 → idle；7 天内到期 → expiring；其余在保 → underWarranty。
  ItemStatus get warrantyStatus {
    if (!hasWarranty) return ItemStatus.idle;
    if (isWarrantyExpired) return ItemStatus.idle;
    if (isWarrantyExpiringSoon) return ItemStatus.expiring;
    return ItemStatus.underWarranty;
  }

  // ─── 保质期（shelf life）派生属性 ───────────────────────
  // shelfLifeDays == 0 表示未设置保质期；>0 时以下 getter 才有意义。
  bool get hasShelfLife => shelfLifeDays > 0;

  DateTime get shelfLifeEndDate =>
      purchaseDate.add(Duration(days: shelfLifeDays));

  int get daysUntilShelfLifeExpiry =>
      shelfLifeEndDate.difference(DateTime.now()).inDays;

  bool get isShelfLifeExpired => hasShelfLife && daysUntilShelfLifeExpiry < 0;

  bool get isShelfLifeExpiringSoon =>
      hasShelfLife && !isShelfLifeExpired && daysUntilShelfLifeExpiry <= 7;

  // ─── 定期保养（maintenance）派生属性 ────────────────────
  // maintenanceCycle 为空字符串表示未设置保养；非空时以下 getter 才有意义。
  // 周期天数采用固定值（每月=30、每季度=90、每半年=180、每年=365），
  // 避免日历月差与闰年边界问题，对"剩余天数"展示足够。

  /// 保养是否被显式设置：maintenanceCycle 非空表示用户已选择保养周期。
  /// 与提醒开关（maintenanceReminderOn）分离，允许仅记录保养信息而不开启提醒。
  bool get hasMaintenance => maintenanceCycle.isNotEmpty;

  int get _maintenanceCycleDays {
    switch (maintenanceCycle) {
      case '每月':
        return 30;
      case '每季度':
        return 90;
      case '每半年':
        return 180;
      case '每年':
        return 365;
      default:
        return 180;
    }
  }

  /// 下次保养剩余天数：以购买日为周期起点，按 cycleDays 取模计算。
  /// - elapsed<=0（购买当天及之前）→ 返回完整周期天数
  /// - intoCycle=0 且 elapsed>0（恰逢保养日）→ 返回 0
  /// - 其余 → cycleDays - intoCycle
  int get daysUntilNextMaintenance {
    final cycleDays = _maintenanceCycleDays;
    final now = DateTime.now();
    final today = DateTime.utc(now.year, now.month, now.day);
    final purchase = DateTime.utc(
      purchaseDate.year,
      purchaseDate.month,
      purchaseDate.day,
    );
    final elapsed = today.difference(purchase).inDays;
    if (elapsed <= 0) return cycleDays;
    final intoCycle = elapsed % cycleDays;
    if (intoCycle == 0) return 0;
    return cycleDays - intoCycle;
  }

  /// 下次保养日期（用于详情弹窗展示）
  DateTime get nextMaintenanceDate {
    final cycleDays = _maintenanceCycleDays;
    final now = DateTime.now();
    final today = DateTime.utc(now.year, now.month, now.day);
    final purchase = DateTime.utc(
      purchaseDate.year,
      purchaseDate.month,
      purchaseDate.day,
    );
    final elapsed = today.difference(purchase).inDays;
    if (elapsed <= 0) return purchaseDate.add(Duration(days: cycleDays));
    final intoCycle = elapsed % cycleDays;
    final daysToNext = intoCycle == 0 ? 0 : (cycleDays - intoCycle);
    return purchaseDate.add(Duration(days: elapsed + daysToNext));
  }

  bool get isMaintenanceDueSoon =>
      hasMaintenance && maintenanceReminderOn && daysUntilNextMaintenance <= 7;
}
