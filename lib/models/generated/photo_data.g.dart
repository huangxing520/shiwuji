// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../photo_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PhotoData _$PhotoDataFromJson(Map<String, dynamic> json) => _PhotoData(
  emoji: json['emoji'] as String,
  color: const ColorConverter().fromJson((json['color'] as num).toInt()),
);

Map<String, dynamic> _$PhotoDataToJson(_PhotoData instance) =>
    <String, dynamic>{
      'emoji': instance.emoji,
      'color': const ColorConverter().toJson(instance.color),
    };
