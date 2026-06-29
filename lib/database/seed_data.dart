part of 'database.dart';

/// 种子数据 —— 仅在数据库首次创建时插入。
///
/// 包含：
/// - 12 个内置分类（isBuiltIn = true）
/// - 2 项默认用户设置（昵称、头像）
/// - 3 个默认收纳空间（卧室、厨房、客厅），每空间含默认柜体和区域
class SeedData {
  // ────────────────────────────────────────────────
  // 分类（内置，isBuiltIn = true）
  // ────────────────────────────────────────────────

  static List<CategoriesCompanion> get categories => [
    CategoriesCompanion.insert(
      id: 'digital',
      label: '数码',
      emoji: '📱',
      isBuiltIn: const Value(true),
      sortOrder: const Value(0),
    ),
    CategoriesCompanion.insert(
      id: 'appliance',
      label: '家电',
      emoji: '🏠',
      isBuiltIn: const Value(true),
      sortOrder: const Value(1),
    ),
    CategoriesCompanion.insert(
      id: 'skincare',
      label: '护肤',
      emoji: '💄',
      isBuiltIn: const Value(true),
      sortOrder: const Value(2),
    ),
    CategoriesCompanion.insert(
      id: 'kitchen',
      label: '厨房',
      emoji: '🍚',
      isBuiltIn: const Value(true),
      sortOrder: const Value(3),
    ),
    CategoriesCompanion.insert(
      id: 'clothing',
      label: '衣物',
      emoji: '👔',
      isBuiltIn: const Value(true),
      sortOrder: const Value(4),
    ),
    CategoriesCompanion.insert(
      id: 'books',
      label: '书籍',
      emoji: '📚',
      isBuiltIn: const Value(true),
      sortOrder: const Value(5),
    ),
    CategoriesCompanion.insert(
      id: 'storage',
      label: '收纳',
      emoji: '📦',
      isBuiltIn: const Value(true),
      sortOrder: const Value(6),
    ),
    CategoriesCompanion.insert(
      id: 'toy',
      label: '玩具',
      emoji: '🧸',
      isBuiltIn: const Value(true),
      sortOrder: const Value(7),
    ),
    CategoriesCompanion.insert(
      id: 'sports',
      label: '运动',
      emoji: '🏋️',
      isBuiltIn: const Value(true),
      sortOrder: const Value(8),
    ),
    CategoriesCompanion.insert(
      id: 'stationery',
      label: '文具',
      emoji: '🎨',
      isBuiltIn: const Value(true),
      sortOrder: const Value(9),
    ),
    CategoriesCompanion.insert(
      id: 'keys',
      label: '钥匙',
      emoji: '🔑',
      isBuiltIn: const Value(true),
      sortOrder: const Value(10),
    ),
    CategoriesCompanion.insert(
      id: 'tools',
      label: '工具',
      emoji: '🔧',
      isBuiltIn: const Value(true),
      sortOrder: const Value(11),
    ),
  ];

  // ────────────────────────────────────────────────
  // 用户设置（默认值）
  // ────────────────────────────────────────────────

  static List<SettingsCompanion> get settings => [
    SettingsCompanion.insert(key: 'nickname', value: const Value('小橘')),
    SettingsCompanion.insert(key: 'avatar_emoji', value: const Value('🧑')),
  ];

  // ────────────────────────────────────────────────
  // 默认收纳空间（3 个房间 → 3 个柜体 → 3 个区域）
  // ────────────────────────────────────────────────

  static List<RoomsCompanion> get defaultRooms => [
    RoomsCompanion.insert(
      id: 'room_bedroom',
      name: '卧室',
      emoji: '🛏️',
      color: 0xFFE8F5E9,
    ),
    RoomsCompanion.insert(
      id: 'room_kitchen',
      name: '厨房',
      emoji: '🍳',
      color: 0xFFFFD4D4,
    ),
    RoomsCompanion.insert(
      id: 'room_living',
      name: '客厅',
      emoji: '🛋️',
      color: 0xFFFFE8CC,
    ),
  ];

  static List<CabinetsCompanion> get defaultCabinets => [
    // 卧室
    CabinetsCompanion.insert(
      id: 'cab_bedroom_wardrobe',
      name: '主柜体',
      emoji: '👔',
      color: 0xFFE8F5E9,
      roomId: 'room_bedroom',
      hasPhoto: const Value(true),
    ),
    // 厨房
    CabinetsCompanion.insert(
      id: 'cab_kitchen_upper',
      name: '主柜体',
      emoji: '🍽️',
      color: 0xFFFFD4D4,
      roomId: 'room_kitchen',
      hasPhoto: const Value(true),
    ),
    // 客厅
    CabinetsCompanion.insert(
      id: 'cab_living_tvstand',
      name: '主柜体',
      emoji: '📺',
      color: 0xFFFFE8CC,
      roomId: 'room_living',
      hasPhoto: const Value(true),
    ),
  ];

  static List<SlotsCompanion> get defaultSlots => [
    // 卧室 · 衣柜
    SlotsCompanion.insert(
      id: 'slot_wardrobe_main',
      name: '主区域',
      emoji: '👔',
      color: 0xFFD4F5D9,
      cabinetId: 'cab_bedroom_wardrobe',
    ),
    // 厨房 · 吊柜
    SlotsCompanion.insert(
      id: 'slot_kitchen_main',
      name: '主区域',
      emoji: '🍽️',
      color: 0xFFFFEBEB,
      cabinetId: 'cab_kitchen_upper',
    ),
    // 客厅 · 电视柜
    SlotsCompanion.insert(
      id: 'slot_living_main',
      name: '主区域',
      emoji: '📺',
      color: 0xFFFFF3CC,
      cabinetId: 'cab_living_tvstand',
    ),
  ];

  // Items、SpaceItems、ImportHistory 不再预置种子数据，首次安装后为空表。
  static List<ItemsCompanion> get items => [];
  static List<SpaceItemsCompanion> get spaceItems => [];
  static List<ImportHistoryCompanion> get importHistory => [];
}
