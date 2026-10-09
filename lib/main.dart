import 'package:bugsnag_flutter/bugsnag_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_router.dart';
import 'providers/database_provider.dart';
import 'services/notification_service.dart';
import 'services/first_run_service.dart';
import 'services/encryption_service.dart';
import 'utils/package_info_setup_web.dart'
    if (dart.library.io) 'utils/package_info_setup_io.dart';

/// Bugsnag 崩溃上报 API Key。
///
/// 编译期注入：`flutter run/build --dart-define=BUGSNAG_API_KEY=xxx`。
/// 未注入时为空字符串，Bugsnag 直接跳过启动（不再是必需资源，克隆即可构建）。
const String _bugsnagApiKey = String.fromEnvironment('BUGSNAG_API_KEY');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  registerPackageInfoPlus();

  // 启动初始化：任何一步失败都只降级，绝不让整个 App 白屏。
  // 只有 runApp 本身是关键路径，其余全部包 try/catch。
  // 启动 Bugsnag 崩溃监控，API Key 来自编译期 --dart-define
  await _safeInit('启动 Bugsnag', () async {
    if (_bugsnagApiKey.isNotEmpty) {
      await bugsnag.start(apiKey: _bugsnagApiKey);
    }
  });

  await _safeInit('初始化通知', () => NotificationService().init());
  await _safeInit('初始化首启动标记', FirstRunService.init);
  await _safeInit('初始化加密服务', EncryptionService.instance.init);
  // 预加载首页背景图，避免首次渲染时闪烁（失败只是无预加载，不影响启动）
  await _safeInit(
    '预加载背景图',
    () => rootBundle.load('assets/icon/background1.jpg'),
  );

  runApp(ProviderScope(child: MyApp()));
}

/// 执行一步启动初始化，失败时仅记录日志、不中断启动。
Future<void> _safeInit(String label, Future<void> Function() action) async {
  try {
    await action();
  } catch (e, st) {
    debugPrint('[main] $label 失败，已跳过: $e\n$st');
  }
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  final _router = createAppRouter(
    initialLocation: FirstRunService.isFirstRun ? '/' : '/home',
  );

  @override
  void initState() {
    super.initState();
    // 启动时加载通知偏好（保修/保质期提醒开关与天数），
    // 确保后续新增/编辑物品调度使用用户已保存的配置。
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _loadNotificationPrefs(),
    );
  }

  Future<void> _loadNotificationPrefs() async {
    try {
      final dao = ref.read(settingsDaoProvider);
      await NotificationService().loadPreferences((key) => dao.getValue(key));
      debugPrint('[MyApp] 通知偏好加载完成');
    } catch (e) {
      debugPrint('[MyApp] 加载通知偏好失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: '拾物记',
      theme: ThemeData(primarySwatch: Colors.amber),
      routerConfig: _router,
    );
  }
}
