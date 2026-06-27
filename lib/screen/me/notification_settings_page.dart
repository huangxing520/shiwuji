import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shi_wu_ji/constants/app_colors.dart';
import 'package:shi_wu_ji/services/notification_service.dart';
import 'package:shi_wu_ji/providers/database_provider.dart';
import 'package:shi_wu_ji/widgets/toast_utils.dart';

/// 通知设置页面 —— 开启/关闭保修到期提醒，配置提前提醒天数。
class NotificationSettingsPage extends ConsumerStatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  ConsumerState<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState
    extends ConsumerState<NotificationSettingsPage> {
  bool _enabled = true;
  int _reminderDays = 7;
  bool _loaded = false;

  static const _dayOptions = [3, 7, 14, 30];

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
      _enabled = service.isEnabled;
      _reminderDays = service.reminderDays;
      _loaded = true;
    });
  }

  Future<void> _saveEnabled(bool value) async {
    setState(() => _enabled = value);
    final dao = ref.read(settingsDaoProvider);
    final service = NotificationService();
    await service.savePreferences(
      (k, v) => dao.setValue(k, v),
      enabled: value,
    );
    if (!value) {
      await service.cancelAll();
    }
    if (!mounted) return;
    ToastUtils.show(context, value ? '已开启到期提醒' : '已关闭到期提醒');
  }

  Future<void> _saveReminderDays(int days) async {
    setState(() => _reminderDays = days);
    final dao = ref.read(settingsDaoProvider);
    final service = NotificationService();
    await service.savePreferences(
      (k, v) => dao.setValue(k, v),
      reminderDays: days,
    );
    if (!mounted) return;
    ToastUtils.show(context, '已设置为到期前 $days 天提醒');
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
                    _buildToggleCard(),
                    const SizedBox(height: 16),
                    _buildDaysCard(),
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

  // ─── 通知开关卡片 ─────────────────────────

  Widget _buildToggleCard() {
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
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: _enabled
                  ? AppColors.primary.withValues(alpha: 0.12)
                  : AppColors.border.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              _enabled
                  ? Icons.notifications_active
                  : Icons.notifications_off_outlined,
              size: 26,
              color: _enabled ? AppColors.primary : AppColors.textHint,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '保修到期提醒',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _enabled ? '将在到期前自动推送通知' : '关闭后将不再推送通知',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
          ),
          _buildSwitch(_enabled, onChanged: _saveEnabled),
        ],
      ),
    );
  }

  // ─── 提醒天数卡片 ─────────────────────────

  Widget _buildDaysCard() {
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
            '在保修到期前几天提醒你',
            style: TextStyle(fontSize: 12, color: AppColors.textHint),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _dayOptions.map((days) {
              final isSelected = _reminderDays == days;
              return GestureDetector(
                onTap: _enabled ? () => _saveReminderDays(days) : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFFFF3CC)
                        : AppColors.background,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color:
                          isSelected ? AppColors.primary : AppColors.border,
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
                          : _enabled
                              ? AppColors.textSecondary
                              : AppColors.textHint,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ─── 信息卡片 ─────────────────────────────

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.info.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 18, color: AppColors.info),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '新增物品时，如果开启了保修到期提醒，系统会自动在到期前 $_reminderDays 天推送通知到你的手机通知栏。',
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
    return GestureDetector(
      onTap: _enabled ? _sendTest : null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: _enabled ? AppColors.cardBg : AppColors.background,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _enabled ? AppColors.primary : AppColors.border,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.send,
              size: 16,
              color: _enabled ? AppColors.primary : AppColors.textHint,
            ),
            const SizedBox(width: 8),
            Text(
              '发送测试通知',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _enabled ? AppColors.primary : AppColors.textHint,
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
