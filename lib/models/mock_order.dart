import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/mock_order.freezed.dart';
part 'generated/mock_order.g.dart';

enum OrderStatus {
  pending,
  success,
  fail,
}

@freezed
abstract class MockOrder with _$MockOrder {
  const factory MockOrder({
    required String emoji,
    required String name,
    required String price,
    @Default(OrderStatus.pending) OrderStatus status,
  }) = _MockOrder;

  factory MockOrder.fromJson(Map<String, dynamic> json) =>
      _$MockOrderFromJson(json);
}
