import 'dart:ui';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'color_converter.dart';

part 'generated/photo_data.freezed.dart';
part 'generated/photo_data.g.dart';

@freezed
abstract class PhotoData with _$PhotoData {
  const factory PhotoData({
    required String emoji,
    @ColorConverter() required Color color,
  }) = _PhotoData;

  factory PhotoData.fromJson(Map<String, dynamic> json) =>
      _$PhotoDataFromJson(json);
}

/// 模拟照片 emoji 列表
const List<String> photoEmojis = ['📷', '🖼️', '📸', '🏞️', '🏠', '✨'];

/// 模拟照片背景色列表
const List<Color> photoColors = [
  Color(0xFFFFE8CC),
  Color(0xFFE8F5E9),
  Color(0xFFE3F2FD),
  Color(0xFFF3E5F5),
  Color(0xFFFFF9C4),
  Color(0xFFFFEBEE),
];
