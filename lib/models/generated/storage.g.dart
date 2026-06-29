// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../storage.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Room _$RoomFromJson(Map<String, dynamic> json) => _Room(
  id: json['id'] as String,
  name: json['name'] as String,
  emoji: json['emoji'] as String,
  color: const ColorConverter().fromJson((json['color'] as num).toInt()),
  items: (json['items'] as num).toInt(),
  storageCount: (json['storageCount'] as num).toInt(),
  occupation: (json['occupation'] as num).toInt(),
);

Map<String, dynamic> _$RoomToJson(_Room instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'emoji': instance.emoji,
  'color': const ColorConverter().toJson(instance.color),
  'items': instance.items,
  'storageCount': instance.storageCount,
  'occupation': instance.occupation,
};

_Cabinet _$CabinetFromJson(Map<String, dynamic> json) => _Cabinet(
  id: json['id'] as String,
  name: json['name'] as String,
  emoji: json['emoji'] as String,
  color: const ColorConverter().fromJson((json['color'] as num).toInt()),
  items: (json['items'] as num).toInt(),
  occupation: (json['occupation'] as num).toInt(),
  hasPhoto: json['hasPhoto'] as bool,
  expectedItems: (json['expectedItems'] as num).toInt(),
  photoPath: json['photoPath'] as String?,
);

Map<String, dynamic> _$CabinetToJson(_Cabinet instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'emoji': instance.emoji,
  'color': const ColorConverter().toJson(instance.color),
  'items': instance.items,
  'occupation': instance.occupation,
  'hasPhoto': instance.hasPhoto,
  'expectedItems': instance.expectedItems,
  'photoPath': instance.photoPath,
};

_Slot _$SlotFromJson(Map<String, dynamic> json) => _Slot(
  id: json['id'] as String,
  name: json['name'] as String,
  emoji: json['emoji'] as String,
  color: const ColorConverter().fromJson((json['color'] as num).toInt()),
  items: (json['items'] as num).toInt(),
  occupation: (json['occupation'] as num).toInt(),
  expectedItems: (json['expectedItems'] as num).toInt(),
);

Map<String, dynamic> _$SlotToJson(_Slot instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'emoji': instance.emoji,
  'color': const ColorConverter().toJson(instance.color),
  'items': instance.items,
  'occupation': instance.occupation,
  'expectedItems': instance.expectedItems,
};

_SpaceItem _$SpaceItemFromJson(Map<String, dynamic> json) => _SpaceItem(
  id: (json['id'] as num).toInt(),
  emoji: json['emoji'] as String,
  name: json['name'] as String,
  meta: json['meta'] as String,
);

Map<String, dynamic> _$SpaceItemToJson(_SpaceItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'emoji': instance.emoji,
      'name': instance.name,
      'meta': instance.meta,
    };
