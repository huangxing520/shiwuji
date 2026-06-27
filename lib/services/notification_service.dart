import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/item.dart';

/// 通知服务 —— 管理保修到期提醒的本地推送。
///
/// 当前主要面向 Android 平台，其他平台会静默跳过（不崩溃）。
/// 初始化时调用 [init]，内部会判断平台可用性。
class NotificationService {
  NotificationService._();
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  bool _platformSupported = false;

  // ─── 偏好设置 key（存入 Settings 表）───
  static const String keyNotificationsEnabled = 'notifications_enabled';
  static const String keyReminderDays = 'reminder_days';

  // ─── 初始化 ───────────────────────────────

  /// 应用启动时调用，初始化通知插件和时区数据。
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    // 支持 Android、Windows、Linux 等非 Web 平台
    _platformSupported = !kIsWeb;
    if (!_platformSupported) {
      debugPrint('[NotificationService] 当前平台不支持本地通知，已跳过初始化');
      return;
    }

    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@drawable/ic_notification',
    );
    const initSettings = InitializationSettings(android: androidSettings);
    await _plugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Android 13+ (API 33) 需要运行时请求通知权限
    if (!kIsWeb && Platform.isAndroid) {
      final androidPlugin = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      await androidPlugin?.requestNotificationsPermission();
      await androidPlugin?.requestExactAlarmsPermission();
    }

    debugPrint('[NotificationService] 初始化完成');
  }

  void _onNotificationTapped(NotificationResponse response) {
    // 点击通知后的处理 —— 可跳转到对应物品详情页
    debugPrint('[NotificationService] 通知被点击: ${response.payload}');
  }

  // ─── 偏好读写 ─────────────────────────────

  /// 通知开关是否开启（默认 true）
  bool _enabled = true;

  /// 提前几天提醒（默认 7 天）
  int _reminderDays = 7;

  bool get isEnabled => _enabled;
  int get reminderDays => _reminderDays;

  /// 从 Settings DAO 加载偏好
  Future<void> loadPreferences(
    Future<String?> Function(String) getValue,
  ) async {
    final enabled = await getValue(keyNotificationsEnabled);
    _enabled = enabled != 'false'; // 默认 true

    final days = await getValue(keyReminderDays);
    _reminderDays = int.tryParse(days ?? '') ?? 7;
  }

  /// 保存偏好到 Settings DAO
  Future<void> savePreferences(
    Future<void> Function(String, String) setValue, {
    bool? enabled,
    int? reminderDays,
  }) async {
    if (enabled != null) {
      _enabled = enabled;
      await setValue(keyNotificationsEnabled, enabled.toString());
    }
    if (reminderDays != null) {
      _reminderDays = reminderDays;
      await setValue(keyReminderDays, reminderDays.toString());
    }
  }

  // ─── 调度 & 取消 ──────────────────────────

  /// 为单个物品调度保修到期提醒通知。
  ///
  /// 根据当前 [reminderDays] 计算提醒日期，
  /// 如果提醒日期已过则跳过。
  Future<void> scheduleWarrantyReminder(Item item) async {
    if (!_platformSupported || !_enabled) return;

    cancelWarrantyReminder(item.id);

    final warrantyEnd = item.warrantyEndDate;
    final reminderDate = warrantyEnd.subtract(Duration(days: _reminderDays));

    if (reminderDate.isBefore(DateTime.now())) {
      debugPrint('[NotificationService] 提醒日期已过，跳过: ${item.name}');
      return;
    }

    try {
      await _plugin.zonedSchedule(
        id: item.id.hashCode,
        title: '保修即将到期',
        body: '「${item.name}」保修将于 ${warrantyEnd.month}月${warrantyEnd.day}日 到期',
        scheduledDate: tz.TZDateTime.from(reminderDate, tz.local),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'warranty_reminder',
            '保修到期提醒',
            channelDescription: '物品保修即将到期时推送通知提醒',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: null,
        payload: item.id,
      );
      debugPrint('[NotificationService] 已调度提醒: ${item.name} → $reminderDate');
    } catch (e) {
      debugPrint('[NotificationService] 调度通知失败: $e');
    }
  }

  /// 取消指定物品的到期提醒
  Future<void> cancelWarrantyReminder(String itemId) async {
    if (!_platformSupported) return;
    try {
      await _plugin.cancel(id: itemId.hashCode);
    } catch (e) {
      debugPrint('[NotificationService] 取消通知失败: $e');
    }
  }

  /// 批量为多个物品调度提醒（用于初始化或设置变更后重新调度）
  Future<void> scheduleAllReminders(List<Item> items) async {
    if (!_platformSupported || !_enabled) return;
    for (final item in items) {
      if (item.isUnderWarranty && !item.isWarrantyExpired) {
        await scheduleWarrantyReminder(item);
      }
    }
  }

  /// 发送一条测试通知（用于设置页面验证通知是否正常工作）
  Future<void> sendTestNotification() async {
    if (!_platformSupported) return;
    try {
      await _plugin.show(
        id: 99999,
        title: '拾物记 · 通知测试',
        body: '通知功能正常运行，保修到期提醒已开启',
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'warranty_reminder',
            '保修到期提醒',
            channelDescription: '物品保修即将到期时推送通知提醒',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
      );
      debugPrint('[NotificationService] 测试通知已发送');
    } catch (e) {
      debugPrint('[NotificationService] 发送测试通知失败: $e');
    }
  }

  /// 取消所有通知
  Future<void> cancelAll() async {
    if (!_platformSupported) return;
    try {
      await _plugin.cancelAll();
      debugPrint('[NotificationService] 已取消所有通知');
    } catch (e) {
      debugPrint('[NotificationService] 取消所有通知失败: $e');
    }
  }
}
