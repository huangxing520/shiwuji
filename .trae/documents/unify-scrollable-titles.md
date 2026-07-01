# 统一标题为可滚动（与 AI 模型设置页一致）

## Context（背景）

「AI 模型设置」页（`lib/screen/me/ai_settings_page.dart`）采用的可滚动标题模式：`Scaffold`（无 `appBar`）→ `SafeArea` → `ListView`，其中 `_buildTopBar()`（返回按钮 + 标题）作为 `ListView` 的**首项**，随页面内容一起滚动，而非固定在顶部。

系统中其余多个子页面当前将标题元素**固定**在滚动区域之外（放在 `Column` 中、`Expanded(ScrollView)` 之上，或使用 `BasePage` 的 `appBar: CustomAppBar(...)`），与 AI 设置页不一致。

**目标**：将所有「返回按钮 + 标题」型子页面的标题元素改为随内容滚动，与 AI 设置页保持一致。保持各页面整体布局协调与功能完整。

## 参考模式（AI 设置页）

```
Scaffold(
  backgroundColor: AppColors.background,
  body: SafeArea(
    child: Column(children: [
      Expanded(child: ListView(
        padding: EdgeInsets.symmetric(horizontal: 20),
        children: [
          _buildTopBar(),   // ← 首项，随滚动
          ...内容,
        ],
      )),
    ]),
  ),
)
```

关键：`_buildTopBar()` 在滚动视图**内部**作为首项；滚动视图自身提供水平内边距（20），故 topBar 的水平 padding 置 0，仅保留垂直 padding。

## 已正确（无需修改）

- `lib/screen/me/ai_settings_page.dart`（参考实现）
- `lib/screen/home/home_page.dart`（`_buildHeaderContent()` 已在 `ListView` 首项）
- `lib/screen/me/me_page.dart`（`_buildPageHeader()` 已在 `ListView` 首项）
- `lib/screen/category/category_page.dart`（`_buildHeader()` 已在 `ListView` 首项）
- `lib/screen/storage/storage_page.dart`（主标签页，用户决定保持不变）
- `lib/screen/inventory/inventory_page.dart`（顶部为搜索框，非标题元素）
- `lib/screen/scan/scan_page.dart`（AppBar 已注释，相机页面）
- 各模态弹窗（`add_category_modal.dart`、`edit_profile_modal.dart` 等）— 底部弹窗的固定头部是常规模式，不在范围内

## 需修改的 6 个子页面

### 通用改法（适用于 2–6）

当前结构：`Column [ _buildTopBar(), Expanded(ScrollView([ ...内容 ])) ]`
目标结构：`Column [ Expanded(ScrollView([ _buildTopBar(), ...内容 ])) ]`

操作：
1. 将 `_buildTopBar()` 从 `Column` 直接子项移入滚动视图（`ListView`/`SingleChildScrollView`）作为**第一个 child**。
2. 由于滚动视图自身已有 `horizontal: 20` 内边距，将 `_buildTopBar()` 内 `Padding` 的水平值改为 0，仅保留垂直 padding（如 `EdgeInsets.only(top: 8, bottom: 4)`），避免双重 20px 缩进。
3. 移除/调整原先滚动视图首项的多余 `SizedBox` 顶部间距，避免标题与首块内容间距过大（保留合理间距即可）。
4. 保留各页面 `_buildTopBar()` 现有视觉风格（图标、字号、字重）不动，仅改位置。

### 1. `lib/screen/item_detail_page.dart`（特殊：使用 BasePage + CustomAppBar）

当前：`BasePage(appBar: CustomAppBar(title: '物品详情'), child: Column([...]))`
`BasePage`（`lib/widgets/base_page.dart`）将 `child` 包入 `SingleChildScrollView(padding: AppDimensions.pagePadding)`（水平 20），`appBar` 固定在 `Scaffold.appBar`。

改法：
- 移除 `appBar: CustomAppBar(title: '物品详情')` 参数。
- 移除文件顶部 `import 'package:shi_wu_ji/widgets/custom_app_bar.dart';`。
- 新增 `_buildTopBar()` 方法（返回按钮 + 「物品详情」标题），样式参考 AI 设置页 / check_update 页：`chevron_left` 图标、38×38 圆角卡片按钮（`AppColors.cardBg` + 阴影）、`fontSize: 18 / FontWeight.w900`；`onTap: () => context.pop()`（go_router 已导入）。
- 因 `BasePage` 已提供水平 20 内边距，`_buildTopBar()` 的 `Padding` 仅用垂直：`EdgeInsets.only(top: 8, bottom: 4)`。
- 在 `Column` 的 children 最前面插入 `_buildTopBar()`（位于现有 `SizedBox(height: spacingLarge)` 之前）。
- `ItemDetailPage` 是 `ConsumerWidget`，可直接添加实例方法。

### 2. `lib/screen/add_item_page.dart`

- 当前：`Stack > Column [ SizedBox(statusBar), _buildTopBar(), Expanded(SingleChildScrollView(...)) ]`（`build` 见 line 882 起；`_buildTopBar` line 936）。
- 改：将 `_buildTopBar()` 移入 `SingleChildScrollView` 的 `Column` 作为首项（在 `_buildPhotoSection()` 之前）；`_buildTopBar()` padding 由 `fromLTRB(20,8,20,4)` 改为 `only(top: 8, bottom: 4)`。
- 保留 `Stack` 外层与底部 `Positioned` 操作栏、成功弹窗等不变。

### 3. `lib/screen/me/data_backup_page.dart`

- 当前：`Stack > SafeArea > Column [ _buildTopBar(), Expanded(ListView(...)) ]`（`build` line 281；`_buildTopBar` line 396）。
- 改：将 `_buildTopBar()` 移入 `ListView` 的 children 首项（在 `_buildConfigCard()` 之前）；`_buildTopBar()` padding 由 `fromLTRB(8,8,20,8)` 改为 `only(top: 8, bottom: 8)`。
- `ListView` padding（`fromLTRB(20,12,20,40)`）保留；顶部 12 + topBar top 8 视情况微调为更紧凑（可将 ListView top 改 0，由 topBar 控制）。

### 4. `lib/screen/me/check_update_page.dart`

- 当前：`SafeArea > Column [ _buildTopBar(), Expanded(ListView([ SizedBox(24), ... ])) ]`（`build` line 222；`_buildTopBar` line 254）。
- 改：将 `_buildTopBar()` 移入 `ListView` 作为首项，替换原 `SizedBox(height: 24)`；`_buildTopBar()` padding 由 `fromLTRB(20,8,20,4)` 改为 `only(top: 8, bottom: 4)`。

### 5. `lib/screen/me/notification_settings_page.dart`

- 当前：`SafeArea > Column [ _buildTopBar(), (if loaded) Expanded(ListView([ SizedBox(12), ... ])) ]`（`build` line 126；`_buildTopBar` line 164）。
- 改：将 `_buildTopBar()` 移入 `ListView` 作为首项（在 `SizedBox(12)` 之前或替换之）；`_buildTopBar()` padding 由 `fromLTRB(20,8,20,4)` 改为 `only(top: 8, bottom: 4)`。
- 注意：`_buildTopBar()` 当前位于 `if (_loaded)` 分支之外（在 Column 中），移动后需放入 loaded 分支的 `ListView` 内；未加载时仍显示居中 loading（无标题也可，或保持 loading 全屏）。建议：未加载分支保持纯 loading；加载后 `ListView` 首项为 topBar。

### 6. `lib/screen/order_import/order_import_page.dart`

- 当前：`Stack > Column [ SizedBox(statusBar), _buildTopBar(), Expanded(SingleChildScrollView(...)) ]`（`build` line 279；`_buildTopBar` line 350）。
- 改：将 `_buildTopBar()` 移入 `SingleChildScrollView` 的 `Column` 作为首项（在 `SizedBox(8)` / `_buildHeroBanner()` 之前）；`_buildTopBar()` padding 由 `fromLTRB(20,8,20,0)` 改为 `only(top: 8, bottom: 0)`。

## 验证

1. `flutter analyze`（在项目根目录）确认无新增告警/错误，特别注意未使用 import（`custom_app_bar.dart` 在 item_detail 移除后不应残留其他引用）。
2. 逐页手动验证（运行 app）：
   - 进入「物品详情」「添加物品」「数据备份」「检查更新」「通知设置」「订单导入」各页。
   - 确认标题随内容向上滚动消失，不固定在顶部；返回按钮仍可点击返回。
   - 确认标题与首块内容间距合理，无双重 20px 缩进（标题不偏右）。
   - 各页功能（保存、测试连接、导入等）正常。
3. 对照「AI 模型设置」页确认滚动行为一致。
