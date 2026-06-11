import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'add_item_page.dart';
import 'package:shi_wu_ji/constants/app_colors.dart';
import 'package:shi_wu_ji/widgets/toast_utils.dart';
import 'package:shi_wu_ji/widgets/gradient_background.dart';
import 'package:shi_wu_ji/widgets/data_card.dart';
import 'package:shi_wu_ji/widgets/quick_action_card.dart';
import 'package:shi_wu_ji/widgets/list_item_card.dart';
import 'package:shi_wu_ji/widgets/bottom_nav_bar.dart';
import 'package:shi_wu_ji/widgets/section_title.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  TabType _currentTab = TabType.home;
  bool _isRefreshing = false;

  Future<void> _onRefresh() async {
    setState(() => _isRefreshing = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() => _isRefreshing = false);
      ToastUtils.show(context, '数据已刷新 🎉');
    }
  }

  void _handleTabChanged(TabType tab) {
    if (tab != _currentTab) {
      setState(() => _currentTab = tab);
      const labels = {
        TabType.home: '首页',
        TabType.inventory: '物品库',
        TabType.stats: '数据统计',
        TabType.me: '个人中心',
      };
      if (tab != TabType.home) {
        ToastUtils.show(context, '切换到${labels[tab]}');
      }
    }
  }

  void _handleAddTap() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const AddItemPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: Stack(
          children: [
            _buildBackgroundDecoration(),
            SafeArea(
              child: Column(
                children: [
                 // _buildStatusBar(),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _onRefresh,
                      child: ListView(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        children: [
                          _buildHeader(),
                          const SizedBox(height: 4),
                          _buildSearchBar(),
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
                            onMoreTap: () => ToastUtils.show(context, '查看全部待处理'),
                          ),
                          const SizedBox(height: 14),
                          _buildPendingSection(),
                          const SizedBox(height: 20),
                          SectionTitle(
                            title: '最近新增',
                            showMore: true,
                            onMoreTap: () => ToastUtils.show(context, '查看全部物品'),
                          ),
                          const SizedBox(height: 14),
                          _buildRecentSection(),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            //_buildBottomNavBar(),
          ],
        ),
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
                color: AppColors.primary.withOpacity(0.08),
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
                color: AppColors.warning.withOpacity(0.06),
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
                color: AppColors.primary.withOpacity(0.05),
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
              Icon(Icons.signal_cellular_alt, size: 16, color: AppColors.textPrimary),
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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  '早上好，小橘 🌞',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  '你的物品都在掌控中',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _buildHeaderAction(Icons.notifications_none, badgeCount: 3),
          _buildHeaderAction(Icons.settings),
        ],
      ),
    );
  }

  Widget _buildHeaderAction(IconData icon, {int? badgeCount}) {
    return GestureDetector(
      onTap: () {
        if (badgeCount != null) {
          ToastUtils.show(context, '暂无新消息');
        } else {
          ToastUtils.show(context, '打开设置');
        }
      },
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.textPrimary.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(icon, color: AppColors.textSecondary, size: 20),
              if (badgeCount != null)
                Positioned(
                  top: -6,
                  right: -8,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: AppColors.danger,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.background, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        '$badgeCount',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () => ToastUtils.show(context, '搜索物品、分类、收纳位置…'),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: AppColors.textPrimary.withOpacity(0.06),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Row(
            children: [
              Icon(Icons.search, color: AppColors.textHint, size: 20),
              SizedBox(width: 10),
              Text(
                '搜索物品、分类、收纳位置…',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textHint,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDataCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        children: [
          DataCard(
            icon: Icons.inventory,
            target: 236,
            unit: '件',
            label: '物品总数',
            trendLabel: '12 本周新增',
            trendUp: true,
            color: AppColors.accentGold,
            decoColor: AppColors.shimmerGold,
            iconBgColor: AppColors.accentLightBg,
            iconColor: AppColors.accentGold,
            delayMs: 100,
          ),
          DataCard(
            icon: Icons.trending_up,
            target: 48620,
            unit: '元',
            label: '总资产价值',
            trendLabel: '3,280 本月',
            trendUp: true,
            color: AppColors.warning,
            decoColor: AppColors.shimmerOrange,
            iconBgColor: AppColors.warning.withOpacity(0.15),
            iconColor: AppColors.warning,
            delayMs: 200,
          ),
          DataCard(
            icon: Icons.timer,
            target: 8,
            unit: '件',
            label: '即将到期',
            trendLabel: '3天内到期',
            trendUp: false,
            color: AppColors.danger,
            decoColor: AppColors.shimmerRed,
            iconBgColor: AppColors.danger.withOpacity(0.15),
            iconColor: AppColors.danger,
            delayMs: 300,
          ),
          DataCard(
            icon: Icons.archive,
            target: 34,
            unit: '件',
            label: '闲置物品',
            trendLabel: '建议处理',
            trendUp: false,
            color: AppColors.success,
            decoColor: AppColors.shimmerGreen,
            iconBgColor: AppColors.success.withOpacity(0.15),
            iconColor: AppColors.success,
            delayMs: 400,
          ),
        ],
      ),
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
        children: [
          QuickActionCard(
            icon: Icons.download,
            label: '一键导入',
            startColor: AppColors.gradientGold,
            endColor: AppColors.primary,
            onTap: () => ToastUtils.show(context, '打开一键导入订单'),
            delayMs: 50,
          ),
          QuickActionCard(
            icon: Icons.add_circle,
            label: '新增物品',
            startColor: AppColors.gradientOrange,
            endColor: AppColors.gradientOrangeEnd,
            onTap: _handleAddTap,
            delayMs: 120,
          ),
          QuickActionCard(
            icon: Icons.grid_view,
            label: '分类管理',
            startColor: AppColors.gradientGreen,
            endColor: AppColors.gradientGreenEnd,
            onTap: () => ToastUtils.show(context, '打开分类管理'),
            delayMs: 190,
          ),
          QuickActionCard(
            icon: Icons.home,
            label: '收纳位置',
            startColor: AppColors.gradientBlue,
            endColor: AppColors.gradientBlueEnd,
            onTap: () => ToastUtils.show(context, '打开收纳位置'),
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
            desc: '保质期/保修期/会员卡即将到期',
            count: '8',
            type: PendingCardType.expiring,
            onTap: () => ToastUtils.show(context, '查看即将到期物品'),
          ),
          const SizedBox(height: 10),
          PendingCard(
            title: '待归还',
            desc: '借出的物品待归还提醒',
            count: '3',
            type: PendingCardType.returning,
            onTap: () => ToastUtils.show(context, '查看待归还物品'),
          ),
          const SizedBox(height: 10),
          PendingCard(
            title: '待补货',
            desc: '日用品/消耗品需要补充',
            count: '5',
            type: PendingCardType.restocking,
            onTap: () => ToastUtils.show(context, '查看待补货物品'),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          RecentItemCard(
            emoji: '🧹',
            name: '戴森V12吸尘器',
            meta: '家电 · 客厅收纳柜 · 2分钟前',
            tagType: ItemTagType.newItem,
            onTap: () => ToastUtils.show(context, '查看「戴森V12吸尘器」详情'),
          ),
          const SizedBox(height: 8),
          RecentItemCard(
            emoji: '💊',
            name: '兰蔻小黑瓶精华',
            meta: '护肤 · 卧室梳妆台 · 1小时前',
            tagType: ItemTagType.urgent,
            onTap: () => ToastUtils.show(context, '查看「兰蔻小黑瓶」详情'),
          ),
          const SizedBox(height: 8),
          RecentItemCard(
            emoji: '📦',
            name: '宜家思库布收纳箱×3',
            meta: '收纳 · 储物间 · 3小时前',
            tagType: ItemTagType.newItem,
            onTap: () => ToastUtils.show(context, '查看「宜家收纳箱」详情'),
          ),
          const SizedBox(height: 8),
          RecentItemCard(
            emoji: '🎧',
            name: 'AirPods Pro 2',
            meta: '数码 · 书房桌面 · 昨天',
            tagType: ItemTagType.normal,
            onTap: () => ToastUtils.show(context, '查看「AirPods Pro」详情'),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          BottomNavBar(
            currentTab: _currentTab,
            onTabChanged: _handleTabChanged,
            //onAddTap: _handleAddTap,
          ),
          Positioned(
            top: -20,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _handleAddTap,
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.primary, AppColors.warning],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(color: AppColors.cardBg, width: 3),
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 26),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}