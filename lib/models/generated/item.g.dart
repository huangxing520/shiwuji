// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Item _$ItemFromJson(Map<String, dynamic> json) => _Item(
  id: json['id'] as String,
  name: json['name'] as String,
  price: (json['price'] as num).toDouble(),
  emoji: json['emoji'] as String? ?? '',
  category: json['category'] as String? ?? '未分类',
  location: json['location'] as String? ?? '未知',
  purchaseDate: DateTime.parse(json['purchaseDate'] as String),
  warrantyDays: (json['warrantyDays'] as num?)?.toInt() ?? 365,
  status: json['status'] as String? ?? 'safe',
  categoryKey: json['categoryKey'] as String? ?? '',
  cabinetId: json['cabinetId'] as String?,
  slotId: json['slotId'] as String?,
  photos:
      (json['photos'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  brand: json['brand'] as String? ?? '',
  note: json['note'] as String? ?? '',
  templateKey: json['templateKey'] as String? ?? 'none',
  templateData:
      (json['templateData'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      const {},
);

Map<String, dynamic> _$ItemToJson(_Item instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'price': instance.price,
  'emoji': instance.emoji,
  'category': instance.category,
  'location': instance.location,
  'purchaseDate': instance.purchaseDate.toIso8601String(),
  'warrantyDays': instance.warrantyDays,
  'status': instance.status,
  'categoryKey': instance.categoryKey,
  'cabinetId': instance.cabinetId,
  'slotId': instance.slotId,
  'photos': instance.photos,
  'brand': instance.brand,
  'note': instance.note,
  'templateKey': instance.templateKey,
  'templateData': instance.templateData,
};
