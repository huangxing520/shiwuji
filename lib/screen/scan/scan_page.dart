import 'package:flutter/material.dart';
import 'package:flutter_smart_scanner/flutter_smart_scanner.dart';
import 'package:shi_wu_ji/constants/app_colors.dart';
import 'package:shi_wu_ji/widgets/toast_utils.dart';

/// 物体扫描页面：使用 flutter_smart_scanner 进行实时物体识别
///
/// SmartScanner widget 内置了模式切换、目标框、缩放/闪光灯控件，
/// 本页面在此基础上叠加：顶部返回栏 + 底部检测结果面板。
class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  /// 最近一次检测结果
  List<ScannerResult> _latestResults = const [];

  String _modeLabel(ScannerMode m) {
    switch (m) {
      case ScannerMode.object:
        return '物体';
      case ScannerMode.face:
        return '人脸';
      case ScannerMode.text:
        return '文字';
      case ScannerMode.barcode:
        return '条码';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 扫描器主体（内置模式 picker、目标框、缩放/闪光灯控件）
          Positioned.fill(
            child: SmartScanner(
              accentColor: AppColors.primary,
              onDetect: (results) {
                if (!mounted) return;
                setState(() => _latestResults = results);
              },
            ),
          ),
          // 顶部返回栏
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    _buildCircleButton(
                      icon: Icons.arrow_back_ios_new,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                    const Spacer(),
                    _buildCircleButton(
                      icon: Icons.refresh,
                      onTap: () {
                        setState(() => _latestResults = const []);
                        ToastUtils.show(context, '已清空识别结果');
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          // 底部检测结果面板
          if (_latestResults.isNotEmpty)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                top: false,
                child: _buildResultPanel(),
              ),
            ),
        ],
      ),
    );
  }

  /// 顶部圆形按钮
  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.5),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: Colors.white),
      ),
    );
  }

  /// 检测结果面板（可滚动）
  Widget _buildResultPanel() {
    return Container(
      constraints: const BoxConstraints(maxHeight: 220),
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '识别结果',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white70,
                ),
              ),
              const Spacer(),
              Text(
                '${_latestResults.length} 项',
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.white54,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: _latestResults.length,
              separatorBuilder: (_, _) => const Divider(
                color: Colors.white24,
                height: 1,
              ),
              itemBuilder: (context, index) {
                final r = _latestResults[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _modeLabel(r.mode),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          r.content,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        '${(r.confidence * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.white54,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
