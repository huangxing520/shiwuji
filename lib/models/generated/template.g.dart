// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../template.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TemplateField _$TemplateFieldFromJson(Map<String, dynamic> json) =>
    _TemplateField(
      label: json['label'] as String,
      placeholder: json['placeholder'] as String,
      id: json['id'] as String,
      isDate: json['isDate'] as bool? ?? false,
    );

Map<String, dynamic> _$TemplateFieldToJson(_TemplateField instance) =>
    <String, dynamic>{
      'label': instance.label,
      'placeholder': instance.placeholder,
      'id': instance.id,
      'isDate': instance.isDate,
    };

_TemplateData _$TemplateDataFromJson(Map<String, dynamic> json) =>
    _TemplateData(
      name: json['name'] as String,
      fields: (json['fields'] as List<dynamic>)
          .map((e) => TemplateField.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TemplateDataToJson(_TemplateData instance) =>
    <String, dynamic>{'name': instance.name, 'fields': instance.fields};
