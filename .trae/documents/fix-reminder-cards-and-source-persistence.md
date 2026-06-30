# 修复智能提醒卡片显示与物品来源持久化

## 摘要

详情页的 4 个显示问题根因一致：表单收集的 5 项数据（`source`、`warrantyReminderOn`、`shelfLifeReminderOn`、`maintenanceReminderOn`、`maintenanceCycle`）**从未持久化**到 Item 模型或数据库。详情页改用启发式判断（`warrantyDays != 365`）而非用户开关状态来决定卡片显示，导致默认 1 年保修无法显示卡片；保养提醒无任何持久化字段；来源字段在模型中不存在。

本计划新增 5 个持久化字段，执行数据库迁移 v3→v4，并更新表单保存/回填逻辑与详情页渲染逻辑。

## 当前状态分析

### 问题 1：保修/保质提醒卡片不显示
- `item_detail_page.dart:144` 使用 `item.hasWarranty` 判断
- `item.dart:92` 定义 `hasWarranty => warrantyDays > 0 && warrantyDays != 365`
- 当用户开启保修提醒并使用默认 1 年（购买日+365 天）时，`warrantyDays` 计算为 365 → `hasWarranty=false` → 卡片隐藏
- 保质期同理：`_expiryOn` 开关未持久化，详情页只能用 `shelfLifeDays > 0` 启发式判断

### 问题 2：保养提醒卡片不显示
- `add_item_page.dart:1579-1607` 有 `_maintainOn`/`_maintainCycle` 表单状态与 UI
- 但 `_saveItem`（行 703、756）构造 Item 时**未传递**这两个字段
- Item 模型与 items 表均无对应列
- 详情页 `_buildCountdownSection` 也无保养卡片构建逻辑

### 问题 3：编辑物品时三个智能提醒不显示
- `add_item_page.dart:185` `_prefillFromItem` 仅还原保修/保质天数，未还原：
  - `_expiryOn`（保质期开关）— 用 `shelfLifeDays > 0` 启发式判断，与详情页不一致
  - `_warrantyOn` — 用 `warrantyDays > 0 && warrantyDays != 365` 启发式，默认 1 年时为 false
  - `_maintainOn`、`_maintainCycle` — 完全未还原
  - `_selectedSource` — 完全未还原

### 问题 4：物品来源不显示
- `add_item_page.dart:1344-1383` 有来源选择 UI（`sourceOptions` 来自 `template.dart:455`）
- 但 `_selectedSource` 状态从未持久化，Item 模型与表均无 `source` 字段
- 详情页 `_buildInfoSection`（`item_detail_page.dart:309`）GridView 仅 4 个 cell（分类/收纳位置/购买日期/价格），无来源

## 实施步骤

### 步骤 1：扩展 Item 模型（`lib/models/item.dart`）

新增 5 个字段到 `Item` 工厂构造函数与 `Item.create`：

```dart
@Default('线下购买') String source,
@Default(false) bool warrantyReminderOn,
@Default(false) bool shelfLifeReminderOn,
@Default(false) bool maintenanceReminderOn,
@Default('每半年') String maintenanceCycle,
```

**修改 `hasWarranty` 定义**（行 92）：
```dart
/// 保修期是否被显式设置：以用户开关为准（持久化字段）。
bool get hasWarranty => warrantyReminderOn;
```

**新增保养周期派生属性**（在文件末尾）：
```dart
// ─── 定期保养（maintenance）派生属性 ────────────────────
int get _maintenanceCycleDays {
  switch (maintenanceCycle) {
    case '每月': return 30;
    case '每季度': return 90;
    case '每半年': return 180;
    case '每年': return 365;
    default: return 180;
  }
}

/// 下次保养剩余天数：以购买日为周期起点，按 cycleDays 取模计算。
/// - elapsed=0（购买当天）→ 返回完整周期天数
/// - intoCycle=0 且 elapsed>0（恰逢保养日）→ 返回 0
/// - 其余 → cycleDays - intoCycle
int get daysUntilNextMaintenance {
  final cycleDays = _maintenanceCycleDays;
  final now = DateTime.now();
  final today = DateTime.utc(now.year, now.month, now.day);
  final purchase = DateTime.utc(purchaseDate.year, purchaseDate.month, purchaseDate.day);
  final elapsed = today.difference(purchase).inDays;
  if (elapsed <= 0) return cycleDays;
  final intoCycle = elapsed % cycleDays;
  if (intoCycle == 0) return 0;
  return cycleDays - intoCycle;
}

/// 下次保养日期（用于详情弹窗展示）
DateTime get nextMaintenanceDate {
  final cycleDays = _maintenanceCycleDays;
  final now = DateTime.now();
  final today = DateTime.utc(now.year, now.month, now.day);
  final purchase = DateTime.utc(purchaseDate.year, purchaseDate.month, purchaseDate.day);
  final elapsed = today.difference(purchase).inDays;
  if (elapsed <= 0) return purchaseDate.add(Duration(days: cycleDays));
  final intoCycle = elapsed % cycleDays;
  final daysToNext = intoCycle == 0 ? 0 : (cycleDays - intoCycle);
  return purchaseDate.add(Duration(days: elapsed + daysToNext));
}

bool get isMaintenanceDueSoon => maintenanceReminderOn && daysUntilNextMaintenance <= 7;
```

### 步骤 2：扩展数据库表（`lib/database/tables/items_table.dart`）

在 `templateData` 列后新增 5 列：
```dart
// 物品来源
TextColumn get source => text().withDefault(const Constant('线下购买'))();
// 三个智能提醒开关
BoolColumn get warrantyReminderOn => boolean().withDefault(const Constant(false))();
BoolColumn get shelfLifeReminderOn => boolean().withDefault(const Constant(false))();
BoolColumn get maintenanceReminderOn => boolean().withDefault(const Constant(false))();
// 保养周期（每月/每季度/每半年/每年）
TextColumn get maintenanceCycle => text().withDefault(const Constant('每半年'))();
```

### 步骤 3：数据库迁移 v3→v4（`lib/database/database.dart`）

```dart
@override
int get schemaVersion => 4;

@override
MigrationStrategy get migration => MigrationStrategy(
  onCreate: (Migrator m) async {
    await m.createAll();
  },
  onUpgrade: (Migrator m, int from, int to) async {
    if (from < 2) {
      await m.addColumn(cabinets, cabinets.photoPath);
    }
    if (from < 3) {
      await m.addColumn(items, items.shelfLifeDays);
    }
    if (from < 4) {
      await m.addColumn(items, items.source);
      await m.addColumn(items, items.warrantyReminderOn);
      await m.addColumn(items, items.shelfLifeReminderOn);
      await m.addColumn(items, items.maintenanceReminderOn);
      await m.addColumn(items, items.maintenanceCycle);
      // 回填：用旧启发式为已存在物品推导开关状态
      await customStatement(
        'UPDATE items SET '
        "warrantyReminderOn = (warrantyDays > 0 AND warrantyDays != 365), "
        "shelfLifeReminderOn = (shelfLifeDays > 0) "
        "WHERE warrantyReminderOn = 0",
      );
    }
  },
  beforeOpen: (details) async {
    if (details.wasCreated) {
      await _seedDefaultData();
    }
  },
);
```

### 步骤 4：重新生成 freezed + drift 代码

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 步骤 5：更新 Provider 映射（`lib/providers/item_providers.dart`）

**`toModel`（行 88）** 增加 5 字段映射：
```dart
source: row.source,
warrantyReminderOn: row.warrantyReminderOn,
shelfLifeReminderOn: row.shelfLifeReminderOn,
maintenanceReminderOn: row.maintenanceReminderOn,
maintenanceCycle: row.maintenanceCycle,
```

**`_toCompanion`（行 110）** 增加 5 字段映射：
```dart
source: Value(item.source),
warrantyReminderOn: Value(item.warrantyReminderOn),
shelfLifeReminderOn: Value(item.shelfLifeReminderOn),
maintenanceReminderOn: Value(item.maintenanceReminderOn),
maintenanceCycle: Value(item.maintenanceCycle),
```

### 步骤 6：更新 WebDAV 恢复逻辑（`lib/services/webdav_service.dart`）

在 `ItemsCompanion.insert`（行 307-326）增加 5 字段：
```dart
source: Value(j['source'] as String? ?? '线下购买'),
warrantyReminderOn: Value(j['warrantyReminderOn'] as bool? ?? false),
shelfLifeReminderOn: Value(j['shelfLifeReminderOn'] as bool? ?? false),
maintenanceReminderOn: Value(j['maintenanceReminderOn'] as bool? ?? false),
maintenanceCycle: Value(j['maintenanceCycle'] as String? ?? '每半年'),
```

导出（行 110 `e.toJson()`）自动包含新列，无需修改。

### 步骤 7：更新表单保存（`lib/screen/add_item_page.dart` `_saveItem`）

**编辑模式（行 703）Item 构造**增加 5 字段：
```dart
source: _selectedSource,
warrantyReminderOn: _warrantyOn,
shelfLifeReminderOn: _expiryOn,
maintenanceReminderOn: _maintainOn,
maintenanceCycle: _maintainCycle,
```

**新增模式（行 756）Item.create 构造**增加相同 5 字段。

### 步骤 8：更新表单回填（`lib/screen/add_item_page.dart` `_prefillFromItem`）

替换行 215-226 的启发式还原逻辑：
```dart
// 还原保质期信息
_shelfLifeDays = item.shelfLifeDays;
_shelfLifeController.text = item.shelfLifeDays.toString();
_expiryOn = item.shelfLifeReminderOn;

// 还原保修信息（以持久化开关为准）
_warrantyOn = item.warrantyReminderOn;
if (_warrantyOn) {
  final warrantyEnd = item.warrantyEndDate;
  _warrantyDate = warrantyEnd;
  _warrantyDateController.text =
      '${warrantyEnd.year}-${warrantyEnd.month.toString().padLeft(2, '0')}-${warrantyEnd.day.toString().padLeft(2, '0')}';
}

// 还原保养提醒
_maintainOn = item.maintenanceReminderOn;
_maintainCycle = item.maintenanceCycle;

// 还原物品来源
_selectedSource = item.source;
```

### 步骤 9：更新详情页卡片渲染（`lib/screen/item_detail_page.dart`）

**修改 `_buildCountdownSection`（行 141-177）** — 改用开关判断 + 支持 3 卡片 Wrap 布局：
```dart
Widget _buildCountdownSection(BuildContext context, Item item) {
  final cards = <Widget>[];
  if (item.warrantyReminderOn) {
    cards.add(_buildWarrantyCard(context, item));
  }
  if (item.shelfLifeReminderOn && item.hasShelfLife) {
    cards.add(_buildShelfLifeCard(context, item));
  }
  if (item.maintenanceReminderOn) {
    cards.add(_buildMaintenanceCard(context, item));
  }

  if (cards.isEmpty) return const SizedBox.shrink();

  // 统一使用半宽 Wrap：1 卡片居中靠左、2 卡片并排、3 卡片 2+1 换行
  return LayoutBuilder(
    builder: (context, constraints) {
      final cardWidth =
          (constraints.maxWidth - AppDimensions.spacingMedium) / 2;
      return Wrap(
        spacing: AppDimensions.spacingMedium,
        runSpacing: AppDimensions.spacingMedium,
        alignment: WrapAlignment.start,
        children: cards
            .map((c) => SizedBox(width: cardWidth, child: c))
            .toList(),
      );
    },
  );
}
```

**新增 `_buildMaintenanceCard`**（紧随 `_buildShelfLifeCard` 之后）：
```dart
Widget _buildMaintenanceCard(BuildContext context, Item item) {
  final remaining = item.daysUntilNextMaintenance;
  return CountdownCard(
    icon: '🔧',
    label: '保养',
    value: _formatMaintenanceValue(remaining),
    date: _formatMaintenanceDate(remaining),
    status: _resolveMaintenanceStatus(remaining),
    onTap: () => _showMaintenanceDetail(
      context,
      item: item,
      remainingDays: remaining,
    ),
  );
}

static String _formatMaintenanceValue(int remaining) => '$remaining';
static String _formatMaintenanceDate(int remaining) =>
    remaining == 0 ? '今日保养' : '剩余天数';
static CountdownStatus _resolveMaintenanceStatus(int remaining) {
  if (remaining == 0) return CountdownStatus.expiringSoon;
  if (remaining <= 7) return CountdownStatus.expiringSoon;
  return CountdownStatus.normal;
}
```

**新增 `_showMaintenanceDetail`**（紧随 `_showExpiryDetail` 之后）— 复用 `_showExpiryDetail` 的弹窗风格，但展示周期与下次保养日：
```dart
void _showMaintenanceDetail(
  BuildContext context, {
  required Item item,
  required int remainingDays,
}) {
  final isDueToday = remainingDays == 0;
  final isDueSoon = !isDueToday && remainingDays <= 7;

  String fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String statusText;
  Color statusColor;
  if (isDueToday) {
    statusText = '今日需保养';
    statusColor = AppColors.warning;
  } else if (isDueSoon) {
    statusText = '即将保养 · 剩余 $remainingDays 天';
    statusColor = AppColors.warning;
  } else {
    statusText = '有效 · 剩余 $remainingDays 天';
    statusColor = AppColors.success;
  }

  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Row(
        children: [
          EmojiText(emoji: '🔧', fontSize: 22),
          const SizedBox(width: 8),
          Text('保养信息', style: AppTextStyles.titleMedium),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('保养周期：${item.maintenanceCycle}', style: AppTextStyles.bodyMedium),
          const SizedBox(height: AppDimensions.spacingSmall),
          Text('下次保养：${fmt(item.nextMaintenanceDate)}', style: AppTextStyles.bodyMedium),
          const SizedBox(height: AppDimensions.spacingMedium),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSmall),
            ),
            child: Text(
              statusText,
              style: AppTextStyles.colored(
                color: statusColor,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('知道了'),
        ),
      ],
    ),
  );
}
```

### 步骤 10：详情页新增物品来源 InfoCell（`lib/screen/item_detail_page.dart` `_buildInfoSection`）

在 GridView.count 的 children 列表（行 323-339）末尾追加：
```dart
InfoCell(label: '来源', value: item.source),
```

最终 GridView 含 5 个 cell（分类/收纳位置/购买日期/价格/来源），3 行布局（2+2+1）。

### 步骤 11：更新测试（`test/models/item_test.dart`）

重写 Task 1 中基于 365-启发式的 3 个 `hasWarranty` 测试，改用 `warrantyReminderOn`：
```dart
test('hasWarranty is true when warrantyReminderOn is true', () {
  final item = Item.create(name: 'x', price: 1, warrantyReminderOn: true);
  expect(item.hasWarranty, isTrue);
});

test('hasWarranty is false when warrantyReminderOn is false', () {
  final item = Item.create(name: 'x', price: 1, warrantyReminderOn: false);
  expect(item.hasWarranty, isFalse);
});
```

新增保养周期计算测试（覆盖 elapsed=0、intoCycle=0 且 elapsed>0、常规三种情况）。

### 步骤 12：验证

```bash
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
```

手动验证：
1. 新建物品 → 开启保修提醒（默认 1 年）→ 保存 → 详情页应显示保修卡片
2. 新建物品 → 开启保质期提醒 + 填天数 → 保存 → 详情页应显示保质卡片
3. 新建物品 → 开启保养提醒 + 选周期 → 保存 → 详情页应显示保养卡片
4. 同时开启三个提醒 → 详情页应显示 3 张卡片（2+1 换行布局）
5. 编辑已保存物品 → 三个提醒开关状态应正确还原
6. 编辑已保存物品 → 来源选择应正确还原
7. 详情页应显示"来源"InfoCell
8. 旧数据库升级到 v4 → 已有物品的保修/保质开关应正确回填
9. WebDAV 备份/恢复 → 新字段应正确序列化/反序列化

## 假设与决策

1. **保养提醒仅显示卡片，不调度系统通知**：`notification_service.dart` 当前仅支持保修/保质提醒。保养通知调度作为后续工作，不在本次范围。用户问题 2 明确是"详情页面没有显示剩余保养天数卡片"，仅指卡片显示。

2. **`hasWarranty` 定义变更影响面**：全代码库仅 `item_detail_page.dart:144` 与测试文件使用 `hasWarranty` getter。`add_item_page.dart:220` 内联了 `warrantyDays > 0 && warrantyDays != 365` 启发式（将在步骤 8 中改为读取 `item.warrantyReminderOn`），不依赖 getter。变更安全。

3. **保养周期天数映射**：每月=30、每季度=90、每半年=180、每年=365。使用固定天数而非日历月差，简化计算并避免月末/闰年边界问题。这是近似值，对"剩余天数"展示足够。

4. **保养卡片状态**：`remaining==0`（今日保养）→ expiringSoon（橙色）；`remaining<=7` → expiringSoon；其余 → normal。不使用 expired 状态，因为保养周期是循环的，不存在"过期"概念。

5. **3 卡片布局选择 Wrap 而非 Row**：保持每张卡片半宽（与现有 1/2 卡片布局一致），3 张卡片自然换行为 2+1。比 Row+3 Expanded 在窄屏上更稳健。

6. **回填策略**：迁移时用旧启发式（`warrantyDays != 365`、`shelfLifeDays > 0`）为已存在物品推导开关状态，确保升级后已有物品的卡片显示行为与升级前一致（不会突然消失）。

7. **WebDAV 旧备份兼容**：恢复时新字段使用 `?? defaultValue` 兜底，旧版备份文件（无新字段）可正常恢复为默认值。

## 涉及文件清单

| 文件 | 变更类型 |
|------|---------|
| `lib/models/item.dart` | 新增 5 字段 + 修改 hasWarranty + 新增保养派生属性 |
| `lib/database/tables/items_table.dart` | 新增 5 列 |
| `lib/database/database.dart` | schemaVersion 3→4 + 迁移脚本 |
| `lib/database/generated/database.g.dart` | 自动生成（build_runner） |
| `lib/models/generated/item.freezed.dart` | 自动生成（build_runner） |
| `lib/models/generated/item.g.dart` | 自动生成（build_runner） |
| `lib/providers/item_providers.dart` | toModel + _toCompanion 增加 5 字段 |
| `lib/services/webdav_service.dart` | restore 增加 5 字段 |
| `lib/screen/add_item_page.dart` | _saveItem 传递 5 字段 + _prefillFromItem 还原 5 字段 |
| `lib/screen/item_detail_page.dart` | 卡片判断改用开关 + 新增保养卡片 + 新增来源 InfoCell |
| `test/models/item_test.dart` | 重写 hasWarranty 测试 + 新增保养测试 |
