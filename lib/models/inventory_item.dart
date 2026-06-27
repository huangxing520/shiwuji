import 'package:freezed_annotation/freezed_annotation.dart';
import 'enums/item_status.dart';

part 'generated/inventory_item.freezed.dart';
part 'generated/inventory_item.g.dart';

@freezed
abstract class InventoryItem with _$InventoryItem {
  const factory InventoryItem({
    required String id,
    required String emoji,
    required String name,
    required String category,
    required String location,
    required double price,
    required ItemStatus status,
    required String statusLabel,
    required String categoryKey,
  }) = _InventoryItem;

  factory InventoryItem.fromJson(Map<String, dynamic> json) =>
      _$InventoryItemFromJson(json);
}

/// 分类信息
class Category {
  final String key;
  final String label;
  const Category(this.key, this.label);

  static const List<Category> all = [
    Category('all', '全部'),
    Category('digital', '数码'),
    Category('appliance', '家电'),
    Category('skincare', '护肤'),
    Category('kitchen', '厨房'),
    Category('clothing', '衣物'),
    Category('books', '书籍'),
    Category('storage', '收纳'),
    Category('membership', '会员订阅'),
    Category('sim_card', '网卡流量'),
    Category('license', '数字许可证'),
    Category('gift_card', '礼品卡'),
  ];
}

/// Mock 数据 - 种子数据
const List<InventoryItem> seedInventoryItems = [
  InventoryItem(
    id: '1',
    emoji: '🧹',
    name: '戴森V12吸尘器',
    category: '家电',
    location: '客厅收纳柜',
    price: 3990,
    status: ItemStatus.safe,
    statusLabel: '安全',
    categoryKey: 'appliance',
  ),
  InventoryItem(
    id: '2',
    emoji: '🎧',
    name: 'AirPods Pro 2',
    category: '数码',
    location: '书房桌面',
    price: 1899,
    status: ItemStatus.underWarranty,
    statusLabel: '在保',
    categoryKey: 'digital',
  ),
  InventoryItem(
    id: '3',
    emoji: '💊',
    name: '兰蔻小黑瓶精华',
    category: '护肤',
    location: '卧室梳妆台',
    price: 1080,
    status: ItemStatus.expiring,
    statusLabel: '即将到期',
    categoryKey: 'skincare',
  ),
  InventoryItem(
    id: '4',
    emoji: '📦',
    name: '宜家思库布收纳箱×3',
    category: '收纳',
    location: '储物间',
    price: 149,
    status: ItemStatus.idle,
    statusLabel: '闲置',
    categoryKey: 'storage',
  ),
  InventoryItem(
    id: '5',
    emoji: '🎵',
    name: '索尼WH-1000XM5',
    category: '数码',
    location: '书房',
    price: 2499,
    status: ItemStatus.underWarranty,
    statusLabel: '在保',
    categoryKey: 'digital',
  ),
  InventoryItem(
    id: '6',
    emoji: '🍚',
    name: '美的电饭煲',
    category: '厨房',
    location: '料理台',
    price: 399,
    status: ItemStatus.safe,
    statusLabel: '安全',
    categoryKey: 'kitchen',
  ),
  InventoryItem(
    id: '7',
    emoji: '✨',
    name: 'SK-II神仙水230ml',
    category: '护肤',
    location: '卧室梳妆台',
    price: 1590,
    status: ItemStatus.expiring,
    statusLabel: '即将到期',
    categoryKey: 'skincare',
  ),
  InventoryItem(
    id: '8',
    emoji: '🧱',
    name: '乐高建筑系列·悉尼',
    category: '书籍',
    location: '书架第二层',
    price: 599,
    status: ItemStatus.idle,
    statusLabel: '闲置',
    categoryKey: 'books',
  ),
];

/// Mock 数据 - 更多数据
const List<InventoryItem> moreInventoryItems = [
  InventoryItem(
    id: '9',
    emoji: '👔',
    name: '优衣库轻薄羽绒服',
    category: '衣物',
    location: '衣柜左侧',
    price: 499,
    status: ItemStatus.safe,
    statusLabel: '安全',
    categoryKey: 'clothing',
  ),
  InventoryItem(
    id: '10',
    emoji: '📱',
    name: 'iPhone 15手机壳',
    category: '数码',
    location: '书房抽屉',
    price: 89,
    status: ItemStatus.idle,
    statusLabel: '闲置',
    categoryKey: 'digital',
  ),
  InventoryItem(
    id: '11',
    emoji: '🍳',
    name: '不粘煎锅26cm',
    category: '厨房',
    location: '厨房吊柜',
    price: 159,
    status: ItemStatus.safe,
    statusLabel: '安全',
    categoryKey: 'kitchen',
  ),
  InventoryItem(
    id: '12',
    emoji: '📖',
    name: '设计中的设计·原研哉',
    category: '书籍',
    location: '书架第一层',
    price: 48,
    status: ItemStatus.safe,
    statusLabel: '安全',
    categoryKey: 'books',
  ),
];
