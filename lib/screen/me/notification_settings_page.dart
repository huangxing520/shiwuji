import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shi_wu_ji/constants/app_colors.dart';
import 'package:shi_wu_ji/services/notification_service.dart';
import 'package:shi_wu_ji/models/item.dart';
import 'package:shi_wu_ji/providers/database_provider.dart';
import 'package:shi_wu_ji/providers/item_providers.dart';
import 'package:shi_wu_ji/widgets/toast_utils.dart';

/// 通知设置页面 —— 保修 / 保质期到期提醒各自独立开关与提前天数。
///
/// 两类提醒完全分离：各自有开关与天数选项，互不影响；任一设置变更后实时重排既有提醒。
class NotificationSettingsPage extends ConsumerStatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  ConsumerState<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState
    extends ConsumerState<NotificationSettingsPage> {
  bool _warrantyEnabled = true;
  int _warrantyReminderDays = 7;
  bool _shelfLifeEnabled = true;
  int _shelfLifeReminderDays = 3;
  bool _loaded = false;

  static const _warrantyDayOptions = [3, 7, 14, 30];
  static const _shelfLifeDayOptions = [1, 3, 7];

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final dao = ref.read(settingsDaoProvider);
    final service = NotificationService();
    await service.loadPreferences((key) => dao.getValue(key));
    setState(() {
      _warrantyEnabled = service.isWarrantyEnabled;
      _warrantyReminderDays = service.warrantyReminderDays;
      _shelfLifeEnabled = service.isShelfLifeEnabled;
      _shelfLifeReminderDays = service.shelfLifeReminderDays;
      _loaded = true;
    });
  }

  /// 读取当前所有物品（用于设置变更后重排提醒）
  Future<List<Item>> _loadAllItems() async {
    final rows = await ref.read(itemDaoProvider).getAllItems();
    return rows.map(Items.toModel).toList();
  }

  // ─── 保修 ───────────────────────────────

  Future<void> _saveWarrantyEnabled(bool value) async {
    setState(() => _warrantyEnabled = value);
    final dao = ref.read(settingsDaoProvider);
    final service = NotificationService();
    await service.savePreferences(
      (k, v) => dao.setValue(k, v),
      warrantyEnabled: value,
    );
    // 实时重排：开关关时仅取消既有保修通知，不影响保质期
    final items = await _loadAllItems();
    await service.rescheduleAllWarrantyReminders(items);
    if (!mounted) return;
    ToastUtils.show(context, value ? '已开启保修提醒' : '已关闭保修提醒');
  }

  Future<void> _saveWarrantyDays(int days) async {
    setState(() => _warrantyReminderDays = days);
    final dao = ref.read(settingsDaoProvider);
    final service = NotificationService();
    await service.savePreferences(
      (k, v) => dao.setValue(k, v),
      warrantyReminderDays: days,
    );
    final items = await _loadAllItems();
    await service.rescheduleAllWarrantyReminders(items);
    if (!mounted) return;
    ToastUtils.show(context, '已设置为保修到期前 $days 天提醒');
  }

  // ─── 保质期 ─────────────────────────────

  Future<void> _saveShelfLifeEnabled(bool value) async {
    setState(() => _shelfLifeEnabled = value);
    final dao = ref.read(settingsDaoProvider);
    final service = NotificationService();
    await service.savePreferences(
      (k, v) => dao.setValue(k, v),
      shelfLifeEnabled: value,
    );
    final items = await _loadAllItems();
    await service.rescheduleAllShelfLifeReminders(items);
    if (!mounted) return;
    ToastUtils.show(context, value ? '已开启保质期提醒' : '已关闭保质期提醒');
  }

  Future<void> _saveShelfLifeDays(int days) async {
    setState(() => _shelfLifeReminderDays = days);
    final dao = ref.read(settingsDaoProvider);
    final service = NotificationService();
    await service.savePreferences(
      (k, v) => dao.setValue(k, v),
      shelfLifeReminderDays: days,
    );
    final items = await _loadAllItems();
    await service.rescheduleAllShelfLifeReminders(items);
    if (!mounted) return;
    ToastUtils.show(context, '已设置为保质期到期前 $days 天提醒');
  }

  Future<void> _sendTest() async {
    await NotificationService().sendTestNotification();
    if (mounted) {
      ToastUtils.show(context, '测试通知已发送，请检查通知栏');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            if (_loaded)
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    const SizedBox(height: 12),
                    _buildWarrantyCard(),
                    const SizedBox(height: 16),
                    _buildShelfLifeCard(),
                    const SizedBox(height: 16),
                    _buildInfoCard(),
                    const SizedBox(height: 16),
                    _buildTestButton(),
                    const SizedBox(height: 32),
                  ],
                ),
              )
            else
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ─── 顶部导航 ─────────────────────────────

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.textPrimary.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.chevron_left,
                size: 20,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            '通知设置',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // ─── 提醒卡片（开关 + 天数，通用结构）──────

  Widget _buildReminderCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String daysDesc,
    required List<int> dayOptions,
    required int selectedDays,
    required bool enabled,
    required ValueChanged<bool> onToggle,
    required ValueChanged<int> onPickDay,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 开关行
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: enabled
                      ? AppColors.primary.withValues(alpha: 0.12)
                      : AppColors.border.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  size: 26,
                  color: enabled ? AppColors.primary : AppColors.textHint,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 13, color: AppColors.textHint),
                    ),
                  ],
                ),
              ),
              _buildSwitch(enabled, onChanged: onToggle),
            ],
          ),
          const SizedBox(height: 18),
          // 天数选择区
          Row(
            children: [
              Icon(Icons.schedule, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              const Text(
                '提醒时间',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            daysDesc,
            style: TextStyle(fontSize: 12, color: AppColors.textHint),
          ),
          const SizedBox(height: 14),
          _buildDayChips(
            options: dayOptions,
            selectedDays: selectedDays,
            enabled: enabled,
            onPick: onPickDay,
          ),
        ],
      ),
    );
  }

  // ─── 保修提醒卡片 ─────────────────────────

  Widget _buildWarrantyCard() {
    return _buildReminderCard(
      icon: Icons.verified_outlined,
      title: '保修提醒',
      subtitle: _warrantyEnabled
          ? '将在保修到期前 $_warrantyReminderDays 天推送通知'
          : '关闭后将不再推送保修通知',
      daysDesc: '在保修到期前几天提醒你',
      dayOptions: _warrantyDayOptions,
      selectedDays: _warrantyReminderDays,
      enabled: _warrantyEnabled,
      onToggle: _saveWarrantyEnabled,
      onPickDay: _saveWarrantyDays,
    );
  }

  // ─── 保质期提醒卡片 ───────────────────────

  Widget _buildShelfLifeCard() {
    return _buildReminderCard(
      icon: Icons.inventory_2_outlined,
      title: '保质期提醒',
      subtitle: _shelfLifeEnabled
          ? '将在保质期到期前 $_shelfLifeReminderDays 天推送通知'
          : '关闭后将不再推送保质期通知',
      daysDesc: '在保质期到期前几天提醒你',
      dayOptions: _shelfLifeDayOptions,
      selectedDays: _shelfLifeReminderDays,
      enabled: _shelfLifeEnabled,
      onToggle: _saveShelfLifeEnabled,
      onPickDay: _saveShelfLifeDays,
    );
  }

  /// 天数单选 chips —— 选中态有明显视觉反馈；开关关闭时禁用点击。
  Widget _buildDayChips({
    required List<int> options,
    required int selectedDays,
    required bool enabled,
    required ValueChanged<int> onPick,
  }) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: options.map((days) {
        final isSelected = selectedDays == days;
        return GestureDetector(
          onTap: enabled ? () => onPick(days) : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFFFFF3CC)
                  : AppColors.background,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
                width: 1.5,
              ),
            ),
            child: Text(
              '$days 天',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? AppColors.primaryDark
                    : enabled
                    ? AppColors.textSecondary
                    : AppColors.textHint,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ─── 信息卡片 ─────────────────────────────

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 18, color: AppColors.info),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '新增 / 编辑物品时，系统会按此处配置自动调度提醒：保修到期前 '
              '$_warrantyReminderDays 天、保质期到期前 $_shelfLifeReminderDays '
              '天，于当天 08:00 推送通知。修改设置后会立即重排既有提醒；若提醒时刻已过则不再补发。',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── 测试按钮 ─────────────────────────────

  Widget _buildTestButton() {
    final anyEnabled = _warrantyEnabled || _shelfLifeEnabled;
    return GestureDetector(
      onTap: anyEnabled ? _sendTest : null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: anyEnabled ? AppColors.cardBg : AppColors.background,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: anyEnabled ? AppColors.primary : AppColors.border,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.send,
              size: 16,
              color: anyEnabled ? AppColors.primary : AppColors.textHint,
            ),
            const SizedBox(width: 8),
            Text(
              '发送测试通知',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: anyEnabled ? AppColors.primary : AppColors.textHint,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── 开关组件 ─────────────────────────────

  Widget _buildSwitch(bool value, {required ValueChanged<bool> onChanged}) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 52,
        height: 30,
        decoration: BoxDecoration(
          color: value ? AppColors.primary : AppColors.border,
          borderRadius: BorderRadius.circular(15),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 300),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 24,
            height: 24,
            margin: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
