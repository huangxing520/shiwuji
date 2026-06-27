// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../category_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CategoryItem _$CategoryItemFromJson(Map<String, dynamic> json) =>
    _CategoryItem(
      id: json['id'] as String,
      label: json['label'] as String,
      emoji: json['emoji'] as String,
      isBuiltIn: json['isBuiltIn'] as bool,
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$CategoryItemToJson(_CategoryItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'label': instance.label,
      'emoji': instance.emoji,
      'isBuiltIn': instance.isBuiltIn,
      'sortOrder': instance.sortOrder,
    };
