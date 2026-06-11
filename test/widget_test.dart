import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wupin/home_page.dart';

void main() {
  testWidgets('HomePage renders correctly', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: HomePage())),
    );
    await tester.pump();
    expect(find.text('Hello, User!'), findsOneWidget);
    expect(find.text('Total Items'), findsOneWidget);
    expect(find.text('Search items...'), findsOneWidget);
  });
}