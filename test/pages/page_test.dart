import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shi_wu_ji/models/category_item.dart';
import 'package:shi_wu_ji/providers/category_provider.dart';
import 'package:shi_wu_ji/providers/item_providers.dart';
import 'package:shi_wu_ji/providers/storage_providers.dart';
import 'package:shi_wu_ji/screen/home_page.dart';
import 'package:shi_wu_ji/screen/add_item_page.dart';

/// 空的分类管理器：避免 AddItemPage 在测试中打开真实 drift 数据库
/// （真实库会留下未完成的 drift_flutter 定时器，导致 teardown 断言失败）。
class _FakeCategoryManager extends CategoryManager {
  @override
  Future<List<CategoryItem>> build() async => const [];
}

void main() {  group('HomePage', () {
    testWidgets('renders greeting and subtitle', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            itemCountProvider.overrideWith((ref) => 2),
            totalValueProvider.overrideWith((ref) => 1888),
            pendingCountProvider.overrideWith((ref) => 0),
            idleCountProvider.overrideWith((ref) => 0),
            recentItemsProvider.overrideWith((ref) => []),
          ],
          child: const MaterialApp(home: HomePage()),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump();

      // 问候语根据时间动态变化，使用默认昵称"小橘"
      expect(find.textContaining('小橘'), findsOneWidget);
    });

    testWidgets('renders data card labels', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            itemCountProvider.overrideWith((ref) => 2),
            totalValueProvider.overrideWith((ref) => 1888),
            pendingCountProvider.overrideWith((ref) => 0),
            idleCountProvider.overrideWith((ref) => 0),
            recentItemsProvider.overrideWith((ref) => []),
          ],
          child: const MaterialApp(home: HomePage()),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump();

      expect(find.text('物品总数'), findsOneWidget);
      expect(find.text('过保物品'), findsOneWidget);
    });
  });

  group('AddItemPage', () {
    testWidgets('renders form fields', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            categoryManagerProvider.overrideWith(_FakeCategoryManager.new),
            storageLocationTreeProvider.overrideWith((ref) async => const []),
          ],
          child: const MaterialApp(home: AddItemPage()),
        ),
      );
      await tester.pump();

      expect(find.text('物品名称'), findsOneWidget);
      expect(find.text('购买价格'), findsOneWidget);
      expect(find.text('保存入库'), findsOneWidget);
    });

    testWidgets('shows validation error when saving empty form', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            categoryManagerProvider.overrideWith(_FakeCategoryManager.new),
            storageLocationTreeProvider.overrideWith((ref) async => const []),
          ],
          child: const MaterialApp(home: AddItemPage()),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('保存入库'));
      await tester.pump();
      expect(find.text('请填写物品名称'), findsOneWidget);

      // ToastUtils 用 Future.delayed(2s) 自动隐藏，推进时间把它跑完，
      // 否则遗留的定时器会让 teardown 断言「A Timer is still pending」失败。
      await tester.pump(const Duration(seconds: 3));
    });
  });
}
