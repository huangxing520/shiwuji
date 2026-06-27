import 'package:json_annotation/json_annotation.dart';

@JsonEnum()
enum PendingCardType {
  expiring,
  returning,
  restocking,
}
