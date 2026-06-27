import 'dart:ui';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'color_converter.dart';

part 'generated/history_record.freezed.dart';
part 'generated/history_record.g.dart';

@freezed
abstract class HistoryRecord with _$HistoryRecord {
  const factory HistoryRecord({
    required String emoji,
    required String title,
    required String meta,
    required int count,
    @ColorConverter() required Color iconBg,
  }) = _HistoryRecord;

  factory HistoryRecord.fromJson(Map<String, dynamic> json) =>
      _$HistoryRecordFromJson(json);
}
