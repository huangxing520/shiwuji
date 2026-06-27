import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shi_wu_ji/constants/app_colors.dart';
import 'package:shi_wu_ji/widgets/gradient_background.dart';
import 'package:shi_wu_ji/widgets/toast_utils.dart';
import 'package:shi_wu_ji/providers/database_provider.dart';
import 'package:shi_wu_ji/services/webdav_service.dart';
import 'package:go_router/go_router.dart';

class DataBackupPage extends ConsumerStatefulWidget {
  const DataBackupPage({super.key});

  @override
  ConsumerState<DataBackupPage> createState() => _DataBackupPageState();
}

class _DataBackupPageState extends ConsumerState<DataBackupPage> {
  final _webDavService = WebDavService();

  late TextEditingController _urlController;
  late TextEditingController _userController;
  late TextEditingController _passController;
  late TextEditingController _dirController;

  bool _isTesting = false;
  bool _isConnected = false;
  bool _isBackingUp = false;
  bool _isRestoring = false;
  bool _isLoading = true;
  List<BackupFileInfo> _backups = [];
  bool _isLoadingBackups = false;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController();
    _userController = TextEditingController();
    _passController = TextEditingController();
    _dirController = TextEditingController();
    _loadConfig();
  }

  @override
  void dispose() {
    _urlController.dispose();
    _userController.dispose();
    _passController.dispose();
    _dirController.dispose();
    super.dispose();
  }

  Future<void> _loadConfig() async {
    final dao = ref.read(settingsDaoProvider);
    final url = await dao.getValue('webdav_url') ?? '';
    final user = await dao.getValue('webdav_user') ?? '';
    final pass = await dao.getValue('webdav_password') ?? '';
    final dir = await dao.getValue('webdav_dir') ?? '';

    setState(() {
      _urlController.text = url;
      _userController.text = user;
      _passController.text = pass;
      _dirController.text = dir;
      _isLoading = false;
    });

    if (url.isNotEmpty && user.isNotEmpty) {
      _configureClient();
    }
  }

  void _configureClient() {
    _webDavService.configure(
      _urlController.text.trim(),
      _userController.text.trim(),
      _passController.text,
      dir: _dirController.text.trim(),
    );
  }

  Future<void> _saveConfig() async {
    final dao = ref.read(settingsDaoProvider);
    await dao.setAll({
      'webdav_url': _urlController.text.trim(),
      'webdav_user': _userController.text.trim(),
      'webdav_password': _passController.text,
      'webdav_dir': _dirController.text.trim(),
    });
  }

  Future<void> _testConnection() async {
    if (_urlController.text.trim().isEmpty) {
      ToastUtils.show(context, '请填写服务器地址');
      return;
    }

    setState(() {
      _isTesting = true;
      _isConnected = false;
    });

    _configureClient();
    final ok = await _webDavService.testConnection();

    if (!mounted) return;
    setState(() {
      _isTesting = false;
      _isConnected = ok;
    });

    if (ok) {
      await _saveConfig();
      if (!mounted) return;
      ToastUtils.show(context, '连接成功');
      _loadBackups();
    } else {
      if (!mounted) return;
      ToastUtils.show(context, '连接失败，请检查配置');
    }
  }

  Future<void> _loadBackups() async {
    if (!_isConnected) return;
    setState(() => _isLoadingBackups = true);
    try {
      final list = await _webDavService.listBackups();
      if (mounted) setState(() => _backups = list);
    } catch (_) {}
    if (mounted) setState(() => _isLoadingBackups = false);
  }

  Future<void> _doBackup() async {
    if (!_isConnected) {
      ToastUtils.show(context, '请先测试连接');
      return;
    }

    setState(() => _isBackingUp = true);
    try {
      final db = ref.read(databaseProvider);
      final filename = await _webDavService.backup(db);
      if (!mounted) return;
      ToastUtils.show(context, '备份成功：$filename');
      _loadBackups();
    } catch (e) {
      if (!mounted) return;
      ToastUtils.show(context, '备份失败：${e.toString().split('\n').first}');
    }
    if (mounted) setState(() => _isBackingUp = false);
  }

  Future<void> _doRestore(BackupFileInfo info) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认恢复',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text('将从「${info.name}」恢复所有数据，当前数据会被覆盖。确定继续？'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('确定恢复'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isRestoring = true);
    try {
      final db = ref.read(databaseProvider);
      await _webDavService.restore(db, info.path);
      if (!mounted) return;
      ToastUtils.show(context, '恢复成功，请重启应用');
    } catch (e) {
      if (!mounted) return;
      ToastUtils.show(context, '恢复失败：${e.toString().split('\n').first}');
    }
    if (mounted) setState(() => _isRestoring = false);
  }

  Future<void> _deleteBackup(BackupFileInfo info) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除备份',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text('确定删除「${info.name}」？此操作不可恢复。'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _webDavService.deleteBackup(info.path);
      if (!mounted) return;
      ToastUtils.show(context, '已删除');
      _loadBackups();
    } catch (e) {
      if (!mounted) return;
      ToastUtils.show(context, '删除失败');
    }
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
                  _buildTopBar(),
                  Expanded(
                    child: _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          )
                        : ListView(
                            padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
                            children: [
                              _buildConfigCard(),
                              const SizedBox(height: 16),
                              _buildActionCard(),
                              if (_isConnected) ...[
                                const SizedBox(height: 24),
                                _buildHistorySection(),
                              ],
                              const SizedBox(height: 80),
                            ],
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
            top: 40,
            right: -40,
            width: 140,
            height: 140,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.07),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: 150,
            left: -30,
            width: 100,
            height: 100,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 20, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.textPrimary.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                size: 18,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            '数据备份',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfigCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.cloud_outlined,
                    size: 20, color: AppColors.info),
              ),
              const SizedBox(width: 10),
              const Text(
                'WebDAV 服务器配置',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInputField(
            controller: _urlController,
            label: '服务器地址',
            hint: 'https://dav.example.com/',
            icon: Icons.link,
          ),
          const SizedBox(height: 12),
          _buildInputField(
            controller: _userController,
            label: '用户名',
            hint: '请输入用户名',
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 12),
          _buildInputField(
            controller: _passController,
            label: '密码',
            hint: '请输入密码',
            icon: Icons.lock_outline,
            obscureText: true,
          ),
          const SizedBox(height: 12),
          _buildInputField(
            controller: _dirController,
            label: '备份目录（可选）',
            hint: '/shiwuji_backups',
            icon: Icons.folder_outlined,
          ),
          const SizedBox(height: 16),
          _buildTestButton(),
          if (_isConnected)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '已连接',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 13),
            prefixIcon: Icon(icon, size: 18, color: AppColors.textHint),
            prefixIconConstraints: const BoxConstraints(minWidth: 36),
            filled: true,
            fillColor: AppColors.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFF0E4D0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFF0E4D0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.accentGold),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            isDense: true,
          ),
          style: const TextStyle(fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildTestButton() {
    return GestureDetector(
      onTap: _isTesting ? null : _testConnection,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: _isTesting
              ? AppColors.textHint.withValues(alpha: 0.3)
              : AppColors.info.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _isTesting
                ? AppColors.textHint.withValues(alpha: 0.2)
                : AppColors.info.withValues(alpha: 0.3),
          ),
        ),
        child: Center(
          child: _isTesting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppColors.info),
                )
              : Text(
                  '测试连接',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.info,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildActionCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.backup_outlined,
                    size: 20, color: AppColors.primary),
              ),
              const SizedBox(width: 10),
              const Text(
                '备份操作',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '将所有物品、分类、收纳位置数据备份到 WebDAV 服务器。',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          _buildBackupButton(),
        ],
      ),
    );
  }

  Widget _buildBackupButton() {
    final enabled = _isConnected && !_isBackingUp;

    return GestureDetector(
      onTap: enabled ? _doBackup : null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: enabled
              ? const LinearGradient(
                  colors: [AppColors.accentGold, AppColors.warning],
                )
              : null,
          color: enabled ? null : AppColors.textHint.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(18),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: const Color(0x40FFB800),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: _isBackingUp
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : Text(
                  _isBackingUp ? '备份中…' : '立即备份',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: enabled ? Colors.white : AppColors.textHint,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              const Text(
                '备份历史',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: _isLoadingBackups ? null : _loadBackups,
                child: Text(
                  '刷新',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.info,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_isLoadingBackups)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: AppColors.primary),
            ),
          )
        else if (_backups.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 32),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Icon(Icons.cloud_off_outlined,
                    size: 40, color: AppColors.textHint.withValues(alpha: 0.5)),
                const SizedBox(height: 8),
                Text(
                  '暂无备份记录',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textHint,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          )
        else
          ..._backups.map((b) => _buildBackupTile(b)),
      ],
    );
  }

  Widget _buildBackupTile(BackupFileInfo info) {
    final dateStr = _parseFilenameDate(info.name);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.textPrimary.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.description_outlined,
                  size: 20, color: AppColors.success),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dateStr,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    info.name,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textHint,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            _buildIconButton(
              icon: Icons.restore,
              color: AppColors.info,
              onTap: _isRestoring ? null : () => _doRestore(info),
            ),
            const SizedBox(width: 4),
            _buildIconButton(
              icon: Icons.delete_outline,
              color: AppColors.danger,
              onTap: () => _deleteBackup(info),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }

  String _parseFilenameDate(String name) {
    // shiwuji_backup_20260627_143000.json → 2026-06-27 14:30
    try {
      final parts = name.replaceAll('shiwuji_backup_', '').replaceAll('.json', '');
      final date = parts.substring(0, 8);
      final time = parts.substring(9);
      return '${date.substring(0, 4)}-${date.substring(4, 6)}-${date.substring(6, 8)} ${time.substring(0, 2)}:${time.substring(2, 4)}';
    } catch (_) {
      return name;
    }
  }
}
