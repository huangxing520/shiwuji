// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../platform_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TutorialStep _$TutorialStepFromJson(Map<String, dynamic> json) =>
    _TutorialStep(title: json['title'] as String, desc: json['desc'] as String);

Map<String, dynamic> _$TutorialStepToJson(_TutorialStep instance) =>
    <String, dynamic>{'title': instance.title, 'desc': instance.desc};

_PlatformData _$PlatformDataFromJson(Map<String, dynamic> json) =>
    _PlatformData(
      key: json['key'] as String,
      name: json['name'] as String,
      emoji: json['emoji'] as String,
      iconText: json['iconText'] as String,
      connected: json['connected'] as bool,
      orderEstimate: (json['orderEstimate'] as num).toInt(),
      gradientColors: (json['gradientColors'] as List<dynamic>)
          .map((e) => const ColorConverter().fromJson((e as num).toInt()))
          .toList(),
      steps: (json['steps'] as List<dynamic>)
          .map((e) => TutorialStep.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PlatformDataToJson(_PlatformData instance) =>
    <String, dynamic>{
      'key': instance.key,
      'name': instance.name,
      'emoji': instance.emoji,
      'iconText': instance.iconText,
      'connected': instance.connected,
      'orderEstimate': instance.orderEstimate,
      'gradientColors': instance.gradientColors
          .map(const ColorConverter().toJson)
          .toList(),
      'steps': instance.steps,
    };
