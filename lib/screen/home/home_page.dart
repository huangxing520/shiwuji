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
import 'data_cards_section.dart';
import 'recent_section.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  bool _isRefreshing = false;

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
            SafeArea(
              child: Column(
                children: [
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
                  '早上好，小橘 \u{1F31E}',
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
          //_buildHeaderAction(Icons.notifications_none, badgeCount: 3),
          //_buildHeaderAction(Icons.settings),
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
              color: AppColors.textPrimary.withValues(alpha: 0.06),
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
                color: AppColors.textPrimary.withValues(alpha: 0.06),
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
    return DataCardsSection(
      itemCount: ref.watch(itemCountProvider),
      totalValue: ref.watch(totalValueProvider),
      pendingCount: ref.watch(pendingCountProvider),
      idleCount: ref.watch(idleCountProvider),
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
            onTap: () => context.push('/order-import'),
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
            title: '闲置物品',
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
