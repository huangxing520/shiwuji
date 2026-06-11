import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wupin/models/item.dart';
import 'package:wupin/providers/item_providers.dart';
import 'package:wupin/home_page.dart';
import 'package:wupin/add_item_page.dart';
import 'package:wupin/item_detail_page.dart';

void main() {
  group('HomePage', () {
    testWidgets('renders header text', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: HomePage())),
      );
      await tester.pump();
      expect(find.text('Hello, User!'), findsOneWidget);
      expect(find.text('Manage your items easily'), findsOneWidget);
    });

    testWidgets('renders stat cards with provider data', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: HomePage())),
      );
      await tester.pump();
      expect(find.text('Total Items'), findsOneWidget);
      expect(find.text('Pending'), findsOneWidget);
      expect(find.text('Warranty'), findsOneWidget);
    });

    testWidgets('renders quick action cards', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: HomePage())),
      );
      await tester.pump();
      expect(find.text('Add'), findsOneWidget);
      expect(find.text('Categories'), findsOneWidget);
      expect(find.text('Locations'), findsOneWidget);
      expect(find.text('Stats'), findsOneWidget);
    });

    testWidgets('renders section titles', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: HomePage())),
      );
      await tester.pump();
      expect(find.text('Quick Actions'), findsOneWidget);
      expect(find.text('Pending Items'), findsOneWidget);
    });
  });

  group('AddItemPage', () {
    testWidgets('renders form fields', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: AddItemPage())),
      );
      await tester.pump();
      expect(find.text('Item Name'), findsOneWidget);
      expect(find.text('Price'), findsOneWidget);
      expect(find.text('Save Item'), findsOneWidget);
    });

    testWidgets('shows validation error when saving empty form', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: AddItemPage())),
      );
      await tester.pump();
      await tester.tap(find.text('Save Item'));
      await tester.pump();
      expect(find.text('Please enter item name'), findsOneWidget);
    });
  });

  group('ItemDetailPage', () {
    testWidgets('shows item not found for invalid id', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: ItemDetailPage(itemId: 'invalid-id')),
        ),
      );
      await tester.pump();
      expect(find.text('Item not found'), findsOneWidget);
    });

    testWidgets('shows item details for valid id', (tester) async {
      final testItem = Item(
        id: 'test-id',
        name: 'TestWidget',
        price: 999,
        category: 'Gadgets',
        location: 'Shelf',
        purchaseDate: DateTime(2024, 6, 1),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [itemsProvider.overrideWithValue([testItem])],
          child: MaterialApp(home: const ItemDetailPage(itemId: 'test-id')),
        ),
      );
      await tester.pump();
      expect(find.text('TestWidget'), findsWidgets);
      expect(find.text('Category: Gadgets'), findsOneWidget);
      expect(find.text('Location: Shelf'), findsOneWidget);
    });
  });
}