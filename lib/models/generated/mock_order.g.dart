// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../mock_order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MockOrder _$MockOrderFromJson(Map<String, dynamic> json) => _MockOrder(
  emoji: json['emoji'] as String,
  name: json['name'] as String,
  price: json['price'] as String,
  status:
      $enumDecodeNullable(_$OrderStatusEnumMap, json['status']) ??
      OrderStatus.pending,
);

Map<String, dynamic> _$MockOrderToJson(_MockOrder instance) =>
    <String, dynamic>{
      'emoji': instance.emoji,
      'name': instance.name,
      'price': instance.price,
      'status': _$OrderStatusEnumMap[instance.status]!,
    };

const _$OrderStatusEnumMap = {
  OrderStatus.pending: 'pending',
  OrderStatus.success: 'success',
  OrderStatus.fail: 'fail',
};
