import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shi_wu_ji/models/item.dart';
import 'package:shi_wu_ji/providers/item_providers.dart';
import 'package:shi_wu_ji/screen/home_page.dart';

void main() {
  testWidgets('HomePage renders correctly', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          itemCountProvider.overrideWith((ref) => 3),
          totalValueProvider.overrideWith((ref) => 7597),
          pendingCountProvider.overrideWith((ref) => 1),
          idleCountProvider.overrideWith((ref) => 0),
          recentItemsProvider.overrideWith((ref) => [
            Item(
              id: '1',
              name: '测试物品',
              price: 99,
              purchaseDate: DateTime(2024, 6, 1),
            ),
          ]),
        ],
        child: const MaterialApp(home: HomePage()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();

    // 标题区域：问候语按当前小时分支（凌晨/早上/中午/傍晚/晚上），
    // 只断言昵称，避免测试只在本地 05:00–11:00 通过。
    expect(find.textContaining('小橘'), findsOneWidget);
    // 头部下方紧邻的数据卡片区块（首屏可见，ListView 懒加载不会跳过）。
    expect(find.text('物品总数'), findsOneWidget);
  });
}
