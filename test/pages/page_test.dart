import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shi_wu_ji/models/item.dart';
import 'package:shi_wu_ji/providers/item_providers.dart';
import 'package:shi_wu_ji/screen/home_page.dart';
import 'package:shi_wu_ji/screen/add_item_page.dart';

void main() {
  group('HomePage', () {
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

      expect(find.text('早上好，小橘 🌞'), findsOneWidget);
      expect(find.text('你的物品都在掌控中'), findsOneWidget);
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
      expect(find.text('闲置物品'), findsOneWidget);
    });

  });

  group('AddItemPage', () {
    testWidgets('renders form fields', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: AddItemPage())),
      );
      await tester.pump();

      expect(find.text('物品名称'), findsOneWidget);
      expect(find.text('购买价格'), findsOneWidget);
      expect(find.text('保存入库'), findsOneWidget);
    });

    testWidgets('shows validation error when saving empty form',
        (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: AddItemPage())),
      );
      await tester.pump();

      await tester.tap(find.text('保存入库'));
      await tester.pump();
      expect(find.text('请填写物品名称'), findsOneWidget);
    });
  });
}
