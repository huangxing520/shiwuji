# 保修 / 保质期提醒天数独立配置

## Context

当前 `NotificationService` 用单一 `_reminderDays`（默认 7）同时驱动**保修**和**保质期**两类到期提醒，通知设置页也只有一个共享的天数卡片（标签还是「保修到期提醒」）。这导致：

- 两类提醒无法分别配置提前天数；
- 保质期没有独立的启停开关；
- 修改天数后**不会重新调度**已有物品的提醒（只有新增/编辑/恢复备份时才用新值）；
- 提醒时刻携带购买时刻的时间分量，且应用启动时未加载已保存的偏好（跨重启后回到默认 7）。

本次改造将两类提醒完全解耦：各自独立的开关 + 各自独立的天数配置 + 实时重排 + 8:00 定时 + 启动加载。

## 设计决策（已与用户确认）

1. **总开关拆分为两个独立开关**：「保修提醒」「保质期提醒」各自启停，互不影响。
2. **保质期默认 3 天**（选项固定 1 / 3 / 7）；保修保留原选项 3 / 7 / 14 / 30，默认仍 7。
3. 提醒时刻统一为**到期日往前推 N 天当天的 08:00**；若该 08:00 已过则跳过（不补提醒）。
4. `item.dart` 里 `isWarrantyExpiringSoon` / `isShelfLifeExpiringSoon` 的 `<= 7` 是**列表「即将到期」徽标阈值，属于 UI 状态展示，不属于推送提醒**，本次不动（如需联动可后续单独提）。

## 存储键（Drift `Settings` kv 表，向后兼容）

| 用途 | key 字符串 | 默认 | 说明 |
|---|---|---|---|
| 保修开关 | `notifications_enabled` | true | **复用原 key**，语义从「总开关」收窄为「保修开关」 |
| 保修天数 | `reminder_days` | 7 | **复用原 key** |
| 保质期开关 | `shelf_life_notifications_enabled` | true | 新增 |
| 保质期天数 | `shelf_life_reminder_days` | 3 | 新增 |

复用旧 key 保证现有用户升级后保修偏好不丢失；保质期默认 true 与「原总开关开 → 保质期即开」的历史行为一致。

## 改动文件

### 1. `lib/services/notification_service.dart`（核心）

- 常量区：保留 `keyNotificationsEnabled='notifications_enabled'`、`keyReminderDays='reminder_days'`；新增 `keyShelfLifeEnabled='shelf_life_notifications_enabled'`、`keyShelfLifeReminderDays='shelf_life_reminder_days'`。
- 内存字段：把 `_enabled`/`_reminderDays` 拆为 `_warrantyEnabled`(true)/`_warrantyReminderDays`(7) 与 `_shelfLifeEnabled`(true)/`_shelfLifeReminderDays`(3)。
- 公开 getter：`isWarrantyEnabled`、`warrantyReminderDays`、`isShelfLifeEnabled`、`shelfLifeReminderDays`（移除旧 `isEnabled`/`reminderDays`，仅两处外部引用都会同步改）。
- `loadPreferences(getValue)`：一次读全 4 个 key。
- `savePreferences(setValue, {warrantyEnabled, warrantyReminderDays, shelfLifeEnabled, shelfLifeReminderDays})`：按非 null 字段写入。
- 新增私有助手：
  ```dart
  DateTime? _reminderAt8am(DateTime endDate, int days) {
    final end = DateTime(endDate.year, endDate.month, endDate.day);
    final at8 = DateTime(end.year, end.month, end.day, 8).subtract(Duration(days: days));
    return at8.isBefore(DateTime.now()) ? null : at8;
  }
  ```
- `scheduleWarrantyReminder`：门控改 `_warrantyEnabled`，用 `_warrantyReminderDays` + `_reminderAt8am`，null 则跳过（取消仍先执行）。`scheduledDate` 用 `tz.TZDateTime.from(at8, tz.local)`。
- `scheduleShelfLifeReminder`：门控改 `_shelfLifeEnabled`，用 `_shelfLifeReminderDays` + `_reminderAt8am`，id 掩码沿用 `_shelfLifeIdMask`。
- `scheduleAllReminders(items)`：保修分支门控 `_warrantyEnabled`、保质期分支门控 `_shelfLifeEnabled`。
- 新增两个重排方法（设置变更后实时生效）：
  ```dart
  Future<void> rescheduleAllWarrantyReminders(List<Item> items);   // 先逐个 cancel，再按开关/天数重排
  Future<void> rescheduleAllShelfLifeReminders(List<Item> items);
  ```
  每个：先 `cancelXxxReminder(item.id)` 全部，再若开关开则对合格物品 `scheduleXxxReminder`（内部 cancel 无害）。开关关时只取消不重排——天然支持「关开关即清通知」。
- `sendTestNotification` / `cancelAll` 保持不变。

### 2. `lib/screen/me/notification_settings_page.dart`（UI 重构）

- 状态字段：`_warrantyEnabled`/`_warrantyReminderDays`/`_shelfLifeEnabled`/`_shelfLifeReminderDays`，`_loaded`。
- 常量：`_warrantyDayOptions=[3,7,14,30]`、`_shelfLifeDayOptions=[1,3,7]`。
- `_loadPreferences`：读 4 个值。
- 四个保存方法，每个保存后调用对应 `rescheduleAllXxxReminders(items)`，items 通过 `ref.read(itemDaoProvider).getAllItems()` + `Items.toModel` 取（与 `data_backup_page._recreateReminders` 同模式）。
- UI：两张**独立卡片**，每张内部含「开关行 + 天数选择」：
  - `_buildWarrantyCard()`：图标 `verified`/`shield`，标题「保修提醒」，副标题「到期前 N 天推送通知」；下方「提醒时间」+「在保修到期前几天提醒你」+ `[3,7,14,30]` chips（开关关时禁用）。
  - `_buildShelfLifeCard()`：图标 `inventory_2`/`timer`，标题「保质期提醒」，副标题同构；下方「在保质期到期前几天提醒你」+ `[1,3,7]` chips（开关关时禁用）。
  - 抽取共享 `_buildDayChips({options, selected, enabled, onTap})` 复用选中态样式（选中：`#FFF3CC` 底 + primary 边框 + primaryDark 文字；未选：background 底 + border），保证单选交互与视觉反馈一致。
- `_buildInfoCard`：文案改为同时说明两类提醒，分别带当前天数。
- `_buildTestButton`：门控改为 `_warrantyEnabled || _shelfLifeEnabled`。
- ListView 顺序：`warrantyCard → 16 → shelfLifeCard → 16 → infoCard → 16 → testButton`。

### 3. `lib/screen/add_item_page.dart`（联动展示）

- **行 1451**：`'过期前${NotificationService().reminderDays}天推送通知'` → 改用 `shelfLifeReminderDays`（保质期文案应读保质期天数）。
- 检查保修区是否有同类展示文案，若有同样改用 `warrantyReminderDays`（实施时 grep 确认）。
- 新增/编辑物品时的 `scheduleWarrantyReminder` / `scheduleShelfLifeReminder` 调用**无需改**——服务内部已按新开关/天数门控。

### 4. `lib/main.dart`（启动加载，满足需求 #5）

- `MyApp` 由 `StatelessWidget` 改为 `ConsumerStatefulWidget`。
- `initState` 里 `addPostFrameCallback`：`ref.read(settingsDaoProvider)` → `NotificationService().loadPreferences((k) => dao.getValue(k))`，失败仅 debugPrint。
- 需新增 import：`flutter_riverpod`（已有）、`providers/database_provider.dart`。
- `_router` 字段保留在 State 里。

### 5. `lib/screen/me/data_backup_page.dart`（无需改，已兼容）

`_recreateReminders` 调 `loadPreferences`（现读 4 键）→ `cancelAll` → `scheduleAllReminders`（按各类型开关/天数调度）。逻辑自动正确，不动代码。

## 不改动 / 明确排除

- `lib/models/item.dart` 的 `<= 7` 徽标阈值（UI 状态，非推送提醒）。
- `lib/database/tables/settings_table.dart`、`settings_dao.dart`（kv 表已够用，无需 schema 迁移）。

## 验证

1. `flutter analyze` 无报错。
2. `flutter run` 真机/模拟器：
   - 进入「我的 → 通知设置」，看到两张独立卡片，各自开关 + 天数 chips。
   - 关闭「保修提醒」→ 既有保修通知被取消（通知栏无残留），保质期通知不受影响；反之亦然。
   - 把保修天数从 7 改 30、保质期从 3 改 1 → 各自卡片选中态切换；构造一个到期日在新阈值内的物品，确认重新调度日志（`[NotificationService] 已调度...`）出现且时刻为 08:00。
   - 构造一个「新阈值下提醒 08:00 已过」的物品 → 日志显示「提醒日期已过，跳过」，无通知。
   - 新增/编辑物品开启保质期提醒 → 文案显示「过期前 3 天推送通知」（默认值），与设置一致。
   - 杀进程重启应用 → 设置页显示上次保存的值（启动加载生效）。
3. 备份恢复：恢复后 `_recreateReminders` 仍能重建两类提醒（日志正常）。
