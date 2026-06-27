import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/category_item.freezed.dart';
part 'generated/category_item.g.dart';

@freezed
abstract class CategoryItem with _$CategoryItem {
  const factory CategoryItem({
    required String id,
    required String label,
    required String emoji,
    required bool isBuiltIn,
    @Default(0) int sortOrder,
  }) = _CategoryItem;

  factory CategoryItem.fromJson(Map<String, dynamic> json) =>
      _$CategoryItemFromJson(json);
}
