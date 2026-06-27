// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../picker_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PickerItem {

 String get emoji; String get name;
/// Create a copy of PickerItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PickerItemCopyWith<PickerItem> get copyWith => _$PickerItemCopyWithImpl<PickerItem>(this as PickerItem, _$identity);

  /// Serializes this PickerItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PickerItem&&(identical(other.emoji, emoji) || other.emoji == emoji)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,emoji,name);

@override
String toString() {
  return 'PickerItem(emoji: $emoji, name: $name)';
}


}

/// @nodoc
abstract mixin class $PickerItemCopyWith<$Res>  {
  factory $PickerItemCopyWith(PickerItem value, $Res Function(PickerItem) _then) = _$PickerItemCopyWithImpl;
@useResult
$Res call({
 String emoji, String name
});




}
/// @nodoc
class _$PickerItemCopyWithImpl<$Res>
    implements $PickerItemCopyWith<$Res> {
  _$PickerItemCopyWithImpl(this._self, this._then);

  final PickerItem _self;
  final $Res Function(PickerItem) _then;

/// Create a copy of PickerItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? emoji = null,Object? name = null,}) {
  return _then(_self.copyWith(
emoji: null == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PickerItem].
extension PickerItemPatterns on PickerItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PickerItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PickerItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PickerItem value)  $default,){
final _that = this;
switch (_that) {
case _PickerItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PickerItem value)?  $default,){
final _that = this;
switch (_that) {
case _PickerItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String emoji,  String name)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PickerItem() when $default != null:
return $default(_that.emoji,_that.name);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String emoji,  String name)  $default,) {final _that = this;
switch (_that) {
case _PickerItem():
return $default(_that.emoji,_that.name);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String emoji,  String name)?  $default,) {final _that = this;
switch (_that) {
case _PickerItem() when $default != null:
return $default(_that.emoji,_that.name);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PickerItem implements PickerItem {
  const _PickerItem({required this.emoji, required this.name});
  factory _PickerItem.fromJson(Map<String, dynamic> json) => _$PickerItemFromJson(json);

@override final  String emoji;
@override final  String name;

/// Create a copy of PickerItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PickerItemCopyWith<_PickerItem> get copyWith => __$PickerItemCopyWithImpl<_PickerItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PickerItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PickerItem&&(identical(other.emoji, emoji) || other.emoji == emoji)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,emoji,name);

@override
String toString() {
  return 'PickerItem(emoji: $emoji, name: $name)';
}


}

/// @nodoc
abstract mixin class _$PickerItemCopyWith<$Res> implements $PickerItemCopyWith<$Res> {
  factory _$PickerItemCopyWith(_PickerItem value, $Res Function(_PickerItem) _then) = __$PickerItemCopyWithImpl;
@override @useResult
$Res call({
 String emoji, String name
});




}
/// @nodoc
class __$PickerItemCopyWithImpl<$Res>
    implements _$PickerItemCopyWith<$Res> {
  __$PickerItemCopyWithImpl(this._self, this._then);

  final _PickerItem _self;
  final $Res Function(_PickerItem) _then;

/// Create a copy of PickerItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? emoji = null,Object? name = null,}) {
  return _then(_PickerItem(
emoji: null == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
