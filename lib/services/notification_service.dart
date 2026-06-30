import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/item.dart';

/// 通知服务 —— 管理保修 / 保质期到期提醒的本地推送。
///
/// 保修与保质期两类提醒**完全独立**：各自有开关与提前天数，互不影响。
/// 提醒时刻统一为「到期日往前推 N 天当天的 08:00」；若该 08:00 已过则跳过。
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
  // 保修：复用原 key 以兼容旧版本数据。
  static const String keyWarrantyEnabled = 'notifications_enabled';
  static const String keyWarrantyReminderDays = 'reminder_days';
  // 保质期：新增独立 key。
  static const String keyShelfLifeEnabled = 'shelf_life_notifications_enabled';
  static const String keyShelfLifeReminderDays = 'shelf_life_reminder_days';

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

  /// 保修提醒开关（默认 true）
  bool _warrantyEnabled = true;

  /// 保修提前几天提醒（默认 7 天）
  int _warrantyReminderDays = 7;

  /// 保质期提醒开关（默认 true）
  bool _shelfLifeEnabled = true;

  /// 保质期提前几天提醒（默认 3 天）
  int _shelfLifeReminderDays = 3;

  bool get isWarrantyEnabled => _warrantyEnabled;
  int get warrantyReminderDays => _warrantyReminderDays;
  bool get isShelfLifeEnabled => _shelfLifeEnabled;
  int get shelfLifeReminderDays => _shelfLifeReminderDays;

  /// 从 Settings DAO 加载偏好
  Future<void> loadPreferences(
    Future<String?> Function(String) getValue,
  ) async {
    final warrantyEnabled = await getValue(keyWarrantyEnabled);
    _warrantyEnabled = warrantyEnabled != 'false'; // 默认 true

    final warrantyDays = await getValue(keyWarrantyReminderDays);
    _warrantyReminderDays = int.tryParse(warrantyDays ?? '') ?? 7;

    final shelfLifeEnabled = await getValue(keyShelfLifeEnabled);
    // 未设置时默认 true（与历史「总开关开 → 保质期即开」行为一致）
    _shelfLifeEnabled = shelfLifeEnabled == null
        ? true
        : shelfLifeEnabled != 'false';

    final shelfLifeDays = await getValue(keyShelfLifeReminderDays);
    _shelfLifeReminderDays = int.tryParse(shelfLifeDays ?? '') ?? 3;
  }

  /// 保存偏好到 Settings DAO
  Future<void> savePreferences(
    Future<void> Function(String, String) setValue, {
    bool? warrantyEnabled,
    int? warrantyReminderDays,
    bool? shelfLifeEnabled,
    int? shelfLifeReminderDays,
  }) async {
    if (warrantyEnabled != null) {
      _warrantyEnabled = warrantyEnabled;
      await setValue(keyWarrantyEnabled, warrantyEnabled.toString());
    }
    if (warrantyReminderDays != null) {
      _warrantyReminderDays = warrantyReminderDays;
      await setValue(keyWarrantyReminderDays, warrantyReminderDays.toString());
    }
    if (shelfLifeEnabled != null) {
      _shelfLifeEnabled = shelfLifeEnabled;
      await setValue(keyShelfLifeEnabled, shelfLifeEnabled.toString());
    }
    if (shelfLifeReminderDays != null) {
      _shelfLifeReminderDays = shelfLifeReminderDays;
      await setValue(
        keyShelfLifeReminderDays,
        shelfLifeReminderDays.toString(),
      );
    }
  }

  // ─── 调度 & 取消 ──────────────────────────

  /// 计算提醒时刻：到期日 [endDate] 往前推 [days] 天当天的 08:00。
  /// 若该时刻已过返回 null（调用方应跳过调度）。
  DateTime? _reminderAt8am(DateTime endDate, int days) {
    final end = DateTime(endDate.year, endDate.month, endDate.day);
    final at8 = DateTime(
      end.year,
      end.month,
      end.day,
      8,
    ).subtract(Duration(days: days));
    return at8.isBefore(DateTime.now()) ? null : at8;
  }

  /// 为单个物品调度保修到期提醒通知。
  ///
  /// 根据当前 [_warrantyReminderDays] 计算提醒日期（08:00），
  /// 如果提醒时刻已过则跳过。
  Future<void> scheduleWarrantyReminder(Item item) async {
    if (!_platformSupported || !_warrantyEnabled) return;

    cancelWarrantyReminder(item.id);

    final reminderAt8am = _reminderAt8am(
      item.warrantyEndDate,
      _warrantyReminderDays,
    );
    if (reminderAt8am == null) {
      debugPrint('[NotificationService] 保修提醒时刻已过，跳过: ${item.name}');
      return;
    }

    final warrantyEnd = item.warrantyEndDate;
    try {
      await _plugin.zonedSchedule(
        id: item.id.hashCode,
        title: '保修即将到期',
        body: '「${item.name}」保修将于 ${warrantyEnd.month}月${warrantyEnd.day}日 到期',
        scheduledDate: tz.TZDateTime.from(reminderAt8am, tz.local),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'warranty_reminder',
            '保修到期提醒',
            channelDescription: '物品保修即将到期时推送通知提醒',
            importance: Importance.high,
            priority: Priority.high,
            largeIcon: DrawableResourceAndroidBitmap('@mipmap/launcher_icon'),
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: null,
        payload: item.id,
      );
      debugPrint(
        '[NotificationService] 已调度保修提醒: ${item.name} → $reminderAt8am',
      );
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

  /// 保质期提醒通知 id 异或掩码 —— 与保修提醒（id = itemId.hashCode）区分，避免相互覆盖。
  static const int _shelfLifeIdMask = 0x5F4C0000;

  /// 为单个物品调度保质期到期提醒通知。
  ///
  /// 仅当物品设置了保质期（shelfLifeDays > 0）时生效。
  /// 提醒时刻 = 保质期结束日 - [_shelfLifeReminderDays] 当天 08:00；若已过则跳过。
  Future<void> scheduleShelfLifeReminder(Item item) async {
    if (!_platformSupported || !_shelfLifeEnabled) return;
    if (item.shelfLifeDays <= 0) return;

    cancelShelfLifeReminder(item.id);

    final reminderAt8am = _reminderAt8am(
      item.shelfLifeEndDate,
      _shelfLifeReminderDays,
    );
    if (reminderAt8am == null) {
      debugPrint('[NotificationService] 保质期提醒时刻已过，跳过: ${item.name}');
      return;
    }

    final expiryEnd = item.shelfLifeEndDate;
    try {
      await _plugin.zonedSchedule(
        id: item.id.hashCode ^ _shelfLifeIdMask,
        title: '保质期即将到期',
        body: '「${item.name}」保质期将于 ${expiryEnd.month}月${expiryEnd.day}日 到期',
        scheduledDate: tz.TZDateTime.from(reminderAt8am, tz.local),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'shelf_life_reminder',
            '保质期到期提醒',
            channelDescription: '物品保质期即将到期时推送通知提醒',
            importance: Importance.high,
            priority: Priority.high,
            largeIcon: DrawableResourceAndroidBitmap('@mipmap/launcher_icon'),
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: null,
        payload: item.id,
      );
      debugPrint(
        '[NotificationService] 已调度保质期提醒: ${item.name} → $reminderAt8am',
      );
    } catch (e) {
      debugPrint('[NotificationService] 调度保质期通知失败: $e');
    }
  }

  /// 取消指定物品的保质期提醒
  Future<void> cancelShelfLifeReminder(String itemId) async {
    if (!_platformSupported) return;
    try {
      await _plugin.cancel(id: itemId.hashCode ^ _shelfLifeIdMask);
    } catch (e) {
      debugPrint('[NotificationService] 取消保质期通知失败: $e');
    }
  }

  /// 批量为多个物品调度提醒（用于初始化或备份恢复后重新调度）
  ///
  /// 同时检查全局开关与物品级提醒开关（warrantyReminderOn / shelfLifeReminderOn），
  /// 信息已设置但未开启提醒的物品不会被调度。
  Future<void> scheduleAllReminders(List<Item> items) async {
    if (!_platformSupported) return;
    for (final item in items) {
      if (_warrantyEnabled &&
          item.warrantyReminderOn &&
          item.isUnderWarranty &&
          !item.isWarrantyExpired) {
        await scheduleWarrantyReminder(item);
      }
      if (_shelfLifeEnabled &&
          item.shelfLifeReminderOn &&
          item.hasShelfLife &&
          !item.isShelfLifeExpired) {
        await scheduleShelfLifeReminder(item);
      }
    }
  }

  /// 重新调度所有物品的**保修**提醒（设置变更后调用，实时生效）。
  ///
  /// 先逐个取消既有保修提醒，再按当前 [_warrantyEnabled] / [_warrantyReminderDays]
  /// 重新调度。开关关闭时仅取消不重排 —— 天然支持「关开关即清通知」。
  /// 仅调度信息已设置且物品级提醒开关（warrantyReminderOn）为开启的物品。
  /// 若新阈值下提醒 08:00 已过，对应物品不会重新调度（跳过）。
  Future<void> rescheduleAllWarrantyReminders(List<Item> items) async {
    if (!_platformSupported) return;
    for (final item in items) {
      await cancelWarrantyReminder(item.id);
    }
    if (!_warrantyEnabled) return;
    for (final item in items) {
      if (item.warrantyReminderOn &&
          item.isUnderWarranty &&
          !item.isWarrantyExpired) {
        await scheduleWarrantyReminder(item);
      }
    }
  }

  /// 重新调度所有物品的**保质期**提醒（设置变更后调用，实时生效）。
  ///
  /// 先逐个取消既有保质期提醒，再按当前 [_shelfLifeEnabled] / [_shelfLifeReminderDays]
  /// 重新调度。开关关闭时仅取消不重排。
  /// 仅调度信息已设置且物品级提醒开关（shelfLifeReminderOn）为开启的物品。
  Future<void> rescheduleAllShelfLifeReminders(List<Item> items) async {
    if (!_platformSupported) return;
    for (final item in items) {
      await cancelShelfLifeReminder(item.id);
    }
    if (!_shelfLifeEnabled) return;
    for (final item in items) {
      if (item.shelfLifeReminderOn &&
          item.hasShelfLife &&
          !item.isShelfLifeExpired) {
        await scheduleShelfLifeReminder(item);
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
        body: '通知功能正常运行，到期提醒已开启',
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'warranty_reminder',
            '保修到期提醒',
            channelDescription: '物品保修即将到期时推送通知提醒',
            importance: Importance.high,
            priority: Priority.high,
            largeIcon: DrawableResourceAndroidBitmap('@mipmap/launcher_icon'),
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
