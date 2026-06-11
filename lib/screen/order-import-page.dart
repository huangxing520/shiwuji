import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shi_wu_ji/constants/app_colors.dart';
import 'package:shi_wu_ji/widgets/toast_utils.dart';

// ==================== 本地颜色常量 ====================
class _Colors {
  static const Color bg = Color(0xFFFFF8E7);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color fg = Color(0xFF3D2B1F);
  static const Color fgSecondary = Color(0xFF7A6555);
  static const Color muted = Color(0xFFB8A48E);
  static const Color border = Color(0xFFF0E4D0);
  static const Color accent = Color(0xFFFFB800);
  static const Color accentLight = Color(0xFFFFE066);
  static const Color accentDark = Color(0xFFE5A500);
  static const Color orange = Color(0xFFFF8C42);
  static const Color orangeLight = Color(0xFFFFD4B8);
  static const Color green = Color(0xFF6BCB77);
  static const Color greenLight = Color(0xFFD4F5D9);
  static const Color red = Color(0xFFFF6B6B);
  static const Color redLight = Color(0xFFFFD4D4);
  static const Color blue = Color(0xFF5B9BFF);
  static const Color blueLight = Color(0xFFD4E8FF);
  static const Color purple = Color(0xFF9B7BFF);
  static const Color purpleLight = Color(0xFFE4DAFF);
}

// ==================== 数据模型 ====================
class _PlatformData {
  final String key;
  final String name;
  final String emoji;
  final String iconText;
  final bool connected;
  final int orderEstimate;
  final List<Color> gradientColors;
  final List<_TutorialStep> steps;

  const _PlatformData({
    required this.key,
    required this.name,
    required this.emoji,
    required this.iconText,
    required this.connected,
    required this.orderEstimate,
    required this.gradientColors,
    required this.steps,
  });
}

class _TutorialStep {
  final String title;
  final String desc;
  const _TutorialStep({required this.title, required this.desc});
}

class _HistoryRecord {
  final String emoji;
  final String title;
  final String meta;
  final int count;
  final Color iconBg;

  const _HistoryRecord({
    required this.emoji,
    required this.title,
    required this.meta,
    required this.count,
    required this.iconBg,
  });
}

class _MockOrder {
  final String emoji;
  final String name;
  final String price;
  String status; // success / fail / pending

  _MockOrder({
    required this.emoji,
    required this.name,
    required this.price,
    this.status = 'pending',
  });
}

// ==================== 平台数据 ====================
const List<_PlatformData> _platforms = [
  _PlatformData(
    key: 'taobao',
    name: '淘宝',
    emoji: '🟠',
    iconText: '𝐓',
    connected: true,
    orderEstimate: 186,
    gradientColors: [Color(0xFFFF4D00), Color(0xFFFF8A00)],
    steps: [
      _TutorialStep(title: '打开淘宝APP', desc: '确保已安装淘宝APP并登录你的账号'),
      _TutorialStep(title: '进入订单页面', desc: '点击「我的淘宝」→「我的订单」→「全部订单」'),
      _TutorialStep(title: '分享订单数据', desc: '点击页面右上角「…」→「分享」→ 选择「复制链接」，将链接粘贴到下方输入框'),
      _TutorialStep(title: '授权导入', desc: '点击下方按钮，系统将自动解析订单信息并导入到你的物品库'),
    ],
  ),
  _PlatformData(
    key: 'jd',
    name: '京东',
    emoji: '🔴',
    iconText: 'JD',
    connected: true,
    orderEstimate: 94,
    gradientColors: [Color(0xFFE4393C), Color(0xFFFF6B6B)],
    steps: [
      _TutorialStep(title: '打开京东APP', desc: '确保已安装京东APP并登录账号'),
      _TutorialStep(title: '进入订单列表', desc: '点击「我的」→「我的订单」'),
      _TutorialStep(title: '导出订单数据', desc: '点击右上角「…」→「导出订单」→ 选择日期范围 → 复制导出链接'),
      _TutorialStep(title: '授权导入', desc: '点击下方按钮，京东订单将自动同步到物品库'),
    ],
  ),
  _PlatformData(
    key: 'pdd',
    name: '拼多多',
    emoji: '🛒',
    iconText: '拼',
    connected: false,
    orderEstimate: 67,
    gradientColors: [Color(0xFFE02E24), Color(0xFFF44336)],
    steps: [
      _TutorialStep(title: '打开拼多多APP', desc: '确保已安装拼多多APP并登录账号'),
      _TutorialStep(title: '进入个人中心', desc: '点击「个人中心」→「全部订单」'),
      _TutorialStep(title: '截图订单页面', desc: '截图包含商品名称、价格、日期等关键信息的订单页面'),
      _TutorialStep(title: '上传截图识别', desc: '点击下方按钮，上传截图，系统将AI识别订单内容'),
    ],
  ),
  _PlatformData(
    key: 'douyin',
    name: '抖音商城',
    emoji: '🎵',
    iconText: '♪',
    connected: false,
    orderEstimate: 43,
    gradientColors: [Color(0xFF1A1A1A), Color(0xFF333333)],
    steps: [
      _TutorialStep(title: '打开抖音APP', desc: '确保已安装抖音APP并登录账号'),
      _TutorialStep(title: '进入商城订单', desc: '点击「我」→「商城」→「我的订单」'),
      _TutorialStep(title: '分享订单链接', desc: '长按订单条目 →「复制链接」，将链接粘贴到输入框'),
      _TutorialStep(title: '授权导入', desc: '点击下方按钮开始导入抖音商城订单'),
    ],
  ),
  _PlatformData(
    key: 'suning',
    name: '苏宁',
    emoji: '🟡',
    iconText: '苏',
    connected: false,
    orderEstimate: 28,
    gradientColors: [Color(0xFFFFA200), Color(0xFFFFD000)],
    steps: [
      _TutorialStep(title: '打开苏宁APP', desc: '确保已安装苏宁易购APP并登录账号'),
      _TutorialStep(title: '进入我的订单', desc: '点击「我的」→「全部订单」'),
      _TutorialStep(title: '复制订单数据', desc: '通过网页版苏宁导出订单CSV文件'),
      _TutorialStep(title: '上传文件导入', desc: '点击下方按钮上传CSV文件，自动解析导入'),
    ],
  ),
  _PlatformData(
    key: 'vipshop',
    name: '唯品会',
    emoji: '💜',
    iconText: 'V',
    connected: false,
    orderEstimate: 19,
    gradientColors: [Color(0xFFFF007F), Color(0xFFFF6BA8)],
    steps: [
      _TutorialStep(title: '打开唯品会APP', desc: '确保已安装唯品会APP并登录账号'),
      _TutorialStep(title: '查看订单记录', desc: '进入「个人」→「全部订单」'),
      _TutorialStep(title: '截图或复制链接', desc: '截图订单页面或复制订单详情链接'),
      _TutorialStep(title: '开始导入', desc: '点击下方按钮，上传截图或粘贴链接完成导入'),
    ],
  ),
  _PlatformData(
    key: 'kaola',
    name: '考拉',
    emoji: '🐨',
    iconText: '考',
    connected: false,
    orderEstimate: 15,
    gradientColors: [Color(0xFF0066FF), Color(0xFF4D94FF)],
    steps: [
      _TutorialStep(title: '打开考拉APP', desc: '确保已安装考拉海购APP并登录账号'),
      _TutorialStep(title: '浏览历史订单', desc: '进入「我的」→「全部订单」'),
      _TutorialStep(title: '导出订单信息', desc: '通过考拉网页版导出订单数据文件'),
      _TutorialStep(title: '上传导入', desc: '点击下方按钮上传数据文件完成导入'),
    ],
  ),
];

const List<_HistoryRecord> _historyRecords = [
  _HistoryRecord(
    emoji: '🟠',
    title: '淘宝订单导入',
    meta: '2025-05-28 14:32 · 全部历史订单',
    count: 186,
    iconBg: Color(0xFFFFF0E5),
  ),
  _HistoryRecord(
    emoji: '🔴',
    title: '京东订单导入',
    meta: '2025-05-20 09:15 · 近6个月',
    count: 94,
    iconBg: Color(0xFFFFE8E8),
  ),
  _HistoryRecord(
    emoji: '🟠',
    title: '淘宝订单导入',
    meta: '2025-04-12 20:48 · 近1年',
    count: 52,
    iconBg: Color(0xFFFFF0E5),
  ),
];

final List<_MockOrder> _mockOrders = [
  _MockOrder(emoji: '🧹', name: '戴森V12吸尘器', price: '¥3,990'),
  _MockOrder(emoji: '🎧', name: 'AirPods Pro 2', price: '¥1,899'),
  _MockOrder(emoji: '💊', name: '兰蔻小黑瓶精华', price: '¥1,080'),
  _MockOrder(emoji: '📦', name: '宜家思库布收纳箱', price: '¥149'),
  _MockOrder(emoji: '🎵', name: '索尼WH-1000XM5', price: '¥2,499'),
  _MockOrder(emoji: '🍚', name: '美的电饭煲', price: '¥399'),
  _MockOrder(emoji: '✨', name: 'SK-II神仙水230ml', price: '¥1,590'),
  _MockOrder(emoji: '👔', name: '优衣库轻薄羽绒服', price: '¥499'),
  _MockOrder(emoji: '📱', name: 'iPhone 15手机壳', price: '¥89'),
  _MockOrder(emoji: '🍳', name: '不粘煎锅26cm', price: '¥159'),
  _MockOrder(emoji: '📖', name: '设计中的设计·原研哉', price: '¥48'),
  _MockOrder(emoji: '🧱', name: '乐高建筑系列', price: '¥599'),
  _MockOrder(emoji: '🖥️', name: '戴尔U2723QE显示器', price: '¥3,599'),
  _MockOrder(emoji: '⌨️', name: 'HHKB Professional', price: '¥2,150'),
  _MockOrder(emoji: '🪑', name: '西昊M57人体工学椅', price: '¥1,099'),
  _MockOrder(emoji: '🧴', name: '雅诗兰黛小棕瓶', price: '¥780'),
  _MockOrder(emoji: '👟', name: 'New Balance 990v5', price: '¥1,269'),
  _MockOrder(emoji: '🎒', name: 'Anker通勤背包', price: '¥359'),
];

// ==================== 时间范围选项 ====================
const List<Map<String, String>> _timeRanges = [
  {'key': 'all', 'label': '全部历史订单'},
  {'key': '1m', 'label': '近1个月'},
  {'key': '3m', 'label': '近3个月'},
  {'key': '6m', 'label': '近6个月'},
  {'key': '1y', 'label': '近1年'},
  {'key': 'custom', 'label': '自定义时间'},
];

// ==================== 主页面 ====================
class OrderImportPage extends StatefulWidget {
  const OrderImportPage({super.key});

  @override
  State<OrderImportPage> createState() => _OrderImportPageState();
}

class _OrderImportPageState extends State<OrderImportPage>
    with TickerProviderStateMixin {
  // 当前选中的平台
  _PlatformData? _selectedPlatform;

  // 时间范围
  String _selectedTimeRange = 'all';

  // 导入选项
  bool _onlyPhysical = true;
  bool _autoMatch = true;

  // 进度相关
  bool _isImporting = false;
  bool _importDone = false;
  double _progressValue = 0;
  int _totalCount = 0;
  int _successCount = 0;
  int _failCount = 0;
  int _pendingCount = 0;
  List<_MockOrder> _importedItems = [];
  Timer? _importTimer;

  // Hero 数字动画
  late AnimationController _heroAnimController;
  late Animation<int> _platformCountAnim;
  late Animation<int> _importedCountAnim;

  // 配置面板动画
  late AnimationController _configAnimController;
  late Animation<double> _configFadeAnim;
  late Animation<Offset> _configSlideAnim;

  // 进度区域动画
  late AnimationController _progressAnimController;
  late Animation<double> _progressFadeAnim;

  // 进度条闪光动画
  late AnimationController _shimmerController;

  // 按钮闪光动画
  late AnimationController _btnShineController;

  @override
  void initState() {
    super.initState();

    // Hero 数字动画
    _heroAnimController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _platformCountAnim = IntTween(begin: 0, end: 8).animate(
      CurvedAnimation(parent: _heroAnimController, curve: Curves.easeOutCubic),
    );
    _importedCountAnim = IntTween(begin: 0, end: 1286).animate(
      CurvedAnimation(parent: _heroAnimController, curve: Curves.easeOutCubic),
    );
    _heroAnimController.forward();

    // 配置面板动画
    _configAnimController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _configFadeAnim = CurvedAnimation(
      parent: _configAnimController,
      curve: const Interval(0.0, 1.0, curve: Curves.easeOut),
    );
    _configSlideAnim = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _configAnimController,
      curve: Curves.easeOutBack,
    ));

    // 进度区域动画
    _progressAnimController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _progressFadeAnim = CurvedAnimation(
      parent: _progressAnimController,
      curve: Curves.easeOut,
    );

    // 进度条闪光
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    // 按钮闪光
    _btnShineController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _importTimer?.cancel();
    _heroAnimController.dispose();
    _configAnimController.dispose();
    _progressAnimController.dispose();
    _shimmerController.dispose();
    _btnShineController.dispose();
    super.dispose();
  }

  // ==================== 平台选择 & 教程弹窗 ====================
  void _openPlatform(_PlatformData platform) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _TutorialSheet(
        platform: platform,
        onConfirm: () {
          Navigator.pop(ctx);
          _confirmPlatform(platform);
        },
      ),
    );
  }

  void _confirmPlatform(_PlatformData platform) {
    setState(() {
      _selectedPlatform = platform;
      _isImporting = false;
      _importDone = false;
      _progressValue = 0;
      _totalCount = 0;
      _successCount = 0;
      _failCount = 0;
      _pendingCount = 0;
      _importedItems = [];
    });
    _configAnimController.forward(from: 0);
    _progressAnimController.reverse();
    ToastUtils.show(
      context,
      '已选择「${platform.name}」，约${platform.orderEstimate}笔订单待导入',
    );
  }

  // ==================== 开始导入 ====================
  void _startImport() {
    if (_selectedPlatform == null) {
      ToastUtils.show(context, '请先选择购物平台');
      return;
    }

    final total = _selectedPlatform!.orderEstimate;

    setState(() {
      _isImporting = true;
      _importDone = false;
      _progressValue = 0;
      _totalCount = 0;
      _successCount = 0;
      _failCount = 0;
      _pendingCount = total;
      _importedItems = [];
    });
    _progressAnimController.forward(from: 0);

    final rng = Random();
    int imported = 0;

    _importTimer?.cancel();
    _importTimer = Timer.periodic(const Duration(milliseconds: 350), (timer) {
      imported++;

      final orderIdx = (imported - 1) % _mockOrders.length;
      final order = _MockOrder(
        emoji: _mockOrders[orderIdx].emoji,
        name: _mockOrders[orderIdx].name,
        price: _mockOrders[orderIdx].price,
      );

      final isSuccess = rng.nextDouble() < 0.9;
      order.status = isSuccess ? 'success' : 'fail';

      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _totalCount = imported;
        if (isSuccess) {
          _successCount++;
        } else {
          _failCount++;
        }
        _pendingCount = max(0, total - imported);
        _progressValue = min(imported / total, 1.0);
        _importedItems.insert(0, order);
      });

      if (imported >= total) {
        timer.cancel();
        _importTimer = null;
        setState(() {
          _isImporting = false;
          _importDone = true;
          _pendingCount = 0;
          _progressValue = 1.0;
        });
        ToastUtils.show(
          context,
          '${_selectedPlatform!.emoji} ${_selectedPlatform!.name}导入完成！成功$_successCount件，失败$_failCount件',
        );
      }
    });
  }

  // ==================== Build ====================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _Colors.bg,
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(height: MediaQuery.of(context).padding.top),
              _buildTopBar(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      _buildHeroBanner(),
                      const SizedBox(height: 20),
                      _buildSectionTitle(
                        iconBg: const Color(0xFFFFF3CC),
                        iconColor: _Colors.accentDark,
                        icon: Icons.grid_view,
                        title: '选择购物平台',
                      ),
                      const SizedBox(height: 12),
                      _buildPlatformGrid(),
                      const SizedBox(height: 20),
                      if (_selectedPlatform != null)
                        _buildConfigPanel(),
                      if (_isImporting || _importDone)
                        _buildProgressSection(),
                      const SizedBox(height: 4),
                      _buildSectionTitle(
                        iconBg: _Colors.greenLight,
                        iconColor: const Color(0xFF3A9E4A),
                        icon: Icons.check_circle,
                        title: '导入记录',
                      ),
                      const SizedBox(height: 12),
                      _buildHistoryList(),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== 顶部导航栏 ====================
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Row(
        children: [
          // 返回按钮
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: _Colors.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: _Colors.fg.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.chevron_left,
                size: 20,
                color: _Colors.fgSecondary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            '订单导入',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: _Colors.fg,
            ),
          ),
          const Spacer(),
          // 帮助按钮
          GestureDetector(
            onTap: () => ToastUtils.show(context, '导入常见问题解答'),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: _Colors.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: _Colors.fg.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.help_outline,
                size: 18,
                color: _Colors.fgSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== Hero Banner ====================
  Widget _buildHeroBanner() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFD460), Color(0xFFFFB800), Color(0xFFFF9E40)],
          stops: [0.0, 0.4, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: _Colors.accent.withOpacity(0.25),
            blurRadius: 24,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // 装饰圆
            Positioned(
              top: -30,
              right: -20,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: -20,
              left: 40,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // 内容
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🛒 一键导入购物订单',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '支持全主流购物平台，自动解析订单信息',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.85),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _buildHeroStat(
                        value: '${_platformCountAnim.value}',
                        label: '支持平台',
                      ),
                      const SizedBox(width: 20),
                      _buildHeroStat(
                        value: _formatNumber(_importedCountAnim.value),
                        label: '累计导入',
                      ),
                      const SizedBox(width: 20),
                      const _HeroStatStatic(
                        value: '¥52.4w',
                        label: '已管理资产',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroStat({required String value, required String label}) {
    return AnimatedBuilder(
      animation: _heroAnimController,
      builder: (context, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Colors.white.withOpacity(0.75),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatNumber(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  // ==================== 区块标题 ====================
  Widget _buildSectionTitle({
    required Color iconBg,
    required Color iconColor,
    required IconData icon,
    required String title,
  }) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 14, color: iconColor),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: _Colors.fg,
          ),
        ),
      ],
    );
  }

  // ==================== 平台网格 ====================
  Widget _buildPlatformGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: _platforms.length + 1, // +1 for "more"
      itemBuilder: (context, index) {
        if (index == _platforms.length) {
          return _buildMoreButton();
        }
        return _buildPlatformItem(_platforms[index], index);
      },
    );
  }

  Widget _buildPlatformItem(_PlatformData platform, int index) {
    return GestureDetector(
      onTap: () => _openPlatform(platform),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: platform.gradientColors,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadowCard,
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    platform.iconText,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              // 连接状态圆点
              Positioned(
                top: -1,
                right: -1,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: platform.connected ? _Colors.green : _Colors.muted,
                    shape: BoxShape.circle,
                    border: Border.all(color: _Colors.surface, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            platform.name,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _Colors.fgSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoreButton() {
    return GestureDetector(
      onTap: () => ToastUtils.show(context, '更多平台开发中…'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: _Colors.surface,
              border: Border.all(color: _Colors.border, width: 2, strokeAlign: BorderSide.strokeAlignInside),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowCard,
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.add, size: 24, color: _Colors.muted),
          ),
          const SizedBox(height: 8),
          const Text(
            '更多',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _Colors.fgSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== 配置面板 ====================
  Widget _buildConfigPanel() {
    return FadeTransition(
      opacity: _configFadeAnim,
      child: SlideTransition(
        position: _configSlideAnim,
        child: Container(
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _Colors.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowCard,
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 选择导入范围
              _buildConfigLabel('选择导入范围', _Colors.accent),
              const SizedBox(height: 10),
              _buildTimeChips(),
              // 自定义日期
              if (_selectedTimeRange == 'custom') ...[
                const SizedBox(height: 10),
                _buildCustomDateRow(),
              ],
              const SizedBox(height: 18),
              // 导入选项
              _buildConfigLabel('导入选项', _Colors.orange),
              const SizedBox(height: 10),
              _buildCheckboxRow(
                label: '仅导入实物商品订单',
                value: _onlyPhysical,
                onChanged: (v) => setState(() => _onlyPhysical = v),
              ),
              const SizedBox(height: 8),
              _buildCheckboxRow(
                label: '自动匹配已有物品',
                value: _autoMatch,
                onChanged: (v) => setState(() => _autoMatch = v),
              ),
              const SizedBox(height: 18),
              // 开始导入按钮
              _buildImportButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConfigLabel(String text, Color dotColor) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: dotColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: _Colors.fg,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _timeRanges.map((range) {
        final isSelected = _selectedTimeRange == range['key'];
        return GestureDetector(
          onTap: () => setState(() => _selectedTimeRange = range['key']!),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFFFF3CC) : _Colors.bg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? _Colors.accent : _Colors.border,
                width: 1.5,
              ),
            ),
            child: Text(
              range['label']!,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? _Colors.accentDark : _Colors.fgSecondary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCustomDateRow() {
    return Row(
      children: [
        Expanded(child: _buildDateInput('2024-01-01')),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            '至',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: _Colors.muted,
            ),
          ),
        ),
        Expanded(child: _buildDateInput('2025-06-01')),
      ],
    );
  }

  Widget _buildDateInput(String defaultDate) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _Colors.bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _Colors.border, width: 1.5),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today, size: 14, color: _Colors.muted),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              defaultDate,
              style: const TextStyle(
                fontSize: 12,
                color: _Colors.fg,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxRow({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Row(
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: Checkbox(
              value: value,
              onChanged: (v) => onChanged(v ?? false),
              activeColor: _Colors.accent,
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: _Colors.fgSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImportButton() {
    return GestureDetector(
      onTap: _isImporting ? null : _startImport,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: _isImporting ? 0.5 : 1.0,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              colors: [_Colors.accent, _Colors.orange],
            ),
            boxShadow: [
              BoxShadow(
                color: _Colors.accent.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // 按钮闪光
              AnimatedBuilder(
                animation: _btnShineController,
                builder: (context, _) {
                  final pos = _btnShineController.value;
                  if (pos < 0.4) {
                    return Positioned(
                      left: -100 + pos * 600,
                      top: 0,
                      bottom: 0,
                      child: Container(
                        width: 80,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0),
                              Colors.white.withOpacity(0.25),
                              Colors.white.withOpacity(0),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              Center(
                child: Text(
                  _isImporting
                      ? '导入中…'
                      : _importDone
                          ? '再次导入'
                          : '开始导入',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== 进度区域 ====================
  Widget _buildProgressSection() {
    return FadeTransition(
      opacity: _progressFadeAnim,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _Colors.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowCard,
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 头部
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _importDone ? '导入完成！' : '正在导入${_selectedPlatform?.name ?? ''}订单…',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _Colors.fg,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: _importDone
                        ? _Colors.greenLight
                        : _isImporting
                            ? _Colors.accentLight
                            : _Colors.redLight,
                  ),
                  child: Text(
                    _importDone ? '已完成' : _isImporting ? '导入中' : '出错',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _importDone
                          ? const Color(0xFF3A9E4A)
                          : _isImporting
                              ? _Colors.accentDark
                              : _Colors.red,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // 进度条
            _buildProgressBar(),
            const SizedBox(height: 10),
            // 统计数据
            _buildProgressStats(),
            const SizedBox(height: 14),
            // 导入项目列表
            _buildProgressItems(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        height: 10,
        child: Stack(
          children: [
            // 背景
            Container(color: _Colors.bg),
            // 填充
            AnimatedBuilder(
              animation: _shimmerController,
              builder: (context, _) {
                return FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: _progressValue,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [_Colors.accent, _Colors.orange],
                          ),
                        ),
                      ),
                      // 闪光效果
                      Positioned.fill(
                        child: ShaderMask(
                          shaderCallback: (rect) {
                            final shimmerX =
                                (_shimmerController.value * 2 - 1) * rect.width;
                            return LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Colors.transparent,
                                Colors.white.withOpacity(0.3),
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.5, 1.0],
                              transform: _SlidingGradientTransform(shimmerX / rect.width),
                            ).createShader(rect);
                          },
                          blendMode: BlendMode.srcATop,
                          child: Container(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStatItem(value: '$_totalCount', label: '总订单', color: _Colors.fg),
        _buildStatItem(value: '$_successCount', label: '成功', color: _Colors.green),
        _buildStatItem(value: '$_failCount', label: '失败', color: _Colors.red),
        _buildStatItem(value: '$_pendingCount', label: '等待中', color: _Colors.orange),
      ],
    );
  }

  Widget _buildStatItem({
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: _Colors.muted,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressItems() {
    if (_importedItems.isEmpty) return const SizedBox.shrink();
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 160),
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: _importedItems.length,
        separatorBuilder: (_, __) => const Divider(
          color: _Colors.border,
          height: 1,
          thickness: 1,
        ),
        itemBuilder: (context, index) {
          final item = _importedItems[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Text(item.emoji, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _Colors.fg,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  item.price,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _Colors.accentDark,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: item.status == 'success'
                        ? _Colors.greenLight
                        : _Colors.redLight,
                  ),
                  child: Text(
                    item.status == 'success' ? '成功' : '失败',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: item.status == 'success'
                          ? const Color(0xFF3A9E4A)
                          : _Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ==================== 导入记录 ====================
  Widget _buildHistoryList() {
    return Column(
      children: _historyRecords.map((record) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: GestureDetector(
            onTap: () => ToastUtils.show(context, '查看${record.title.replaceAll('订单导入', '')}导入详情'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: _Colors.surface,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: _Colors.fg.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // 图标
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: record.iconBg,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        record.emoji,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // 信息
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          record.title,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _Colors.fg,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          record.meta,
                          style: const TextStyle(
                            fontSize: 11,
                            color: _Colors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 数量
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '${record.count}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: _Colors.accentDark,
                          ),
                        ),
                        const TextSpan(
                          text: ' 件',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: _Colors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ==================== Hero 静态统计（资产值不动画） ====================
class _HeroStatStatic extends StatelessWidget {
  final String value;
  final String label;

  const _HeroStatStatic({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.white.withOpacity(0.75),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ==================== 教程弹窗 (Bottom Sheet) ====================
class _TutorialSheet extends StatelessWidget {
  final _PlatformData platform;
  final VoidCallback onConfirm;

  const _TutorialSheet({
    required this.platform,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      decoration: const BoxDecoration(
        color: _Colors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 30),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 头部
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      platform.emoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${platform.name}授权导入',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: _Colors.fg,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: _Colors.bg,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, size: 16, color: _Colors.muted),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // 步骤列表
            ...List.generate(platform.steps.length, (i) {
              final step = platform.steps[i];
              final isLast = i == platform.steps.length - 1;
              return _TutorialStepWidget(
                index: i + 1,
                step: step,
                isLast: isLast,
              );
            }),
            const SizedBox(height: 6),
            // 授权按钮
            GestureDetector(
              onTap: onConfirm,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: const LinearGradient(
                    colors: [_Colors.accent, _Colors.orange],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _Colors.accent.withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    platform.connected ? '📱 重新授权并导入' : '🔑 授权并开始导入',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            // 暂不导入
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: _Colors.bg,
                ),
                child: const Center(
                  child: Text(
                    '暂不导入',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _Colors.fgSecondary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== 教程步骤组件 ====================
class _TutorialStepWidget extends StatelessWidget {
  final int index;
  final _TutorialStep step;
  final bool isLast;

  const _TutorialStepWidget({
    required this.index,
    required this.step,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 序号 + 连线
          SizedBox(
            width: 36,
            child: Column(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [_Colors.accent, _Colors.orange],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '$index',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: _Colors.border,
                    ),
                  ),
              ],
            ),
          ),
          // 内容
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _Colors.fg,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    step.desc,
                    style: const TextStyle(
                      fontSize: 12,
                      color: _Colors.fgSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== 渐变动画辅助 ====================
class _SlidingGradientTransform extends GradientTransform {
  final double slidePercent;

  const _SlidingGradientTransform(this.slidePercent);

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent, 0, 0);
  }
}
