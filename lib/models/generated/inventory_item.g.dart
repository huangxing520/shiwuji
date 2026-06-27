// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../inventory_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_InventoryItem _$InventoryItemFromJson(Map<String, dynamic> json) =>
    _InventoryItem(
      id: json['id'] as String,
      emoji: json['emoji'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      location: json['location'] as String,
      price: (json['price'] as num).toDouble(),
      status: $enumDecode(_$ItemStatusEnumMap, json['status']),
      statusLabel: json['statusLabel'] as String,
      categoryKey: json['categoryKey'] as String,
    );

Map<String, dynamic> _$InventoryItemToJson(_InventoryItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'emoji': instance.emoji,
      'name': instance.name,
      'category': instance.category,
      'location': instance.location,
      'price': instance.price,
      'status': _$ItemStatusEnumMap[instance.status]!,
      'statusLabel': instance.statusLabel,
      'categoryKey': instance.categoryKey,
    };

const _$ItemStatusEnumMap = {
  ItemStatus.safe: 'safe',
  ItemStatus.expiring: 'expiring',
  ItemStatus.idle: 'idle',
  ItemStatus.underWarranty: 'underWarranty',
};
