# 物品「借出 / 收回」功能实现计划

## Context（背景）

当前物品系统记录保修、保质期、保养、收纳位置等信息，但没有「借出状态」概念。用户希望：

1. 在物品详情页底部增加「借出 / 收回」按钮，状态与物品实时同步；
2. 在数据模型、数据库表、API/序列化全链路新增 `isBorrowed` 布尔属性，确保创建/更新/查询/备份恢复均正确持久化；
3. 详情页「来源」旁以标签形式展示借出状态（已借出 / 可借出）；
4. 物品库页增加两个筛选：按借出状态筛选（全部 / 已借出 / 可借出）、按购买时间区间筛选（起止日期选择器）。

目标是在不破坏现有架构（freezed + drift + riverpod + FilterPanel 底部弹窗）的前提下，以与现有「保修/保养」字段一致的风格完成扩展。

---

## 实现步骤

### 1. 数据模型 — [item.dart](file:///c:/Users/bron1117/flutter/wupin/lib/models/item.dart)

在 `Item` freezed 工厂与 `Item.create` 中新增字段（紧跟 `maintenanceCycle` 之后，保持字段顺序与表结构对齐）：

```dart
@Default(false) bool isBorrowed,   // freezed 主工厂
bool isBorrowed = false,           // Item.create
```

无需派生属性（布尔本身就是终态）。`copyWith` / `fromJson` / `toJson` 由 freezed + json_serializable 代码生成自动支持。

### 2. 数据库表 — [items_table.dart](file:///c:/Users/bron1117/flutter/wupin/lib/database/tables/items_table.dart)

新增列（与 `maintenanceCycle` 风格一致）：

```dart
// 是否已借出（false = 在家可借出，true = 已借出）
BoolColumn get isBorrowed => boolean().withDefault(const Constant(false))();
```

### 3. 数据库迁移 — [database.dart](file:///c:/Users/bron1117/flutter/wupin/lib/database/database.dart)

- `schemaVersion` 由 `1` 升至 `2`；
- `onUpgrade` 中新增增量迁移（使用 drift 原生 `m.addColumn`，自带默认值，安全幂等）：

```dart
onUpgrade: (Migrator m, int from, int to) async {
  if (from < 2) {
    // v2: 新增「是否借出」字段（is_borrowed，布尔，默认 false）
    await m.addColumn(items, items.isBorrowed);
  }
},
```

> 符合项目记忆约束：drift onUpgrade 非事务、DDL 自动提交；addColumn 是单条 DDL，无部分迁移风险。

### 4. Provider 全链路 — [item_providers.dart](file:///c:/Users/bron1117/flutter/wupin/lib/providers/item_providers.dart)

- `Items.toModel`：增加 `isBorrowed: row.isBorrowed`；
- `Items._toCompanion`：增加 `isBorrowed: Value(item.isBorrowed)`；
- 新增便捷方法 `toggleBorrowed(Item item)`：调用 `updateItem(item.copyWith(isBorrowed: !item.isBorrowed))`，复用现有全量更新 + `ref.invalidateSelf()`，详情页与物品库均通过 `ref.watch(itemsProvider)` 自动重建。

### 5. WebDAV 备份恢复 — [webdav_service.dart](file:///c:/Users/bron1117/flutter/wupin/lib/services/webdav_service.dart)

- 备份：`e.toJson()` 自动包含 `isBorrowed`（freezed 生成），无需改动；
- 恢复：在 `ItemsCompanion.insert(...)`（约 381 行）末尾新增：
  ```dart
  isBorrowed: Value(_optBool(j, 'isBorrowed', false)),
  ```
  确保恢复后借出状态不丢失。旧备份无此字段时 `_optBool` 回退 `false`，向后兼容。

### 6. 物品详情页 — [item_detail_page.dart](file:///c:/Users/bron1117/flutter/wupin/lib/screen/item_detail_page.dart)

**(a) 底部「借出/收回」按钮**：在 `_buildBottomActions` 上方插入全宽按钮（`_buildBorrowButton`），置于 `build` 列表中 `_buildInfoSection` 与原 `_buildBottomActions` 之间：

- `item.isBorrowed == false` → 主色填充按钮「借出」（图标 `Icons.logout`）；
- `item.isBorrowed == true` → 语义色按钮「收回」（图标 `Icons.login_back`，用 `AppColors.info` 蓝色区分）；
- 点击弹 `AlertDialog` 二次确认（「确定要借出「{name}」吗？」/「确定要收回吗？」），确认后 `ref.read(itemsProvider.notifier).toggleBorrowed(item)`，并 `ToastUtils`/`SnackBar` 反馈；
- 因页面 `ref.watch(itemByIdProvider(itemId))`，状态变更后按钮文案与样式自动同步。

**(b) 「来源」旁借出状态标签**：将详情 `_buildInfoSection` GridView 中的 `InfoCell(label: '来源', value: item.source)` 替换为自定义 `_SourceWithBorrowCell`（仿照现有 `_LocationCell` 的自定义单元格模式）：

- 上行：标签「来源」+ 值；
- 下行：值 + 间距 + 借出状态 chip（已借出 = `dangerLight`/`danger` 红；可借出 = `successLight`/`statusUsing` 绿），与现有 `_buildStatusBadge` 配色一致。

### 7. 物品库筛选 — [filter_panel.dart](file:///c:/Users/bron1117/flutter/wupin/lib/screen/inventory/filter_panel.dart) + [inventory_page.dart](file:///c:/Users/bron1117/flutter/wupin/lib/screen/inventory/inventory_page.dart)

**(a) FilterPanel 扩展**：

- `FilterApplyCallback` 签名扩展为：
  ```dart
  void Function(String? priceRange, String? location, String? status,
                String? borrowedStatus, DateTime? purchaseStart, DateTime? purchaseEnd)
  ```
- 新增初始值参数 `initialBorrowedStatus` / `initialPurchaseStart` / `initialPurchaseEnd`，`show()` 透传；
- UI 新增两节（沿用 `_buildFilterSection` chip 风格）：
  - 「借出状态」：全部 / 已借出 / 可借出；
  - 「购买时间」：两行可点（开始日期 / 结束日期），点击调用 `flutter_datetime_picker_plus` 的 `DatePicker.showDatePicker`（与 [add_item_page.dart:623](file:///c:/Users/bron1117/flutter/wupin/lib/screen/add_item_page.dart#L623) 一致），并在节内提供「清除时间」链接重置两端；边界：若用户选了开始>结束，自动交换或在确认时校验提示。

**(b) inventory_page 状态与过滤逻辑**：

- 新增字段 `String? _selectedBorrowedStatus;` `DateTime? _purchaseStart;` `DateTime? _purchaseEnd;`；
- `_resetSecondaryState()` 一并重置三者；
- `_activeFilterCount` 计入三者；
- `_filteredItems` 增加两段过滤：
  - 借出状态：`'已借出'` → `i.isBorrowed`；`'可借出'` → `!i.isBorrowed`；`'全部'`/null 跳过；
  - 购买时间：`_purchaseStart != null` → `!i.purchaseDate.isBefore(start0h)`；`_purchaseEnd != null` → `!i.purchaseDate.isAfter(endDay23h59)`（结束日含当天，按日粒度）；
- `_showFilterPanel` 透传新初始值，`onApply` 写回三字段，`onReset` 清空三字段。

**(c) 卡片借出指示（轻量增强）**：在 `_buildGridCard` / `_buildListCard` 的状态徽章区，当 `item.isBorrowed` 时额外显示一个小「已借出」红点徽标，便于筛选时一眼辨识。

### 8. 测试 — [item_test.dart](file:///c:/Users/bron1117/flutter/wupin/test/models/item_test.dart)

补充用例：
- `Item.create` 默认 `isBorrowed == false`；
- `copyWith(isBorrowed: true)` 正确切换且不影响其它字段；
- 值相等性：仅 `isBorrowed` 不同 → 不相等。

### 9. 代码生成

模型/表/DAO 改动后必须重新生成 freezed / json_serializable / drift 文件：

```
dart run build_runner build --delete-conflicting-outputs
```

> 生成的文件（`item.freezed.dart`、`item.g.dart`、`database.g.dart`、`item_dao.g.dart`、`item_providers.g.dart`）由工具产出，无需手改。

---

## 关键文件清单

| 文件 | 改动 |
|---|---|
| `lib/models/item.dart` | 新增 `isBorrowed` 字段 |
| `lib/database/tables/items_table.dart` | 新增 `isBorrowed` 列 |
| `lib/database/database.dart` | schemaVersion→2 + onUpgrade addColumn |
| `lib/providers/item_providers.dart` | toModel/_toCompanion + `toggleBorrowed` |
| `lib/services/webdav_service.dart` | 恢复 insert 增加 `isBorrowed` |
| `lib/screen/item_detail_page.dart` | 借出按钮 + 来源旁状态标签 |
| `lib/screen/inventory/filter_panel.dart` | 新增借出状态/购买时间筛选节 + 回调签名 |
| `lib/screen/inventory/inventory_page.dart` | 新增筛选状态、过滤逻辑、卡片徽标 |
| `test/models/item_test.dart` | 补充 isBorrowed 用例 |

---

## 验证方式

1. `dart run build_runner build --delete-conflicting-outputs` 成功无报错；
2. `flutter test test/models/item_test.dart` 全绿；
3. `flutter analyze` 无新增 warning；
4. 运行 App 端到端验证：
   - 首次升级：旧库迁移到 v2，现有物品 `isBorrowed` 均为 false，详情页显示「可借出」；
   - 详情页点「借出」→ 确认 → 按钮变「收回」、来源旁标签变「已借出」红色；再点「收回」还原；
   - 物品库筛选：选「已借出」仅显示已借物品；设置购买时间起止后结果准确；「重置」清空；
   - 备份→恢复：借出状态保留；旧备份恢复后默认「可借出」。
