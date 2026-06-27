import 'package:json_annotation/json_annotation.dart';

@JsonEnum()
enum ItemStatus {
  safe,
  expiring,
  idle,
  underWarranty,
}
