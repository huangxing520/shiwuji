import 'package:json_annotation/json_annotation.dart';

@JsonEnum()
enum ItemStatus {
  expiring,
  idle,
  underWarranty,
}
