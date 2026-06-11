import 'package:go_router/go_router.dart';
import 'package:shi_wu_ji/screen/home_page.dart';
import 'package:shi_wu_ji/screen/inventory.dart';
import 'package:shi_wu_ji/screen/item_detail_page.dart';
import 'package:shi_wu_ji/screen/storage.dart';
import 'package:shi_wu_ji/widgets/main_shell.dart';
import 'package:shi_wu_ji/screen/splash_page.dart';
import 'package:shi_wu_ji/screen/add_item_page.dart';
import 'package:shi_wu_ji/screen/order-import-page.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashPage()),
    //GoRoute(path: '/home', builder: (context, state) => const HomePage()),
    GoRoute(path: '/add_item', builder: (context, state) => const AddItemPage()),
    GoRoute(path: '/order-import', builder: (context, state) => const OrderImportPage()),
    GoRoute(
      path: '/detail/:id',
      builder: (context, state) =>
          ItemDetailPage(itemId: state.pathParameters['id']!),
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

      ],
    ),
  ],
);
