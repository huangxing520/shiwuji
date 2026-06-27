// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../mock_order.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MockOrder {

 String get emoji; String get name; String get price; OrderStatus get status;
/// Create a copy of MockOrder
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MockOrderCopyWith<MockOrder> get copyWith => _$MockOrderCopyWithImpl<MockOrder>(this as MockOrder, _$identity);

  /// Serializes this MockOrder to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MockOrder&&(identical(other.emoji, emoji) || other.emoji == emoji)&&(identical(other.name, name) || other.name == name)&&(identical(other.price, price) || other.price == price)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,emoji,name,price,status);

@override
String toString() {
  return 'MockOrder(emoji: $emoji, name: $name, price: $price, status: $status)';
}


}

/// @nodoc
abstract mixin class $MockOrderCopyWith<$Res>  {
  factory $MockOrderCopyWith(MockOrder value, $Res Function(MockOrder) _then) = _$MockOrderCopyWithImpl;
@useResult
$Res call({
 String emoji, String name, String price, OrderStatus status
});




}
/// @nodoc
class _$MockOrderCopyWithImpl<$Res>
    implements $MockOrderCopyWith<$Res> {
  _$MockOrderCopyWithImpl(this._self, this._then);

  final MockOrder _self;
  final $Res Function(MockOrder) _then;

/// Create a copy of MockOrder
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? emoji = null,Object? name = null,Object? price = null,Object? status = null,}) {
  return _then(_self.copyWith(
emoji: null == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OrderStatus,
  ));
}

}


/// Adds pattern-matching-related methods to [MockOrder].
extension MockOrderPatterns on MockOrder {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MockOrder value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MockOrder() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MockOrder value)  $default,){
final _that = this;
switch (_that) {
case _MockOrder():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MockOrder value)?  $default,){
final _that = this;
switch (_that) {
case _MockOrder() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String emoji,  String name,  String price,  OrderStatus status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MockOrder() when $default != null:
return $default(_that.emoji,_that.name,_that.price,_that.status);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String emoji,  String name,  String price,  OrderStatus status)  $default,) {final _that = this;
switch (_that) {
case _MockOrder():
return $default(_that.emoji,_that.name,_that.price,_that.status);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String emoji,  String name,  String price,  OrderStatus status)?  $default,) {final _that = this;
switch (_that) {
case _MockOrder() when $default != null:
return $default(_that.emoji,_that.name,_that.price,_that.status);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MockOrder implements MockOrder {
  const _MockOrder({required this.emoji, required this.name, required this.price, this.status = OrderStatus.pending});
  factory _MockOrder.fromJson(Map<String, dynamic> json) => _$MockOrderFromJson(json);

@override final  String emoji;
@override final  String name;
@override final  String price;
@override@JsonKey() final  OrderStatus status;

/// Create a copy of MockOrder
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MockOrderCopyWith<_MockOrder> get copyWith => __$MockOrderCopyWithImpl<_MockOrder>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MockOrderToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MockOrder&&(identical(other.emoji, emoji) || other.emoji == emoji)&&(identical(other.name, name) || other.name == name)&&(identical(other.price, price) || other.price == price)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,emoji,name,price,status);

@override
String toString() {
  return 'MockOrder(emoji: $emoji, name: $name, price: $price, status: $status)';
}


}

/// @nodoc
abstract mixin class _$MockOrderCopyWith<$Res> implements $MockOrderCopyWith<$Res> {
  factory _$MockOrderCopyWith(_MockOrder value, $Res Function(_MockOrder) _then) = __$MockOrderCopyWithImpl;
@override @useResult
$Res call({
 String emoji, String name, String price, OrderStatus status
});




}
/// @nodoc
class __$MockOrderCopyWithImpl<$Res>
    implements _$MockOrderCopyWith<$Res> {
  __$MockOrderCopyWithImpl(this._self, this._then);

  final _MockOrder _self;
  final $Res Function(_MockOrder) _then;

/// Create a copy of MockOrder
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? emoji = null,Object? name = null,Object? price = null,Object? status = null,}) {
  return _then(_MockOrder(
emoji: null == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OrderStatus,
  ));
}


}

// dart format on
