import 'package:shared_preferences/shared_preferences.dart';

/// 首次启动状态管理服务。
///
/// 使用 SharedPreferences 持久化首次启动标记，确保跨设备重启和App升级后状态可靠。
/// 仅在首次安装运行时返回 true，完成引导后标记为已完成，后续启动直接跳过 splash。
class FirstRunService {
  static const _keyCompleted = 'splash_completed';

  static SharedPreferences? _prefs;

  /// 初始化 SharedPreferences 实例，应在 App 启动时调用。
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// 是否为首次启动（尚未完成 splash 展示）。
  static bool get isFirstRun {
    return !(_prefs?.getBool(_keyCompleted) ?? false);
  }

  /// 标记 splash 已展示完成，后续启动不再显示。
  static Future<void> markCompleted() async {
    await _prefs?.setBool(_keyCompleted, true);
  }
}
