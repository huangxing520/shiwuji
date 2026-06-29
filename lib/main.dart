import 'package:bugsnag_flutter/bugsnag_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_router.dart';
import 'services/notification_service.dart';
import 'services/first_run_service.dart';
import 'utils/package_info_setup_web.dart'
    if (dart.library.io) 'utils/package_info_setup_io.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  registerPackageInfoPlus();
  await bugsnag.start(apiKey: 'a7343293366ed808d575ca08e0a42c03');

  await NotificationService().init();
  await FirstRunService.init();
  // 预加载首页背景图，避免首次渲染时闪烁
  await rootBundle.load('assets/icon/background1.jpg');
  try {
  throw Exception('handled exception');
} catch (e, stack) {
  await bugsnag.notify(e, stack);
}
  runApp(ProviderScope(child: MyApp()));
  
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final _router = createAppRouter(
    initialLocation: FirstRunService.isFirstRun ? '/' : '/home',
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: '拾物记',
      theme: ThemeData(primarySwatch: Colors.amber),
      routerConfig: _router,
    );
  }
}
