import 'dart:ui';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'color_converter.dart';

part 'generated/platform_data.freezed.dart';
part 'generated/platform_data.g.dart';

@freezed
abstract class TutorialStep with _$TutorialStep {
  const factory TutorialStep({
    required String title,
    required String desc,
  }) = _TutorialStep;

  factory TutorialStep.fromJson(Map<String, dynamic> json) =>
      _$TutorialStepFromJson(json);
}

@freezed
abstract class PlatformData with _$PlatformData {
  const factory PlatformData({
    required String key,
    required String name,
    required String emoji,
    required String iconText,
    required bool connected,
    required int orderEstimate,
    @ColorConverter() required List<Color> gradientColors,
    required List<TutorialStep> steps,
  }) = _PlatformData;

  factory PlatformData.fromJson(Map<String, dynamic> json) =>
      _$PlatformDataFromJson(json);
}
