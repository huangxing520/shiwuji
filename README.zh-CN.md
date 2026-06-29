

# 拾物记 (ShiWuJi)
[<img src="https://images.typeform.com/images/QKuaAssrFCq7/image/default-firstframe.png" width="40" alt="Bugsnag" valign="middle">](https://www.bugsnag.com)
[English](README.md) | [简体中文](README.zh-CN.md)

一款基于 Flutter 的家庭物品收纳管理应用，帮助你记录物品存放位置、归类整理、跟踪保修状态，支持 AI 拍照识别、订单批量导入和 WebDAV 云端备份。

## 功能特性

- **AI 拍照识别**：拍摄物品照片，AI 自动识别名称、品牌、分类并预填充信息，支持 18+ AI 服务商
- **物品管理**：记录物品名称、价格、分类、存放位置、购买日期、保修天数、照片、品牌、备注等完整信息
- **空间层级**：房间 → 柜体 → 区域 → 物品，四层空间结构精准定位
- **保修跟踪**：自动计算保修到期时间，首页展示即将到期、已过保、在保物品统计
- **分类管理**：内置 12 个分类（数码、家电、护肤、厨房、衣物、书籍、收纳、玩具、运动、文具、钥匙、工具），支持自定义扩展
- **订单导入**：从电商平台一键导入订单，批量生成物品记录
- **数据卡片**：首页展示物品总数、总资产价值（含千分位格式）、本周新增数、本月增长额
- **物品库筛选**：按分类/保修状态筛选、按时间/价格/到期日多维排序
- **收纳空间管理**：房间、柜体、区域三级管理，实时显示占用情况
- **WebDAV 备份**：连接任意 WebDAV 服务（坚果云、Nextcloud 等）进行数据库备份与恢复
- **版本更新检查**：从 GitHub Releases 拉取最新版本信息，弹窗提示并跳转浏览器下载
- **本地通知**：物品保修到期提醒
- **数据加密**：基于 PBKDF2 + AES 的数据库加密
- **多端支持**：Android / iOS / Windows / Linux / Web

## 技术栈

| 领域    | 选型                                    |
| ----- | ------------------------------------- |
| 框架    | Flutter / Dart                        |
| 状态管理  | Riverpod + riverpod\_annotation（代码生成） |
| 路由    | go\_router（StatefulShellRoute 底部导航）   |
| 网络请求  | dio（统一拦截器、错误处理）                       |
| 本地存储  | drift（类型安全 SQLite ORM）                |
| 云端备份  | webdav\_client                        |
| 数据模型  | freezed + json\_serializable          |
| 通知    | flutter\_local\_notifications         |
| 加密    | crypto（PBKDF2 + AES-256）              |
| 图片    | image\_picker + photo\_view           |
| 版本信息  | package\_info\_plus                   |
| 浏览器跳转 | url\_launcher                         |

## 目录结构

```
lib/
├── main.dart                     # 应用入口
├── app_router.dart               # 路由配置（5 页面 + 详情/编辑等子路由）
├── constants/                    # 主题色、字号、阴影、输入框样式
├── database/                     # drift 数据库定义
│   ├── database.dart             # 数据库实例、迁移策略、种子数据初始化
│   ├── seed_data.dart            # 首次安装种子数据（3 房间/3 柜体/3 区域/12 分类）
│   └── tables/                   # 8 张表定义（Items/Rooms/Cabinets/Slots/...）
├── daos/                         # 数据访问层（每表一个 DAO）
├── models/                       # freezed 数据模型 + 枚举
│   └── enums/                    # ItemStatus / SortType / TabType / PendingCardType
├── providers/                    # Riverpod 状态提供者
├── services/                     # 业务服务
│   ├── ai/                       # AI 识别服务
│   │   ├── ai_provider.dart      # 抽象基类
│   │   ├── ai_provider_registry.dart  # 服务商注册表
│   │   ├── ai_provider_type.dart # 服务商枚举
│   │   ├── ai_models.dart        # AI 响应数据模型
│   │   └── providers/            # 18+ AI 服务商实现
│   ├── http_service.dart         # dio 封装
│   ├── update_service.dart       # GitHub Releases 版本检查
│   ├── webdav_service.dart       # WebDAV 备份/恢复
│   ├── encryption_service.dart   # PBKDF2 + AES 加密
│   ├── notification_service.dart # 本地通知
│   ├── photo_service.dart        # 拍照/相册选图
│   └── prompt_service.dart       # AI 提示词管理
├── screen/                       # 页面
│   ├── home/                     # 首页（数据卡片、待处理、最近新增）
│   ├── inventory/                # 物品库（筛选、排序、列表）
│   ├── storage/                  # 收纳空间管理
│   ├── me/                       # 个人中心（备份、通知、AI 设置、更新检查）
│   ├── scan/                     # AI 拍照识别
│   └── order_import/             # 电商订单导入
└── widgets/                      # 通用 UI 组件（20+）
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
dart run build_runner build

# 3. 运行
flutter run
```

### 代码生成

修改 `models/`、`database/tables/`、`providers/` 后需重新生成：

```bash
dart run build_runner build

# 开发时持续监听
dart run build_runner watch
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

## 许可证

本项目采用 [MIT License](LICENSE) 开源协议。
