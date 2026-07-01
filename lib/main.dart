import 'package:bugsnag_flutter/bugsnag_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_router.dart';
import 'providers/database_provider.dart';
import 'services/notification_service.dart';
import 'services/first_run_service.dart';
import 'services/encryption_service.dart';
import 'utils/package_info_setup_web.dart'
    if (dart.library.io) 'utils/package_info_setup_io.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  registerPackageInfoPlus();

  // 加载 .env 配置文件（含 BUGSNAG_API_KEY 等敏感信息）
  await dotenv.load(fileName: '.env');

  // 启动 Bugsnag 崩溃监控，API Key 从 .env 读取
  final bugsnagApiKey = dotenv.env['BUGSNAG_API_KEY'] ?? '';
  if (bugsnagApiKey.isNotEmpty) {
    await bugsnag.start(apiKey: bugsnagApiKey);
  }

  await NotificationService().init();
  await FirstRunService.init();
  await EncryptionService.instance.init();
  // 预加载首页背景图，避免首次渲染时闪烁
  await rootBundle.load('assets/icon/background1.jpg');
  runApp(ProviderScope(child: MyApp()));
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
