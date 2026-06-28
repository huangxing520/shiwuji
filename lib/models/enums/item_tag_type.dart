import 'package:json_annotation/json_annotation.dart';

@JsonEnum()
enum ItemTagType {
  newItem,
  urgent,
  normal,
  expired,
}
