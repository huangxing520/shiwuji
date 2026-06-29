import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../add_item_page.dart';
import '../order-import-page.dart';
import 'package:shi_wu_ji/constants/app_colors.dart';
import 'package:shi_wu_ji/widgets/toast_utils.dart';
import 'package:shi_wu_ji/widgets/gradient_background.dart';
import 'package:shi_wu_ji/widgets/quick_action_card.dart';
import 'package:shi_wu_ji/widgets/list_item_card.dart';
import 'package:shi_wu_ji/models/enums/pending_card_type.dart';
import 'package:shi_wu_ji/widgets/section_title.dart';
import 'package:shi_wu_ji/providers/item_providers.dart';
import 'package:shi_wu_ji/providers/profile_provider.dart';
import 'data_cards_section.dart';
import 'recent_section.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  bool _isRefreshing = false;
  static const _bgAsset = 'assets/icon/background1.jpg';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 预加载背景图，避免页面渲染后再解码导致的闪烁
    // 必须在 didChangeDependencies 中调用，因为 precacheImage 依赖 MediaQuery
    precacheImage(AssetImage(_bgAsset), context);
  }

  Future<void> _onRefresh() async {
    setState(() => _isRefreshing = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() => _isRefreshing = false);
      ToastUtils.show(context, '数据已刷新 \u{1F389}');
    }
  }

  void _handleAddTap() {
    context.push('/add_item');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: Stack(
          children: [
            _buildBackgroundDecoration(),
            _buildHeaderBackground(),
            SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _onRefresh,
                      child: ListView(
                        padding: const EdgeInsets.only(top: 12, bottom: 12),
                        children: [
                         
                          _buildHeaderContent(),
                          const SizedBox(height: 16),
                          _buildDataCards(),
                          const SizedBox(height: 24),
                          const SectionTitle(title: '快捷功能'),
                          const SizedBox(height: 14),
                          _buildQuickActions(),
                          const SizedBox(height: 24),
                          SectionTitle(
                            title: '待处理事项',
                            showMore: true,
                            onMoreTap: () => _navigateToInventory(),
                          ),
                          const SizedBox(height: 14),
                          _buildPendingSection(),
                          const SizedBox(height: 20),
                          SectionTitle(
                            title: '最近新增',
                            showMore: true,
                            onMoreTap: () => _navigateToInventory(),
                          ),
                          const SizedBox(height: 14),
                          const RecentSection(),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderBackground() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: 320,
      child: Stack(
        children: [
          // 兜底背景色：图片解码完成前显示此颜色，避免闪烁
          Positioned.fill(child: Container(color: AppColors.primaryLight)),
          Positioned.fill(
            child: Image.asset(
              _bgAsset,
              fit: BoxFit.fill,
              // 图片解码完成后淡入显示，避免突然出现的闪烁
              frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                final loaded = wasSynchronouslyLoaded || frame != null;
                return AnimatedOpacity(
                  opacity: loaded ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  child: child,
                );
              },
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.background.withValues(alpha: 0.15),
                    AppColors.background.withValues(alpha: 0.08),
                    AppColors.background.withValues(alpha: 0.25),
                    AppColors.background.withValues(alpha: 0.6),
                    AppColors.background.withValues(alpha: 0.9),
                    AppColors.background,
                  ],
                  stops: const [0.0, 0.15, 0.45, 0.7, 0.88, 1.0],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundDecoration() {
    return Positioned.fill(
      child: Stack(
        children: [
          Positioned(
            top: 60,
            right: -40,
            width: 160,
            height: 160,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: 300,
            left: -30,
            width: 100,
            height: 100,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.06),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: 200,
            right: -20,
            width: 120,
            height: 120,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBar() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 28, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '9:41',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          Row(
            children: [
              Icon(
                Icons.signal_cellular_alt,
                size: 16,
                color: AppColors.textPrimary,
              ),
              SizedBox(width: 6),
              Icon(Icons.wifi, size: 16, color: AppColors.textPrimary),
              SizedBox(width: 6),
              Icon(Icons.battery_full, size: 16, color: AppColors.textPrimary),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderContent() {
    final profile = ref.watch(profileManagerProvider);
    final nickname = profile.asData?.value['nickname'] ?? '小橘';
    final hour = DateTime.now().hour;
    final String greeting;
    final String subtitle;
    if (hour < 5) {
      greeting = '凌晨好';
      subtitle = '夜深了，注意休息';
    } else if (hour < 11) {
      greeting = '早上好';
      subtitle = '新的一天，从整理开始';
    } else if (hour < 13) {
      greeting = '中午好';
      subtitle = '午间时光，轻松盘点';
    } else if (hour < 18) {
      greeting = '傍晚好';
      subtitle = '夕阳西下，整理收尾';
    } else {
      greeting = '晚上好';
      subtitle = '晚安前，回顾今日';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$greeting，$nickname',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }

  Widget _buildDataCards() {
    return DataCardsSection(
      itemCount: ref.watch(itemCountProvider),
      totalValue: ref.watch(totalValueProvider),
      pendingCount: ref.watch(pendingCountProvider),
      idleCount: ref.watch(idleCountProvider),
      weeklyNewCount: ref.watch(weeklyNewCountProvider),
      monthlyGrowth: ref.watch(monthlyGrowthProvider),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.75,
        children: [
          // QuickActionCard(
          //   icon: Icons.download,
          //   label: '一键导入',
          //   startColor: AppColors.gradientGold,
          //   endColor: AppColors.primary,
          //   onTap: () => context.push('/order-import'),
          //   delayMs: 50,
          // ),
          // QuickActionCard(
          //   icon: Icons.add_circle,
          //   label: '新增物品',
          //   startColor: AppColors.gradientOrange,
          //   endColor: AppColors.gradientOrangeEnd,
          //   onTap: _handleAddTap,
          //   delayMs: 120,
          // ),
          QuickActionCard(
            icon: Icons.grid_view,
            label: '分类管理',
            startColor: AppColors.gradientGreen,
            endColor: AppColors.gradientGreenEnd,
            onTap: () => context.push('/categories'),
            delayMs: 190,
          ),
          QuickActionCard(
            icon: Icons.home,
            label: '收纳位置',
            startColor: AppColors.gradientBlue,
            endColor: AppColors.gradientBlueEnd,
            onTap: () => context.go('/storage'),
            delayMs: 260,
          ),
        ],
      ),
    );
  }

  Widget _buildPendingSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          PendingCard(
            title: '即将到期',
            desc: '保修期即将到期的物品',
            count: ref.watch(pendingCountProvider).toString(),
            type: PendingCardType.expiring,
            onTap: () => _navigateToInventory(statusFilter: 'expiring'),
          ),
          const SizedBox(height: 10),
          PendingCard(
            title: '过保物品',
            desc: '已过保修期的物品',
            count: ref.watch(idleCountProvider).toString(),
            type: PendingCardType.returning,
            onTap: () => _navigateToInventory(statusFilter: 'idle'),
          ),
          const SizedBox(height: 10),
          PendingCard(
            title: '在保物品',
            desc: '保修期内的物品',
            count: ref.watch(warrantyCountProvider).toString(),
            type: PendingCardType.restocking,
            onTap: () => _navigateToInventory(statusFilter: 'underWarranty'),
          ),
        ],
      ),
    );
  }

  void _navigateToInventory({String? statusFilter}) {
    if (statusFilter != null) {
      ref.read(pendingStatusFilterProvider.notifier).set(statusFilter);
    }
    context.go('/inventory');
  }
}

/// 打招呼的小猫小狗动画组件
class _GreetingPet extends StatefulWidget {
  const _GreetingPet();

  @override
  State<_GreetingPet> createState() => _GreetingPetState();
}

class _GreetingPetState extends State<_GreetingPet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _wave;
  Timer? _swapTimer;
  bool _showCat = true;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _wave = Tween<double>(
      begin: 0.85,
      end: 1.08,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _ctrl.repeat(reverse: true);
    _swapTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (mounted) setState(() => _showCat = !_showCat);
    });
  }

  @override
  void dispose() {
    _swapTimer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _wave,
      builder: (context, child) {
        return Transform.scale(
          scale: _wave.value,
          child: Transform.rotate(
            angle: (_wave.value - 1.0) * 0.5,
            child: child,
          ),
        );
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        switchInCurve: Curves.easeOutBack,
        child: Text(
          _showCat ? '🐱' : '🐶',
          key: ValueKey(_showCat),
          style: const TextStyle(fontSize: 32),
        ),
      ),
    );
  }
}
