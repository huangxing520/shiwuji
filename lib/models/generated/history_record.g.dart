// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../history_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_HistoryRecord _$HistoryRecordFromJson(Map<String, dynamic> json) =>
    _HistoryRecord(
      emoji: json['emoji'] as String,
      title: json['title'] as String,
      meta: json['meta'] as String,
      count: (json['count'] as num).toInt(),
      iconBg: const ColorConverter().fromJson((json['iconBg'] as num).toInt()),
    );

Map<String, dynamic> _$HistoryRecordToJson(_HistoryRecord instance) =>
    <String, dynamic>{
      'emoji': instance.emoji,
      'title': instance.title,
      'meta': instance.meta,
      'count': instance.count,
      'iconBg': const ColorConverter().toJson(instance.iconBg),
    };
