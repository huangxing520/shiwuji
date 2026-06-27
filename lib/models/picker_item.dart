import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/picker_item.freezed.dart';
part 'generated/picker_item.g.dart';

@freezed
abstract class PickerItem with _$PickerItem {
  const factory PickerItem({
    required String emoji,
    required String name,
  }) = _PickerItem;

  factory PickerItem.fromJson(Map<String, dynamic> json) =>
      _$PickerItemFromJson(json);
}

/// 分类选项
const List<PickerItem> categoryData = [
  PickerItem(emoji: '📱', name: '数码'),
  PickerItem(emoji: '🏠', name: '家电'),
  PickerItem(emoji: '💄', name: '护肤'),
  PickerItem(emoji: '🍚', name: '厨房'),
  PickerItem(emoji: '👔', name: '衣物'),
  PickerItem(emoji: '📚', name: '书籍'),
  PickerItem(emoji: '📦', name: '收纳'),
  PickerItem(emoji: '🧸', name: '玩具'),
  PickerItem(emoji: '🏋️', name: '运动'),
  PickerItem(emoji: '🎨', name: '文具'),
  PickerItem(emoji: '🔑', name: '钥匙'),
  PickerItem(emoji: '🔧', name: '工具'),
];

/// 位置选项
const List<PickerItem> locationData = [
  PickerItem(emoji: '🛋️', name: '客厅'),
  PickerItem(emoji: '🛏️', name: '卧室'),
  PickerItem(emoji: '📚', name: '书房'),
  PickerItem(emoji: '🍳', name: '厨房'),
  PickerItem(emoji: '🚿', name: '浴室'),
  PickerItem(emoji: '🗄️', name: '储物间'),
  PickerItem(emoji: '🚪', name: '玄关'),
  PickerItem(emoji: '🧒', name: '儿童房'),
  PickerItem(emoji: '♿', name: '阳台'),
  PickerItem(emoji: '🚗', name: '车里'),
  PickerItem(emoji: '🏢', name: '办公室'),
  PickerItem(emoji: '🎒', name: '随身包'),
];
