/// Emoji 分类与动态更新系统。
///
/// 设计目标：
/// 1. 每个大类（与 [TemplateCard.key] 对齐）拥有一个默认 emoji；
/// 2. 大类下挂载若干二级分类，每个二级分类由「关键词 + 优先级 + 专属 emoji」定义；
/// 3. [EmojiClassifier.classify] 根据物品名称/品牌/备注等内容动态匹配关键词，
///    命中则返回优先级最高的二级分类 emoji，否则返回大类默认 emoji；
/// 4. 数据驱动、纯声明式，新增二级分类只需往 [_registry] 追加条目，无需改动匹配逻辑。
library;

/// 二级分类定义。
///
/// [keywords] 命中任意一个即视为匹配；[priority] 越大越优先
/// （当多个二级分类同时命中时，取 priority 最大的那个）。
class EmojiSubCategory {
  final String name;
  final List<String> keywords;
  final int priority;
  final String emoji;

  const EmojiSubCategory({
    required this.name,
    required this.keywords,
    required this.priority,
    required this.emoji,
  });

  bool matches(String lowerContent) {
    for (final kw in keywords) {
      if (lowerContent.contains(kw.toLowerCase())) return true;
    }
    return false;
  }
}

/// 大类定义：包含默认 emoji 与其下所有二级分类。
class EmojiMainCategory {
  final String key;
  final String defaultEmoji;
  final List<EmojiSubCategory> subCategories;

  const EmojiMainCategory({
    required this.key,
    required this.defaultEmoji,
    required this.subCategories,
  });
}

/// Emoji 动态分类器。
///
/// 用法：
/// ```dart
/// final emoji = EmojiClassifier.classify(
///   mainCategoryKey: 'digital',
///   content: '${item.name} ${item.brand} ${item.note}',
/// );
/// ```
class EmojiClassifier {
  EmojiClassifier._();

  /// 大类注册表：key 对齐 [TemplateCard.key]。
  ///
  /// 新增大类的二级分类时，只需在此追加条目；
  /// 未在此注册的大类 key，[classify] 会回退到通用默认 📦。
  static const Map<String, EmojiMainCategory> _registry = {
    // 电子产品 / 数码 —— 需求示例：电脑 → 💻，手机 → 📱
    'digital': EmojiMainCategory(
      key: 'digital',
      defaultEmoji: '📱',
      subCategories: [
        EmojiSubCategory(
          name: '电脑',
          keywords: [
            '电脑',
            '笔记本',
            '笔电',
            'laptop',
            'macbook',
            'thinkpad',
            '拯救者',
            '游戏本',
          ],
          priority: 10,
          emoji: '💻',
        ),
        EmojiSubCategory(
          name: '手机',
          keywords: ['手机', 'phone', 'iphone', '红米', '荣耀手机', '三星手机', '华为手机'],
          priority: 10,
          emoji: '📱',
        ),
        EmojiSubCategory(
          name: '平板',
          keywords: ['平板', 'ipad', 'tablet', '安卓平板'],
          priority: 9,
          emoji: '📲',
        ),
        EmojiSubCategory(
          name: '相机',
          keywords: ['相机', '单反', '微单', 'camera', '佳能', '尼康', '索尼相机', '拍立得'],
          priority: 9,
          emoji: '📷',
        ),
        EmojiSubCategory(
          name: '耳机',
          keywords: ['耳机', 'earphone', 'airpods', '头戴', '蓝牙耳机', '降噪'],
          priority: 8,
          emoji: '🎧',
        ),
        EmojiSubCategory(
          name: '手表',
          keywords: ['手表', 'watch', 'apple watch', '智能手表', '手环'],
          priority: 8,
          emoji: '⌚',
        ),
        EmojiSubCategory(
          name: '键盘',
          keywords: ['键盘', 'keyboard', '机械键盘'],
          priority: 7,
          emoji: '⌨️',
        ),
        EmojiSubCategory(
          name: '鼠标',
          keywords: ['鼠标', 'mouse', '触控板'],
          priority: 7,
          emoji: '🖱️',
        ),
        EmojiSubCategory(
          name: '音箱',
          keywords: ['音箱', 'speaker', '蓝牙音箱', '音响', 'homepod'],
          priority: 7,
          emoji: '🔊',
        ),
        EmojiSubCategory(
          name: '充电设备',
          keywords: ['充电器', 'charger', '充电宝', '移动电源', '数据线'],
          priority: 6,
          emoji: '🔌',
        ),
      ],
    ),

    // 家电
    'appliance': EmojiMainCategory(
      key: 'appliance',
      defaultEmoji: '🔌',
      subCategories: [
        EmojiSubCategory(
          name: '电视',
          keywords: ['电视', 'tv', '电视盒子'],
          priority: 10,
          emoji: '📺',
        ),
        EmojiSubCategory(
          name: '冰箱',
          keywords: ['冰箱', '冷柜', '冰柜'],
          priority: 10,
          emoji: '🧊',
        ),
        EmojiSubCategory(
          name: '洗衣机',
          keywords: ['洗衣机', '烘干机'],
          priority: 10,
          emoji: '🌀',
        ),
        EmojiSubCategory(
          name: '空调',
          keywords: ['空调', '挂机', '柜机'],
          priority: 10,
          emoji: '❄️',
        ),
        EmojiSubCategory(
          name: '微波炉',
          keywords: ['微波炉', '烤箱', '空气炸锅'],
          priority: 9,
          emoji: '🍳',
        ),
        EmojiSubCategory(
          name: '电饭煲',
          keywords: ['电饭煲', '电饭锅', '电压力锅'],
          priority: 9,
          emoji: '🍚',
        ),
        EmojiSubCategory(
          name: '风扇',
          keywords: ['风扇', '电风扇', '循环扇'],
          priority: 8,
          emoji: '💨',
        ),
        EmojiSubCategory(
          name: '吸尘器',
          keywords: ['吸尘器', '扫地机器人', '洗地机', '戴森'],
          priority: 9,
          emoji: '🧹',
        ),
      ],
    ),

    // 护肤
    'skincare': EmojiMainCategory(
      key: 'skincare',
      defaultEmoji: '💄',
      subCategories: [
        EmojiSubCategory(
          name: '口红',
          keywords: ['口红', '唇釉', '唇膏', '唇泥'],
          priority: 10,
          emoji: '💄',
        ),
        EmojiSubCategory(
          name: '面霜',
          keywords: ['面霜', '乳液', '精华', '爽肤水'],
          priority: 9,
          emoji: '🧴',
        ),
        EmojiSubCategory(
          name: '面膜',
          keywords: ['面膜', '贴片膜'],
          priority: 9,
          emoji: '🧖',
        ),
        EmojiSubCategory(
          name: '香水',
          keywords: ['香水', 'perfume', '香氛'],
          priority: 9,
          emoji: '🌸',
        ),
        EmojiSubCategory(
          name: '洗护',
          keywords: ['洗发水', '沐浴露', '护发素', '身体乳'],
          priority: 8,
          emoji: '🧼',
        ),
      ],
    ),

    // 厨房
    'kitchen': EmojiMainCategory(
      key: 'kitchen',
      defaultEmoji: '🍳',
      subCategories: [
        EmojiSubCategory(
          name: '锅具',
          keywords: ['锅', '平底锅', '炒锅', '汤锅', '奶锅', '炖锅'],
          priority: 9,
          emoji: '🍳',
        ),
        EmojiSubCategory(
          name: '刀具',
          keywords: ['刀', '菜刀', '砧板'],
          priority: 8,
          emoji: '🔪',
        ),
        EmojiSubCategory(
          name: '杯具',
          keywords: ['杯子', '水杯', '保温杯', '马克杯', '水壶'],
          priority: 8,
          emoji: '🥤',
        ),
        EmojiSubCategory(
          name: '餐具',
          keywords: ['餐具', '碗', '筷子', '勺子', '盘子'],
          priority: 7,
          emoji: '🍽️',
        ),
      ],
    ),

    // 服饰
    'clothing': EmojiMainCategory(
      key: 'clothing',
      defaultEmoji: '👔',
      subCategories: [
        EmojiSubCategory(
          name: '上衣',
          keywords: ['t恤', '衬衫', '卫衣', '外套', '夹克', '毛衣'],
          priority: 9,
          emoji: '👕',
        ),
        EmojiSubCategory(
          name: '裤子',
          keywords: ['裤子', '牛仔裤', '短裤', '西裤', '运动裤'],
          priority: 9,
          emoji: '👖',
        ),
        EmojiSubCategory(
          name: '鞋',
          keywords: ['鞋', '球鞋', '运动鞋', '皮鞋', '帆布鞋', '靴子'],
          priority: 10,
          emoji: '👟',
        ),
        EmojiSubCategory(
          name: '包',
          keywords: ['包', '双肩包', '手提包', '背包', '钱包', '腰包'],
          priority: 9,
          emoji: '👜',
        ),
        EmojiSubCategory(
          name: '配饰',
          keywords: ['帽子', '围巾', '手套', '领带', '腰带', '眼镜'],
          priority: 7,
          emoji: '🧢',
        ),
      ],
    ),

    // 书籍
    'books': EmojiMainCategory(
      key: 'books',
      defaultEmoji: '📚',
      subCategories: [
        EmojiSubCategory(
          name: '书',
          keywords: [
            '书',
            '书籍',
            '图书',
            '小说',
            '教材',
            '系列',
            '图集',
            '专辑',
            '手册',
            '指南',
            '绘本',
            '百科',
          ],
          priority: 9,
          emoji: '📕',
        ),
        EmojiSubCategory(
          name: '杂志',
          keywords: ['杂志', '期刊', '画册'],
          priority: 8,
          emoji: '📖',
        ),
        EmojiSubCategory(
          name: '漫画',
          keywords: ['漫画', '漫画书', '单行本'],
          priority: 9,
          emoji: '📙',
        ),
      ],
    ),

    // 食品
    'food': EmojiMainCategory(
      key: 'food',
      defaultEmoji: '🍜',
      subCategories: [
        EmojiSubCategory(
          name: '零食',
          keywords: ['零食', '巧克力', '饼干', '坚果', '薯片'],
          priority: 8,
          emoji: '🍫',
        ),
        EmojiSubCategory(
          name: '饮料',
          keywords: ['饮料', '咖啡', '茶', '牛奶', '果汁', '可乐'],
          priority: 9,
          emoji: '🥤',
        ),
        EmojiSubCategory(
          name: '面食',
          keywords: ['面', '方便面', '米粉', '挂面', '意面'],
          priority: 8,
          emoji: '🍜',
        ),
        EmojiSubCategory(
          name: '调味',
          keywords: ['酱油', '醋', '调味', '香料', '盐', '糖'],
          priority: 7,
          emoji: '🧂',
        ),
      ],
    ),

    // 收纳
    'storage': EmojiMainCategory(
      key: 'storage',
      defaultEmoji: '📦',
      subCategories: [
        EmojiSubCategory(
          name: '收纳箱',
          keywords: ['收纳箱', '收纳盒', '收纳筐', '整理箱'],
          priority: 9,
          emoji: '📦',
        ),
        EmojiSubCategory(
          name: '衣架',
          keywords: ['衣架', '挂钩', '晾衣架'],
          priority: 7,
          emoji: '🧷',
        ),
      ],
    ),

    // 医药保健
    'medicine': EmojiMainCategory(
      key: 'medicine',
      defaultEmoji: '💊',
      subCategories: [
        EmojiSubCategory(
          name: '药品',
          keywords: ['药', '胶囊', '片剂', '冲剂', '口服液'],
          priority: 10,
          emoji: '💊',
        ),
        EmojiSubCategory(
          name: '保健品',
          keywords: ['保健品', '维生素', '钙片', '鱼油', '益生菌'],
          priority: 9,
          emoji: '🧪',
        ),
        EmojiSubCategory(
          name: '医疗器械',
          keywords: ['体温计', '血压计', '血糖仪', '雾化器'],
          priority: 9,
          emoji: '🩺',
        ),
      ],
    ),

    // 母婴
    'baby': EmojiMainCategory(
      key: 'baby',
      defaultEmoji: '🍼',
      subCategories: [
        EmojiSubCategory(
          name: '奶瓶',
          keywords: ['奶瓶', '奶嘴', '吸奶器'],
          priority: 10,
          emoji: '🍼',
        ),
        EmojiSubCategory(
          name: '纸尿裤',
          keywords: ['纸尿裤', '尿不湿', '拉拉裤'],
          priority: 10,
          emoji: '🧷',
        ),
        EmojiSubCategory(
          name: '玩具',
          keywords: ['玩具', '布偶', '积木', '早教'],
          priority: 8,
          emoji: '🧸',
        ),
        EmojiSubCategory(
          name: '辅食',
          keywords: ['辅食', '米粉', '果泥', '奶粉'],
          priority: 8,
          emoji: '🥣',
        ),
      ],
    ),

    // 运动户外
    'sports': EmojiMainCategory(
      key: 'sports',
      defaultEmoji: '⚽',
      subCategories: [
        EmojiSubCategory(
          name: '球类',
          keywords: ['球', '足球', '篮球', '羽毛球', '网球', '乒乓球'],
          priority: 9,
          emoji: '⚽',
        ),
        EmojiSubCategory(
          name: '健身',
          keywords: ['哑铃', '跑步机', '瑜伽', '健身', '拉力器'],
          priority: 8,
          emoji: '🏋️',
        ),
        EmojiSubCategory(
          name: '露营',
          keywords: ['帐篷', '露营', '睡袋', '登山杖'],
          priority: 9,
          emoji: '⛺',
        ),
        EmojiSubCategory(
          name: '骑行',
          keywords: ['自行车', '骑行', '单车', '头盔'],
          priority: 9,
          emoji: '🚲',
        ),
      ],
    ),

    // 文具
    'stationery': EmojiMainCategory(
      key: 'stationery',
      defaultEmoji: '✏️',
      subCategories: [
        EmojiSubCategory(
          name: '笔',
          keywords: ['笔', '钢笔', '中性笔', '圆珠笔', '马克笔'],
          priority: 9,
          emoji: '✏️',
        ),
        EmojiSubCategory(
          name: '本子',
          keywords: ['本', '笔记本', '手账', '便签'],
          priority: 8,
          emoji: '📓',
        ),
        EmojiSubCategory(
          name: '文具收纳',
          keywords: ['笔筒', '笔袋', '文件袋', '文件夹'],
          priority: 7,
          emoji: '🗂️',
        ),
      ],
    ),

    // 工具
    'tools': EmojiMainCategory(
      key: 'tools',
      defaultEmoji: '🔧',
      subCategories: [
        EmojiSubCategory(
          name: '螺丝刀',
          keywords: ['螺丝刀', '螺丝批', '批头'],
          priority: 9,
          emoji: '🔧',
        ),
        EmojiSubCategory(
          name: '锤子',
          keywords: ['锤子', '锤', '橡胶锤'],
          priority: 8,
          emoji: '🔨',
        ),
        EmojiSubCategory(
          name: '钳子',
          keywords: ['钳子', '老虎钳', '尖嘴钳', '斜口钳'],
          priority: 8,
          emoji: '🛠️',
        ),
        EmojiSubCategory(
          name: '电动工具',
          keywords: ['电钻', '角磨机', '电扳手', '电动工具'],
          priority: 9,
          emoji: '⚡',
        ),
      ],
    ),

    // 宠物用品
    'pet': EmojiMainCategory(
      key: 'pet',
      defaultEmoji: '🐾',
      subCategories: [
        EmojiSubCategory(
          name: '猫用品',
          keywords: ['猫', '猫粮', '猫砂', '猫爬架', '逗猫'],
          priority: 10,
          emoji: '🐱',
        ),
        EmojiSubCategory(
          name: '狗用品',
          keywords: ['狗', '狗粮', '狗绳', '狗窝', '狗狗'],
          priority: 10,
          emoji: '🐶',
        ),
        EmojiSubCategory(
          name: '水族',
          keywords: ['鱼缸', '鱼食', '过滤器', '水族'],
          priority: 9,
          emoji: '🐟',
        ),
      ],
    ),

    // 会员订阅
    'membership': EmojiMainCategory(
      key: 'membership',
      defaultEmoji: '💳',
      subCategories: [
        EmojiSubCategory(
          name: '视频会员',
          keywords: [
            '视频',
            '爱奇艺',
            '腾讯视频',
            '优酷',
            'netflix',
            'youtube',
            'b站',
            '哔哩',
          ],
          priority: 9,
          emoji: '🎬',
        ),
        EmojiSubCategory(
          name: '音乐会员',
          keywords: ['音乐', '网易云', 'qq音乐', 'spotify', '酷狗', '酷我'],
          priority: 9,
          emoji: '🎵',
        ),
        EmojiSubCategory(
          name: '云存储',
          keywords: ['云盘', 'icloud', '百度网盘', 'onedrive', 'google one', '云空间'],
          priority: 9,
          emoji: '☁️',
        ),
        EmojiSubCategory(
          name: '购物会员',
          keywords: ['京东plus', '淘宝88vip', '会员', 'prime'],
          priority: 8,
          emoji: '🛍️',
        ),
      ],
    ),

    // 网卡流量
    'sim_card': EmojiMainCategory(
      key: 'sim_card',
      defaultEmoji: '📶',
      subCategories: [
        EmojiSubCategory(
          name: '流量卡',
          keywords: ['流量卡', '流量', '物联卡'],
          priority: 9,
          emoji: '📶',
        ),
        EmojiSubCategory(
          name: '电话卡',
          keywords: ['电话卡', '手机卡', 'sim卡', '副卡'],
          priority: 9,
          emoji: '📲',
        ),
      ],
    ),

    // 数字许可证
    'license': EmojiMainCategory(
      key: 'license',
      defaultEmoji: '🔐',
      subCategories: [
        EmojiSubCategory(
          name: '办公软件',
          keywords: ['office', 'wps', 'excel', 'word', 'ppt'],
          priority: 9,
          emoji: '📊',
        ),
        EmojiSubCategory(
          name: '设计软件',
          keywords: [
            'photoshop',
            'adobe',
            'illustrator',
            'figma',
            'sketch',
            '剪映',
          ],
          priority: 9,
          emoji: '🎨',
        ),
        EmojiSubCategory(
          name: '操作系统',
          keywords: ['windows', 'macos', '系统', '激活码'],
          priority: 8,
          emoji: '💻',
        ),
        EmojiSubCategory(
          name: '开发工具',
          keywords: ['jetbrains', 'ide', '编辑器', 'intellij'],
          priority: 8,
          emoji: '⌨️',
        ),
      ],
    ),

    // 礼品卡
    'gift_card': EmojiMainCategory(
      key: 'gift_card',
      defaultEmoji: '🎁',
      subCategories: [
        EmojiSubCategory(
          name: '电商卡',
          keywords: ['京东', '天猫', 'e卡', '购物卡'],
          priority: 9,
          emoji: '🛍️',
        ),
        EmojiSubCategory(
          name: '充值卡',
          keywords: ['充值卡', '话费', '游戏点卡', '点券'],
          priority: 9,
          emoji: '💳',
        ),
        EmojiSubCategory(
          name: '礼品卡',
          keywords: ['礼品卡', 'gift card', '星礼卡', '星巴克'],
          priority: 9,
          emoji: '🎁',
        ),
      ],
    ),
  };

  /// 大类默认 emoji 兜底值（未注册的大类 key / 通用模板使用）。
  static const String _fallbackEmoji = '📦';

  /// 获取大类默认 emoji。
  static String defaultEmojiOf(String mainCategoryKey) {
    return _registry[mainCategoryKey]?.defaultEmoji ?? _fallbackEmoji;
  }

  /// 查询某大类下所有二级分类（用于展示/校验）。
  static List<EmojiSubCategory> subCategoriesOf(String mainCategoryKey) {
    return _registry[mainCategoryKey]?.subCategories ?? const [];
  }

  /// 动态分类核心：根据大类 key 与文本内容返回最佳 emoji。
  ///
  /// 匹配规则：
  /// 1. 大类未注册 → 返回 [_fallbackEmoji]；
  /// 2. 内容为空 → 返回大类默认 emoji；
  /// 3. 遍历该大类下所有二级分类，收集所有命中项；
  /// 4. 命中多个时取 [EmojiSubCategory.priority] 最大者；
  ///    优先级相同则取列表中靠前的（更具体的分类应声明在前）；
  /// 5. 无命中 → 返回大类默认 emoji。
  ///
  /// 内容建议拼接物品名称、品牌、备注等可读文本，以提升命中率。
  static String classify({
    required String mainCategoryKey,
    required String content,
  }) {
    final main = _registry[mainCategoryKey];
    if (main == null) return _fallbackEmoji;

    final lower = content.toLowerCase();
    if (lower.trim().isEmpty) return main.defaultEmoji;

    EmojiSubCategory? best;
    for (final sub in main.subCategories) {
      if (!sub.matches(lower)) continue;
      if (best == null || sub.priority > best.priority) {
        best = sub;
      }
    }
    final raw = best?.emoji ?? main.defaultEmoji;
    return raw;
  }

  /// 返回命中的二级分类信息（用于调试/预览展示）。
  /// 未命中时返回 null。
  static EmojiSubCategory? matchDetail({
    required String mainCategoryKey,
    required String content,
  }) {
    final main = _registry[mainCategoryKey];
    if (main == null) return null;

    final lower = content.toLowerCase();
    if (lower.trim().isEmpty) return null;

    EmojiSubCategory? best;
    for (final sub in main.subCategories) {
      if (!sub.matches(lower)) continue;
      if (best == null || sub.priority > best.priority) {
        best = sub;
      }
    }
    return best;
  }
}
