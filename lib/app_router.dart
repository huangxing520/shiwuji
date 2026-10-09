import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shi_wu_ji/screen/home_page.dart';
import 'package:shi_wu_ji/screen/inventory_page.dart';
import 'package:shi_wu_ji/screen/item_detail_page.dart';
import 'package:shi_wu_ji/screen/storage_page.dart';
import 'package:shi_wu_ji/screen/category_page.dart';
import 'package:shi_wu_ji/widgets/main_shell.dart';
import 'package:shi_wu_ji/screen/splash_page.dart';
import 'package:shi_wu_ji/screen/add_item_page.dart';
import 'package:shi_wu_ji/screen/order-import-page.dart';
import 'package:shi_wu_ji/screen/me_page.dart';
import 'package:shi_wu_ji/screen/me/data_backup_page.dart';
import 'package:shi_wu_ji/screen/me/notification_settings_page.dart';
import 'package:shi_wu_ji/screen/me/check_update_page.dart';
import 'package:shi_wu_ji/screen/me/ai_settings_page.dart';
import 'package:shi_wu_ji/screen/scan/scan_page.dart';

/// 创建应用路由。根据 [initialLocation] 决定启动页：首次启动显示 splash，否则直接进入首页。
GoRouter createAppRouter({String initialLocation = '/'}) {
  return GoRouter(
    initialLocation: initialLocation,
    // 未匹配的路径或坏深链不抛错，渲染可读兜底页（含返回首页入口）。
    errorBuilder: (context, state) => _RouteErrorPage(message: state.error?.toString()),
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashPage()),
      GoRoute(
        path: '/add_item',
        builder: (context, state) =>
            AddItemPage(initialValues: state.extra as AddItemInitialValues?),
      ),
      GoRoute(
        path: '/edit_item/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'];
          if (id == null || id.isEmpty) return const _RouteErrorPage(message: '缺少物品标识');
          return AddItemPage(itemId: id);
        },
      ),
      GoRoute(
        path: '/order-import',
        builder: (context, state) => const OrderImportPage(),
      ),
      GoRoute(
        path: '/categories',
        builder: (context, state) => const CategoryPage(),
      ),
      GoRoute(
        path: '/data-backup',
        builder: (context, state) => const DataBackupPage(),
      ),
      GoRoute(
        path: '/notification-settings',
        builder: (context, state) => const NotificationSettingsPage(),
      ),
      GoRoute(
        path: '/check-update',
        builder: (context, state) => const CheckUpdatePage(),
      ),
      GoRoute(
        path: '/ai-settings',
        builder: (context, state) => const AiSettingsPage(),
      ),
      GoRoute(path: '/scan', builder: (context, state) => const ScanPage()),
      GoRoute(
        path: '/detail/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'];
          if (id == null || id.isEmpty) return const _RouteErrorPage(message: '缺少物品标识');
          return ItemDetailPage(itemId: id);
        },
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),
          // 物品库
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/inventory',
                builder: (context, state) => const InventoryPage(),
              ),
            ],
          ),
          // 收纳位置管理
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/storage',
                builder: (context, state) => const StoragePage(),
              ),
            ],
          ),
          // 个人中心
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/me', builder: (context, state) => const MePage()),
            ],
          ),
        ],
      ),
    ],
  );
}

/// 路由兜底页：路径未匹配、深链缺参数时展示可读错误，而不是崩溃或白屏。
class _RouteErrorPage extends StatelessWidget {
  final String? message;

  const _RouteErrorPage({this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 16),
              const Text(
                '页面不存在或无法打开',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              if (message != null && message!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13),
                ),
              ],
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => context.go('/home'),
                child: const Text('返回首页'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
