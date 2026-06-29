import 'dart:ui';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'color_converter.dart';

part 'generated/storage.freezed.dart';
part 'generated/storage.g.dart';

@freezed
abstract class Room with _$Room {
  const factory Room({
    required String id,
    required String name,
    required String emoji,
    @ColorConverter() required Color color,
    required int items,
    required int storageCount,
    required int occupation,
  }) = _Room;

  factory Room.fromJson(Map<String, dynamic> json) => _$RoomFromJson(json);
}

@freezed
abstract class Cabinet with _$Cabinet {
  const factory Cabinet({
    required String id,
    required String name,
    required String emoji,
    @ColorConverter() required Color color,
    required int items,
    required int occupation,
    required bool hasPhoto,
    required int expectedItems,
  }) = _Cabinet;

  factory Cabinet.fromJson(Map<String, dynamic> json) =>
      _$CabinetFromJson(json);
}

@freezed
abstract class Slot with _$Slot {
  const factory Slot({
    required String id,
    required String name,
    required String emoji,
    @ColorConverter() required Color color,
    required int items,
    required int occupation,
    required int expectedItems,
  }) = _Slot;

  factory Slot.fromJson(Map<String, dynamic> json) => _$SlotFromJson(json);
}

@freezed
abstract class SpaceItem with _$SpaceItem {
  const factory SpaceItem({
    required int id,
    required String emoji,
    required String name,
    required String meta,
  }) = _SpaceItem;

  factory SpaceItem.fromJson(Map<String, dynamic> json) =>
      _$SpaceItemFromJson(json);
}
