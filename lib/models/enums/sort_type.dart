import 'package:json_annotation/json_annotation.dart';

@JsonEnum()
enum SortType {
  newest,
  oldest,
  priceHigh,
  priceLow,
  expiring,
}
