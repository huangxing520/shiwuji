import 'dart:ui';
import 'package:freezed_annotation/freezed_annotation.dart';

/// Color <-> int JSON 转换器
///
/// 序列化为 Color.value（int），反序列化通过 Color() 还原。
const colorConverter = ColorConverter();

class ColorConverter implements JsonConverter<Color, int> {
  const ColorConverter();

  @override
  Color fromJson(int json) => Color(json);

  @override
  int toJson(Color object) => object.toARGB32();
}
