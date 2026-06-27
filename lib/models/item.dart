import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

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
    );
  }

  DateTime get warrantyEndDate => purchaseDate.add(Duration(days: warrantyDays));

  int get daysUntilWarrantyExpiry =>
      warrantyEndDate.difference(DateTime.now()).inDays;

  bool get isWarrantyExpired => daysUntilWarrantyExpiry < 0;

  bool get isWarrantyExpiringSoon =>
      !isWarrantyExpired && daysUntilWarrantyExpiry <= 7;

  bool get isUnderWarranty => !isWarrantyExpired;
}