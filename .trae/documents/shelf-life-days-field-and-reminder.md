# 保质期天数字段 & 保质期提醒联动 — 实施计划

## Context（背景）

新增物品表单中，「保质期提醒」开关目前是**纯装饰性**的：它带有下方一个「过期日期」日期选择器，但 `_expiryOn` / `_expiryDate` 从不写入 `Item`、编辑模式不还原、也不调度任何通知。本次改造将「保质期」提升为真实的一等概念：

1. 在新增物品界面加入「保质期天数」输入框（按天，默认 0，非必填）。
2. 移除保质期开关下方的「过期日期」选择器，保留上方的「保质期提醒」文字 + 开关。
3. 实现文字与开关的**联动**：保质期天数为 0 时开关禁用并强制关闭；>0 时开关可用，描述文案随状态同步变化。
4. 全面贯通数据层（模型 / DB / DAO / Provider / 备份恢复 / 通知 / 测试），保持一致性。

经用户确认采用：**新增持久化字段 + 功能化提醒（调度本地通知）**；联动方式为**按天数门控开关**。

---

## 关键文件与改动

### A. 数据层

**1. `lib/models/item.dart`**（freezed 模型）
- 工厂构造新增字段：`@Default(0) int shelfLifeDays`（紧随 `warrantyDays`）。
- `Item.create` 新增形参 `int shelfLifeDays = 0`，并在返回 `Item(...)` 时传入。
- 新增派生 getter（镜像 warranty，但用 `shelfLifeDays > 0` 守卫，0 表示未设置）：
  - `bool get hasShelfLife => shelfLifeDays > 0;`
  - `DateTime get shelfLifeEndDate => purchaseDate.add(Duration(days: shelfLifeDays));`
  - `int get daysUntilShelfLifeExpiry => shelfLifeEndDate.difference(DateTime.now()).inDays;`
  - `bool get isShelfLifeExpired => hasShelfLife && daysUntilShelfLifeExpiry < 0;`
  - `bool get isShelfLifeExpiringSoon => hasShelfLife && !isShelfLifeExpired && daysUntilShelfLifeExpiry <= 7;`

**2. `lib/database/tables/items_table.dart`**
- 新增列：`IntColumn get shelfLifeDays => integer().withDefault(const Constant(0))();`

**3. `lib/database/database.dart`**
- `schemaVersion` 由 `2` → `3`。
- `onUpgrade` 新增分支：`if (from < 3) { await m.addColumn(items, items.shelfLifeDays); }`

**4. `lib/providers/item_providers.dart`**
- `toModel`：增 `shelfLifeDays: row.shelfLifeDays,`
- `_toCompanion`：增 `shelfLifeDays: Value(item.shelfLifeDays),`

**5. `lib/services/webdav_service.dart`**（恢复侧，约 L315）
- 增 `shelfLifeDays: Value(j['shelfLifeDays'] as int? ?? 0),`
- 导出侧已由 freezed 的 `toJson()` 自动覆盖，无需改动。

### B. 通知层

**6. `lib/services/notification_service.dart`**
- 新增 `scheduleShelfLifeReminder(Item item)`：镜像 `scheduleWarrantyReminder`，但：
  - 守卫：`if (item.shelfLifeDays <= 0) return;`
  - 基于 `item.shelfLifeEndDate` 减去全局 `_reminderDays` 计算提醒日，已过则跳过。
  - 通知 id 用 `item.id.hashCode ^ 0x5F4C0000`（避免与保修的 `item.id.hashCode` 冲突）。
  - 频道 `shelf_life_reminder`，标题「保质期即将到期」，正文「「{name}」保质期将于 {M}月{D}日 到期」。
- 新增 `cancelShelfLifeReminder(String itemId)`：取消上述 id。
- `scheduleAllReminders` 增补：对 `item.shelfLifeDays > 0 && !item.isShelfLifeExpired` 的物品也调度保质期提醒。
- 全局 `_enabled` / `_reminderDays` 复用，无需改 `notification_settings_page.dart`。

### C. 表单层

**7. `lib/screen/add_item_page.dart`**
- **状态字段**：删除 `_expiryDate` / `_expiryDateController`（过期日期选择器已移除）；新增 `int _shelfLifeDays = 0;` 与 `final _shelfLifeController = TextEditingController();`
- `initState`：`_shelfLifeController.text = '0';` 并加监听器——解析 int（`int.tryParse ?? 0`，负值钳为 0），更新 `_shelfLifeDays`；若为 0 则强制 `_expiryOn = false`；`setState`。
- `dispose`：`_shelfLifeController.dispose();`（移除原 `_expiryDateController.dispose()`）。
- `_prefillFromItem`：还原 `_shelfLifeDays = item.shelfLifeDays;`、`_shelfLifeController.text = ...;`、`_expiryOn = item.shelfLifeDays > 0;`
- **`_buildReminderSection`**：
  - 在「保质期提醒」行**之上**新增「保质期天数」输入：`_buildLabel('保质期天数')` + `_buildInput(controller: _shelfLifeController, keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly], placeholder: '0', suffix: '天' 文本)`。
  - 移除原「过期日期」`AnimatedSwitcher` 块（L1423–1464）。
  - 「保质期提醒」行描述 `desc` 改为动态计算：
    - `_shelfLifeDays <= 0` → `'请先填写保质期天数'`，开关禁用、强制关。
    - `_shelfLifeDays > 0 && !_expiryOn` → `'未开启提醒'`。
    - `_expiryOn` → `'过期前${NotificationService().reminderDays}天推送通知'`（原激活文案）。
  - 给 `_buildReminderRow` 增 `bool enabled = true` 形参：禁用时 `onTap` 置空、开关底色用 `AppColors.border`、整体透明度降低，实现「按天数门控」联动。
  - 「保修到期提醒」「定期保养提醒」两行保持不变。
- **`_saveItem`**：解析 `shelfLifeDays`（`int.tryParse(_shelfLifeController.text.trim()) ?? 0`，钳 ≥0）；分别传入编辑态 `Item(...)` 与新增态 `Item.create(...)`；保存后 `if (_expiryOn && _shelfLifeDays > 0) scheduleShelfLifeReminder(item); else cancelShelfLifeReminder(item.id);`
- **`_resetForm`**：`_shelfLifeDays = 0; _shelfLifeController.text = '0'; _expiryOn = false;`（移除 `_expiryDate`/`_expiryDateController` 相关清理）。

### D. 代码生成

**8. 运行 build_runner** 重新生成 freezed / drift / riverpod 产物：
- `lib/models/generated/item.freezed.dart`、`item.g.dart`
- `lib/database/generated/database.g.dart`
- `lib/providers/generated/item_providers.g.dart`

命令：`dart run build_runner build --delete-conflicting-outputs`

### E. 测试

**9. `test/models/item_test.dart`**
- `Item.create uses default values` 增断言 `expect(item.shelfLifeDays, 0);`
- 新增用例：`shelfLifeDays` 默认 0、`hasShelfLife` 在 0 时为 false / >0 时为 true、`shelfLifeEndDate = purchaseDate + shelfLifeDays`、`isShelfLifeExpired` / `isShelfLifeExpiringSoon` 边界。

---

## 不在本次范围（避免过度扩张）

- `item_detail_page.dart` 的「质保 / 维护」倒计时卡片属保修概念，无保质期展示，无需改动。
- `notification_settings_page.dart` 全局开关与 `_reminderDays` 复用，无需新增 UI。
- 首页/物品库的「即将到期 / 过保 / 在保」统计仍基于 warranty，不调整口径（保质期是独立的物品属性，不影响既有筛选语义）。

---

## 验证方式

1. **静态检查**：`flutter analyze` 无报错。
2. **单测**：`flutter test` 全绿，包含新增 shelfLifeDays 用例。
3. **手动端到端**：
   - 新增物品：保质期天数输入 0 → 开关禁用、文案「请先填写保质期天数」；输入 180 → 开关可用，开启后文案切换为「过期前 N 天推送通知」；保存。
   - 编辑该物品：天数与开关状态正确还原。
   - 清空天数为 0 → 开关自动关闭、文案回退。
   - 保存后查 `NotificationService` debug 日志确认 `scheduleShelfLifeReminder` 已调度（id 与保修不冲突）。
   - 卸载重装 / 老数据库升级到 schema 3：`shelf_life_days` 列存在、旧数据默认 0、应用不崩溃。
   - WebDAV 备份后恢复：`shelfLifeDays` 正确往返。
