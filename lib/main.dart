import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_router.dart';
import 'services/notification_service.dart';
import 'utils/package_info_setup_web.dart'
    if (dart.library.io) 'utils/package_info_setup_io.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  registerPackageInfoPlus();
  await NotificationService().init();
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final _router = appRouter;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: '拾物记',
      theme: ThemeData(primarySwatch: Colors.amber),
      routerConfig: _router,
    );
  }
}
