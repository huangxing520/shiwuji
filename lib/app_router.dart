import 'package:go_router/go_router.dart';
import 'package:shi_wu_ji/screen/home_page.dart';
import 'package:shi_wu_ji/screen/item_detail_page.dart';
import 'package:shi_wu_ji/widgets/main_shell.dart';
import 'splash_page.dart';
import 'add_item_page.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashPage()),
    //GoRoute(path: '/home', builder: (context, state) => const HomePage()),
    GoRoute(path: '/add', builder: (context, state) => const AddItemPage()),
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
        // StatefulShellBranch(
        //   routes: [
        //     GoRoute(
        //       path: '/stats',
        //       builder: (context, state) => const StatsScreen(),
        //     ),
        //   ],
        // ),

        // StatefulShellBranch(
        //   routes: [
        //     GoRoute(
        //       path: '/profile',
        //       builder: (context, state) => ProfileScreen(version: version),
        //     ),
        //   ],
        // ),
      ],
    ),
  ],
);
