import 'dart:io' show Platform;

import 'package:package_info_plus/package_info_plus.dart';

/// 注册桌面端的 package_info_plus 纯 Dart 实现。
///
/// Android/iOS 通过原生插件自动注册，无需调用。
/// Windows/Linux 需要手动注册纯 Dart 实现，否则
/// `PackageInfo.fromPlatform()` 会抛 `MissingPluginException`。
void registerPackageInfoPlus() {
  if (Platform.isWindows) {
    PackageInfoPlusWindowsPlugin.registerWith();
  } else if (Platform.isLinux) {
    PackageInfoPlusLinuxPlugin.registerWith();
  }
}
