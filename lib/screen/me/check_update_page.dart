import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shi_wu_ji/constants/app_colors.dart';
import 'package:shi_wu_ji/services/update_service.dart';
import 'package:shi_wu_ji/widgets/toast_utils.dart';
import 'package:url_launcher/url_launcher.dart';

/// 检查状态
enum _CheckState { idle, checking, upToDate, newVersion, error }

/// 检查更新页面
///
/// 通过 [UpdateService] 调用后端接口获取最新版本信息。
class CheckUpdatePage extends StatefulWidget {
  const CheckUpdatePage({super.key});

  @override
  State<CheckUpdatePage> createState() => _CheckUpdatePageState();
}

class _CheckUpdatePageState extends State<CheckUpdatePage>
    with SingleTickerProviderStateMixin {
  // ─── 常量 ───────────────────────────────────
  // 当前版本号：从 PackageInfo 读取，未加载前用占位符
  String _currentVersion = '—';

  // ─── 状态 ───────────────────────────────────
  _CheckState _state = _CheckState.idle;

  // 新版本信息（API 返回后填充）
  String _latestVersion = '';
  String _releaseNotes = '';
  String _downloadUrl = '';
  String _htmlUrl = '';

  // 错误信息
  String _errorMessage = '';

  // 动画
  late AnimationController _loadingController;

  @override
  void initState() {
    super.initState();
    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _loadVersion();
  }

  /// 从 PackageInfo 读取当前应用版本号
  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() => _currentVersion = info.version);
      }
    } catch (_) {
      // 读取失败保持占位符
    }
  }

  @override
  void dispose() {
    _loadingController.dispose();
    super.dispose();
  }

  // ─── 检查更新逻辑 ─────────────────────────

  Future<void> _checkUpdate() async {
    setState(() => _state = _CheckState.checking);
    _loadingController.repeat();

    final outcome = await UpdateService.instance.check(_currentVersion);

    if (!mounted) return;
    setState(() {
      _loadingController.stop();
      _loadingController.reset();
      _state = _mapResult(outcome.result);
      _errorMessage = outcome.errorMessage ?? '';
      if (outcome.info != null) {
        _latestVersion = outcome.info!.latestVersion;
        _releaseNotes = outcome.info!.releaseNotes;
        _downloadUrl = outcome.info!.downloadUrl;
        _htmlUrl = outcome.info!.htmlUrl;
      }
    });

    // 发现新版本时弹出更新提示
    if (_state == _CheckState.newVersion) {
      _showUpdateDialog();
    }
  }

  _CheckState _mapResult(CheckResult r) {
    switch (r) {
      case CheckResult.upToDate:
        return _CheckState.upToDate;
      case CheckResult.newVersion:
        return _CheckState.newVersion;
      case CheckResult.error:
        return _CheckState.error;
    }
  }

  /// 弹出更新提示对话框（支持取消）
  void _showUpdateDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.system_update, color: AppColors.primary, size: 24),
              const SizedBox(width: 8),
              const Text('发现新版本'),
            ],
          ),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 320),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'v$_currentVersion → v$_latestVersion',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '更新内容：',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _releaseNotes.isEmpty ? '暂无更新说明' : _releaseNotes,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text(
                '稍后再说',
                style: TextStyle(color: AppColors.textHint),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                _downloadUpdate();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('去更新'),
            ),
          ],
        );
      },
    );
  }

  /// 调用系统浏览器打开 GitHub Release 页面
  Future<void> _downloadUpdate() async {
    final url = _htmlUrl.isNotEmpty
        ? _htmlUrl
        : UpdateService.githubReleasesUrl;
    final uri = Uri.tryParse(url);
    if (uri == null) {
      if (mounted) {
        ToastUtils.show(context, '下载地址无效');
      }
      return;
    }
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && mounted) {
        ToastUtils.show(context, '无法打开浏览器，请稍后重试');
      }
    } catch (e) {
      if (mounted) {
        ToastUtils.show(context, '打开更新页面失败：$e');
      }
    }
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
              child: const Icon(
                Icons.chevron_left,
                size: 20,
                color: AppColors.textSecondary,
              ),
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
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '已是最新版本',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '当前版本 v$_currentVersion 已是最新',
                style: const TextStyle(fontSize: 12, color: AppColors.textHint),
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
              child: Icon(
                Icons.new_releases,
                size: 26,
                color: AppColors.primary,
              ),
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
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
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
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '检查失败',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.danger,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                _errorMessage.isEmpty ? '网络连接异常，请稍后重试' : _errorMessage,
                style: const TextStyle(fontSize: 12, color: AppColors.textHint),
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
              colors: [AppColors.primary, AppColors.warning],
            ),
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
                  colors: [AppColors.primary, AppColors.warning],
                ),
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
            '当前版本 v$_currentVersion',
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
