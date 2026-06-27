# 拾物记 (shi_wu_ji)

一款基于 Flutter 的家庭物品收纳管理 App，帮助你记录物品存放位置、归类整理、提醒保质期，并支持 WebDAV 云端备份与 GitHub Release 自动更新检查。

## 功能特性

- **物品管理**：记录物品名称、数量、存放位置、分类、标签、图片，支持状态与保质期提醒
- **空间层级**：房间 → 柜体 → 格位 → 物品，四层空间结构精准定位
- **分类管理**：自定义分类，按类筛选与统计
- **订单导入**：从电商平台一键导入订单，自动生成物品记录
- **数据统计**：首页卡片展示物品总数、分类数、近期变动
- **WebDAV 备份**：连接任意 WebDAV 服务（坚果云、Nextcloud 等）自动备份/恢复数据库
- **更新检查**：从 GitHub Releases 拉取最新版本信息，弹窗提示并跳转浏览器下载
- **本地通知**：物品保质期到期、低库存提醒
- **多端支持**：Android / iOS / Windows / Linux / Web

## 技术栈

| 领域 | 选型 |
| --- | --- |
| 框架 | Flutter 3.44+ / Dart 3.11+ |
| 状态管理 | Riverpod 3 + riverpod_annotation (代码生成) |
| 路由 | go_router 17 |
| 网络请求 | dio 5（统一拦截器、错误处理） |
| 本地存储 | drift 2（类型安全 SQLite ORM） |
| 云端备份 | webdav_client 1.2 |
| 模型序列化 | freezed 3 + json_serializable |
| 通知 | flutter_local_notifications 19 |
| 版本信息 | package_info_plus 8 |
| 浏览器跳转 | url_launcher 6 |

## 目录结构

```
lib/
├── main.dart                 # 应用入口
├── app_router.dart           # 路由配置
├── constants/                # 主题色、字号、阴影等常量
├── database/                 # drift 数据库定义、表结构、种子数据
├── daos/                     # 数据访问层（每张表一个 DAO）
├── models/                   # freezed 数据模型 + 枚举
├── providers/                # Riverpod 状态提供者
├── services/                 # 业务服务
│   ├── http_service.dart     # dio 封装（统一 API 响应/异常）
│   ├── update_service.dart   # GitHub Releases 版本检查
│   ├── webdav_service.dart   # WebDAV 备份/恢复
│   └── notification_service.dart
├── screen/                   # 页面（home/inventory/storage/me 等）
├── utils/                    # 工具函数（含 package_info 桌面端注册）
└── widgets/                  # 通用 UI 组件
```

## 快速开始

### 环境要求

- Flutter 3.44+
- Dart 3.11+
- Android Studio / Xcode（移动端构建）
- CMake + Visual Studio Build Tools（Windows 桌面端构建）

### 安装与运行

```bash
# 1. 拉取依赖
flutter pub get

# 2. 生成代码（freezed / json_serializable / drift / riverpod）
dart run build_runner build --delete-conflicting-outputs

# 3. 运行
flutter run                    # 默认设备
flutter run -d windows         # Windows 桌面
flutter run -d chrome          # Web
```

### 代码生成

修改 `models/`、`database/tables/`、`providers/` 后需重新生成代码：

```bash
dart run build_runner build --delete-conflicting-outputs

# 开发时持续监听
dart run build_runner watch --delete-conflicting-outputs
```

## 测试

```bash
flutter test                                  # 全部测试
flutter test test/services/                   # 仅服务层测试
flutter test --coverage                       # 生成覆盖率报告
```

## 构建 Release

### Android

```bash
flutter build apk --split-per-abi             # 分架构 APK
flutter build appbundle                       # AAB (Play Store)
```

签名配置放在 `android/key.properties`（不入库），由 `android/app/build.gradle.kts` 读取。

### Windows / Linux / Web

```bash
flutter build windows
flutter build linux
flutter build web --release
```

## CI/CD

仓库内置 GitHub Actions workflow：[.github/workflows/flutter_build_apk.yml](.github/workflows/flutter_build_apk.yml)

推送 `v*` 标签（如 `v1.0.0`）自动触发：拉取代码 → 配置 Flutter/Java → 解码签名 → 构建 APK → 发布到 GitHub Release。

所需 GitHub Secrets：

| Secret | 说明 |
| --- | --- |
| `KEYSTORE_BASE64` | `keystore.jks` 的 base64 编码字符串 |
| `KEYSTORE_PASSWORD` | keystore 密码 |
| `KEY_ALIAS` | 签名 key 别名 |
| `KEY_PASSWORD` | 签名 key 密码 |

本地生成 `KEYSTORE_BASE64`：

```powershell
$bytes = [System.IO.File]::ReadAllBytes("android\app\keystore.jks")
[System.Convert]::ToBase64String($bytes) | Set-Clipboard
```

## 版本更新检查机制

应用内「我的 → 检查更新」通过 [update_service.dart](lib/services/update_service.dart) 调用 GitHub Releases API：

1. 请求 `https://github.com/huangxing520/shiwuji/releases`
2. 解析 `tag_name` 提取最新版本号
3. 与本地版本（`package_info_plus` 读取 `pubspec.yaml` 的 `version`）比较
4. 有新版本则弹窗展示更新说明，点击「去更新」用 `url_launcher` 打开 release 页面

发版只需修改 [pubspec.yaml](pubspec.yaml) 中的 `version:` 字段，无需改代码。

## 许可证

私有项目，未授权不得商业使用。
