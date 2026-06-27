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

    // 标题区域
    expect(find.text('早上好，小橘 🌞'), findsOneWidget);
    // 搜索栏
    expect(find.textContaining('搜索'), findsOneWidget);
  });
}
