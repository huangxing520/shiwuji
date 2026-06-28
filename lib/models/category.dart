/// 分类数据结构，用于物品库 tab 筛选与新增物品页分类选择。
///
/// 与 DB `categories` 表（分类管理页，用户自定义实物分类）配合使用：
/// 运行时由 `availableCategoriesProvider` 派生为
/// [数据库分类] + [virtualCategories 虚拟物品分类] 的合并列表。
///
/// 虚拟物品分类（会员订阅、网卡流量、数字许可证、礼品卡）无对应数据库记录，
/// 不参与用户增删管理，仅可通过品类模版设置，故作为固定项保留。
class Category {
  final String key;
  final String label;
  final String emoji;
  const Category(this.key, this.label, {this.emoji = ''});

  /// 虚拟物品分类（不在 categories 表中，仅通过品类模版设置）
  /// 这些分类的物品 categoryKey 直接使用 key 值，无法被用户在分类管理页删除
  static const List<Category> virtualCategories = [
    Category('membership', '会员订阅', emoji: '💳'),
    Category('sim_card', '网卡流量', emoji: '📶'),
    Category('license', '数字许可证', emoji: '🔑'),
    Category('gift_card', '礼品卡', emoji: '🎁'),
  ];
}
