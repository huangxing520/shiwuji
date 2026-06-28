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
    @Default(365) int warrantyDays,
    @Default('safe') String status,
    @Default('') String categoryKey,
    String? cabinetId,
    String? slotId,
    @Default([]) List<String> photos,
    @Default('') String brand,
    @Default('') String note,
    @Default('none') String templateKey,
    @Default({}) Map<String, String> templateData,
  }) = _Item;

  factory Item.fromJson(Map<String, dynamic> json) => _$ItemFromJson(json);

  factory Item.create({
    required String name,
    required double price,
    String emoji = '',
    String category = '未分类',
    String location = '未知',
    DateTime? purchaseDate,
    int warrantyDays = 365,
    String status = 'safe',
    String categoryKey = '',
    String? cabinetId,
    String? slotId,
    List<String> photos = const [],
    String brand = '',
    String note = '',
    String templateKey = 'none',
    Map<String, String> templateData = const {},
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
      status: status,
      categoryKey: categoryKey,
      cabinetId: cabinetId,
      slotId: slotId,
      photos: photos,
      brand: brand,
      note: note,
      templateKey: templateKey,
      templateData: templateData,
    );
  }

  DateTime get warrantyEndDate =>
      purchaseDate.add(Duration(days: warrantyDays));

  int get daysUntilWarrantyExpiry =>
      warrantyEndDate.difference(DateTime.now()).inDays;

  bool get isWarrantyExpired => daysUntilWarrantyExpiry < 0;

  bool get isWarrantyExpiringSoon =>
      !isWarrantyExpired && daysUntilWarrantyExpiry <= 7;

  bool get isUnderWarranty => !isWarrantyExpired;

  /// 保修状态统一推导：以日期实时计算，作为页面显示的唯一真相源。
  /// 已过保 → idle；7 天内到期 → expiring；其余在保 → underWarranty。
  /// （废弃静态 status 字段的业务用途，避免冻结值与实际状态不符。）
  ItemStatus get warrantyStatus {
    if (isWarrantyExpired) return ItemStatus.idle;
    if (isWarrantyExpiringSoon) return ItemStatus.expiring;
    return ItemStatus.underWarranty;
  }
}
