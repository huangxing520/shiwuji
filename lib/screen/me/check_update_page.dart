import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shi_wu_ji/constants/app_colors.dart';

/// 检查状态
enum _CheckState { idle, checking, upToDate, newVersion, error }

/// 检查更新页面
///
/// API 地址占位：[_checkUpdateApi]，后续替换为真实接口即可。
class CheckUpdatePage extends StatefulWidget {
  const CheckUpdatePage({super.key});

  @override
  State<CheckUpdatePage> createState() => _CheckUpdatePageState();
}

class _CheckUpdatePageState extends State<CheckUpdatePage>
    with SingleTickerProviderStateMixin {
  // ─── 常量 ───────────────────────────────────
  static const String _currentVersion = '1.0.0';

  /// TODO: 替换为真实的检查更新 API 地址
  static const String _checkUpdateApi = 'https://api.example.com/check-update';

  // ─── 状态 ───────────────────────────────────
  _CheckState _state = _CheckState.idle;

  // 新版本信息（API 返回后填充）
  String _latestVersion = '';
  String _releaseNotes = '';
  String _downloadUrl = '';

  // 动画
  late AnimationController _loadingController;

  @override
  void initState() {
    super.initState();
    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _loadingController.dispose();
    super.dispose();
  }

  // ─── 检查更新逻辑（API 占位）─────────────────

  Future<void> _checkUpdate() async {
    setState(() => _state = _CheckState.checking);
    _loadingController.repeat();

    try {
      // ──────────────────────────────────────────────
      // TODO: 替换为真实 API 调用
      //
      // 示例：
      // final response = await http.get(Uri.parse(_checkUpdateApi));
      // final data = jsonDecode(response.body);
      //
      // 期望返回格式：
      // {
      //   "latest_version": "1.1.0",
      //   "release_notes": "1. 新增XX功能\n2. 修复XX问题",
      //   "download_url": "https://..."
      // }
      //
      // 比对版本号后设置 _state：
      // if (data['latest_version'] != _currentVersion) → _CheckState.newVersion
      // else → _CheckState.upToDate
      // ──────────────────────────────────────────────

      // 模拟网络请求延迟
      await Future.delayed(const Duration(seconds: 2));

      // 占位：模拟"已是最新版本"
      // 实际使用时请替换为上方 TODO 中的真实逻辑
      if (mounted) {
        setState(() {
          _state = _CheckState.upToDate;
          _loadingController.stop();
          _loadingController.reset();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _state = _CheckState.error;
          _loadingController.stop();
          _loadingController.reset();
        });
      }
    }
  }

  void _downloadUpdate() {
    // TODO: 调用真实下载逻辑
    // 例如：openFileX 打开 _downloadUrl，或跳转到应用商店
  }

  // ─── Build ──────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  const SizedBox(height: 24),
                  _buildAppIconSection(),
                  const SizedBox(height: 32),
                  _buildStatusCard(),
                  const SizedBox(height: 24),
                  _buildActionSection(),
                  const SizedBox(height: 24),
                  _buildReleaseNotes(),
                  const SizedBox(height: 32),
                  _buildFooter(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── 顶部导航 ──────────────────────────────

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
              child: const Icon(Icons.chevron_left,
                  size: 20, color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            '检查更新',
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

  // ─── App 图标区域 ──────────────────────────

  Widget _buildAppIconSection() {
    return Center(
      child: Column(
        children: [
          // 图标
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.warning],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.25),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Center(
              child: Text('📦', style: TextStyle(fontSize: 40)),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            '拾物记',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'v$_currentVersion',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── 状态卡片 ──────────────────────────────

  Widget _buildStatusCard() {
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
      child: _buildStatusContent(),
    );
  }

  Widget _buildStatusContent() {
    switch (_state) {
      case _CheckState.idle:
        return _buildIdleContent();
      case _CheckState.checking:
        return _buildCheckingContent();
      case _CheckState.upToDate:
        return _buildUpToDateContent();
      case _CheckState.newVersion:
        return _buildNewVersionContent();
      case _CheckState.error:
        return _buildErrorContent();
    }
  }

  Widget _buildIdleContent() {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.info.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(Icons.system_update, size: 24, color: AppColors.info),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '检查最新版本',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 3),
              Text(
                '点击下方按钮检查是否有新版本可用',
                style: TextStyle(fontSize: 12, color: AppColors.textHint),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCheckingContent() {
    return Row(
      children: [
        SizedBox(
          width: 48,
          height: 48,
          child: Center(
            child: AnimatedBuilder(
              animation: _loadingController,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _loadingController.value * 2 * 3.14159265,
                  child: child,
                );
              },
              child: Icon(Icons.sync, size: 28, color: AppColors.primary),
            ),
          ),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '正在检查更新…',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 3),
              Text(
                '正在连接服务器',
                style: TextStyle(fontSize: 12, color: AppColors.textHint),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUpToDateContent() {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(Icons.check_circle, size: 26, color: AppColors.success),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '已是最新版本',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.success,
                ),
              ),
              SizedBox(height: 3),
              Text(
                '当前版本 v$_currentVersion 已是最新',
                style: TextStyle(fontSize: 12, color: AppColors.textHint),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNewVersionContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.new_releases,
                  size: 26, color: AppColors.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '发现新版本 v$_latestVersion',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '当前 v$_currentVersion → v$_latestVersion',
                    style: TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'NEW',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDark,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildErrorContent() {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.danger.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(Icons.error_outline, size: 26, color: AppColors.danger),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '检查失败',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.danger,
                ),
              ),
              SizedBox(height: 3),
              Text(
                '网络连接异常，请稍后重试',
                style: TextStyle(fontSize: 12, color: AppColors.textHint),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── 操作按钮 ──────────────────────────────

  Widget _buildActionSection() {
    if (_state == _CheckState.newVersion) {
      // 立即更新按钮
      return GestureDetector(
        onTap: _downloadUpdate,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.warning]),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Center(
            child: Text(
              '立即更新',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
      );
    }

    // 检查更新按钮
    final isChecking = _state == _CheckState.checking;
    return GestureDetector(
      onTap: isChecking ? null : _checkUpdate,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: isChecking
              ? null
              : const LinearGradient(
                  colors: [AppColors.primary, AppColors.warning]),
          color: isChecking ? AppColors.border : null,
          boxShadow: isChecking
              ? null
              : [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Center(
          child: Text(
            isChecking ? '检查中…' : '检查更新',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isChecking ? AppColors.textHint : Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  // ─── 更新日志（新版本时显示）──────────────

  Widget _buildReleaseNotes() {
    if (_state != _CheckState.newVersion || _releaseNotes.isEmpty) {
      return const SizedBox.shrink();
    }

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
              Icon(Icons.notes, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              const Text(
                '更新内容',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _releaseNotes,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }

  // ─── 底部信息 ──────────────────────────────

  Widget _buildFooter() {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: (_state != _CheckState.checking) ? _checkUpdate : null,
            child: Text(
              '重新检查',
              style: TextStyle(
                fontSize: 13,
                color: _state == _CheckState.checking
                    ? AppColors.textHint
                    : AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'API: $_checkUpdateApi',
            style: TextStyle(
              fontSize: 10,
              color: AppColors.textHint.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '用心记录，物尽其用',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textHint.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}
