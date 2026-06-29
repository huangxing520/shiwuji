# 新增收纳空间模块 · 上传实景图功能

## Context（背景）

`AddSpaceModal`（[lib/screen/storage/add_space_modal.dart](file:///c:/Users/bron1117/flutter/wupin/lib/screen/storage/add_space_modal.dart)）已有一个占位的 `_buildPhotoUpload()`（第 718-752 行），点击仅弹 toast「选择实景照片」，未真正实现选图、预览、校验、持久化。

本次需求：在新增「柜体」时支持上传**单张**实景图，含上传按钮、预览区、删除重传、进度指示、格式/大小校验与友好错误提示。用户已确认：
- **完整持久化**：图片路径存入数据库，保存后可复用。
- **仅柜体层级**：与现有 `hasPhoto` 设计一致，房间/格子不开放。

现有可复用能力：
- [PhotoService](file:///c:/Users/bron1117/flutter/wupin/lib/services/photo_service.dart) 已实现 JPG/PNG 校验、5MB 限制、拷贝到文档目录、单选（`pickFromGallery(remaining:1)`）、相机（`pickFromCamera`）、删除（`deleteFile`）。
- [AddItemPage](file:///c:/Users/bron1117/flutter/wupin/lib/screen/add_item_page.dart) 的照片 UI 模式（来源选择 sheet、缩略图、进度遮罩、删除按钮、重试）可直接借鉴。
- `cabinets` 表已有 `hasPhoto` 布尔列，缺 `photoPath` 路径列。

## 实现方案

### 1. 数据库层

**[lib/database/tables/cabinets_table.dart](file:///c:/Users/bron1117/flutter/wupin/lib/database/tables/cabinets_table.dart)**：新增可空文本列
```dart
TextColumn get photoPath => text().nullable()();
```
保留现有 `hasPhoto`（作为快速判断标志，与现有 `_SpaceCard` 徽标逻辑兼容）。

**[lib/database/database.dart](file:///c:/Users/bron1117/flutter/wupin/lib/database/database.dart)**：升级 schema
- `schemaVersion` 从 `1` → `2`
- `migration` 增加 `onUpgrade`：
```dart
onUpgrade: (Migrator m, int from, int to) async {
  if (from < 2) {
    await m.addColumn(cabinets, cabinets.photoPath);
  }
},
```

### 2. 模型层

**[lib/models/storage.dart](file:///c:/Users/bron1117/flutter/wupin/lib/models/storage.dart)**：给 `Cabinet` freezed 类新增 `String? photoPath` 字段（nullable）。

### 3. Provider 层

**[lib/providers/storage_providers.dart](file:///c:/Users/bron1117/flutter/wupin/lib/providers/storage_providers.dart)**：
- `cabinetsByRoom`：映射 `photoPath: row.photoPath` 到 model.Cabinet。
- `CabinetActions.addCabinet`：新增 `String? photoPath` 参数；插入时传
  `photoPath: photoPath != null ? Value(photoPath) : const Value.absent()`
  与 `hasPhoto: (photoPath != null && photoPath.isNotEmpty) ? const Value(true) : const Value.absent()`。
- `CabinetActions.updateCabinet`：**安全保护**——编辑名称/图标时不能清空已存 photoPath。将 DAO 的 `replace` 改为 `write`（仅更新提供的列），避免编辑柜体时把 photoPath 重置为 null。

**[lib/daos/cabinet_dao.dart](file:///c:/Users/bron1117/flutter/wupin/lib/daos/cabinet_dao.dart)**：`updateCabinet` 由 `replace` 改为带 where 的 `write`，仅更新非 absent 字段：
```dart
Future<bool> updateCabinet(CabinetsCompanion cabinet) async {
  final rows = await (update(cabinets)
        ..where((t) => t.id.equals(cabinet.id.value)))
      .write(cabinet);
  return rows > 0;
}
```

### 4. 新增模态框 UI（核心）

**[lib/screen/storage/add_space_modal.dart](file:///c:/Users/bron1117/flutter/wupin/lib/screen/storage/add_space_modal.dart)**：

- 回调签名 `AddSpaceCallback` 增加 `String? photoPath`。
- 新增状态：`PhotoEntry? _photo`、`bool _isPicking`、`bool _saved`（用于 dispose 时判断是否清理草稿文件）。
- 「上传实景图」表单行改为**仅在 `_addLevel == 'cabinet'` 时显示**（当前第 234 行无条件显示）。
- 重写 `_buildPhotoUpload()` 三态：
  - **空态**：虚线边框上传按钮（图标 + 「点击上传空间照片」+ 提示「支持 JPG/PNG，单张 ≤5MB」）。点击 → `_showPhotoSourceSheet()`（相册/拍照/取消，仿 AddItemPage）。
  - **选图中**：上传区显示 `CircularProgressIndicator`。
  - **已选**：全宽预览图（`Image.file`，约 150px 高，圆角），右上角删除 X 按钮。点击预览图本体（非 X）→ toast「仅支持上传一张实景图，请先删除后重新选择」并阻止（满足需求 #2 的"上传第二张时提示并阻止"）。
- `_pickFromGallery()` / `_pickFromCamera()`：调用 `PhotoService.instance`（单选路径），根据 `PickResult.error` 弹友好 toast（格式/大小/保存失败），成功则 `_photo = PhotoEntry(path, success)`。
- `_removePhoto()`：`PhotoService.instance.deleteFile(_photo!.path)` 后清空 `_photo`（草稿文件直接删，未入库）。
- 层级切换保护：`_buildLevelSelect` 的 `onChanged` 中，若离开 cabinet 且 `_photo != null`，先删除草稿文件并清空。
- `_save()`：把 `photoPath: _photo?.path` 传入 `widget.onConfirm`，并置 `_saved = true`。
- `dispose()`：若 `!_saved && _photo != null`，删除草稿文件，避免孤儿文件。

### 5. 调用方

**[lib/screen/storage/storage_page.dart](file:///c:/Users/bron1117/flutter/wupin/lib/screen/storage/storage_page.dart)**：`_onAddConfirm` 签名增加 `String? photoPath`；在 `case 'cabinet'` 分支调用 `addCabinet(...)` 时传入 `photoPath: photoPath`。`case 'room'` 自动创建的「默认柜体」不传 photoPath（null）。

### 6. 代码生成

运行 `dart run build_runner build --delete-conflicting-outputs` 重新生成：
- `lib/models/generated/storage.freezed.dart` / `storage.g.dart`（model.Cabinet.photoPath）
- `lib/database/generated/database.g.dart`（CabinetsCompanion.photoPath、db.Cabinet.photoPath）
- `lib/providers/generated/storage_providers.g.dart`
- `lib/daos/generated/cabinet_dao.g.dart`

## 关键文件清单

| 文件 | 改动 |
|---|---|
| `lib/database/tables/cabinets_table.dart` | 新增 `photoPath` 列 |
| `lib/database/database.dart` | schemaVersion→2 + onUpgrade 迁移 |
| `lib/models/storage.dart` | model.Cabinet 新增 `photoPath` |
| `lib/daos/cabinet_dao.dart` | `updateCabinet` replace→write 保护 |
| `lib/providers/storage_providers.dart` | 映射 photoPath、addCabinet 入参、updateCabinet 保护 |
| `lib/screen/storage/add_space_modal.dart` | 实现单图上传 UI + 回调 |
| `lib/screen/storage/storage_page.dart` | `_onAddConfirm` 透传 photoPath |

## 复用的现有能力（不重复造轮子）

- `PhotoService.instance.pickFromGallery(remaining: 1)` — 单选 + 校验 + 拷贝
- `PhotoService.instance.pickFromCamera()` — 拍照
- `PhotoService.instance.deleteFile()` — 草稿清理
- `PhotoEntry` / `PhotoStatus` — 照片状态模型
- `ToastUtils.show()` — 友好提示
- AddItemPage 的 `_showPhotoSourceSheet` / `_PhotoThumb` 模式 — UI 范式

## 验证方法

1. `dart run build_runner build --delete-conflicting-outputs` 成功，无报错。
2. `flutter analyze` 无新增 error。
3. 运行 App（`flutter run`）：
   - 新增「房间」/「格子」时**不显示**上传实景图行；新增「柜体」时显示。
   - 点上传 → 选择 sheet（相册/拍照/取消）。
   - 选 JPG/PNG ≤5MB → 预览正常显示，删除可重传。
   - 选第二张（点预览图）→ 弹「仅支持一张」toast 且阻止。
   - 选非图片或 >5MB → 弹格式/大小 toast。
   - 保存后该柜体卡片右上角相机徽标出现（`hasPhoto=true`）；重启 App 后徽标仍在（持久化生效）。
   - 编辑该柜体名称 → 保存后徽标仍在（photoPath 未被清空，验证 updateCabinet 保护）。
   - 上传后不保存直接关闭模态 → 检查文档目录无新增孤儿文件。
4. 升级验证：在旧版（schema v1）数据库上启动新版，确认 `photo_path` 列成功 ALTER，原有数据不丢失。
