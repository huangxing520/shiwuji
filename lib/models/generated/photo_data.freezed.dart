// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../photo_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PhotoData {

 String get emoji;@ColorConverter() Color get color;
/// Create a copy of PhotoData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PhotoDataCopyWith<PhotoData> get copyWith => _$PhotoDataCopyWithImpl<PhotoData>(this as PhotoData, _$identity);

  /// Serializes this PhotoData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PhotoData&&(identical(other.emoji, emoji) || other.emoji == emoji)&&(identical(other.color, color) || other.color == color));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,emoji,color);

@override
String toString() {
  return 'PhotoData(emoji: $emoji, color: $color)';
}


}

/// @nodoc
abstract mixin class $PhotoDataCopyWith<$Res>  {
  factory $PhotoDataCopyWith(PhotoData value, $Res Function(PhotoData) _then) = _$PhotoDataCopyWithImpl;
@useResult
$Res call({
 String emoji,@ColorConverter() Color color
});




}
/// @nodoc
class _$PhotoDataCopyWithImpl<$Res>
    implements $PhotoDataCopyWith<$Res> {
  _$PhotoDataCopyWithImpl(this._self, this._then);

  final PhotoData _self;
  final $Res Function(PhotoData) _then;

/// Create a copy of PhotoData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? emoji = null,Object? color = null,}) {
  return _then(_self.copyWith(
emoji: null == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as Color,
  ));
}

}


/// Adds pattern-matching-related methods to [PhotoData].
extension PhotoDataPatterns on PhotoData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PhotoData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PhotoData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PhotoData value)  $default,){
final _that = this;
switch (_that) {
case _PhotoData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PhotoData value)?  $default,){
final _that = this;
switch (_that) {
case _PhotoData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String emoji, @ColorConverter()  Color color)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PhotoData() when $default != null:
return $default(_that.emoji,_that.color);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String emoji, @ColorConverter()  Color color)  $default,) {final _that = this;
switch (_that) {
case _PhotoData():
return $default(_that.emoji,_that.color);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String emoji, @ColorConverter()  Color color)?  $default,) {final _that = this;
switch (_that) {
case _PhotoData() when $default != null:
return $default(_that.emoji,_that.color);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PhotoData implements PhotoData {
  const _PhotoData({required this.emoji, @ColorConverter() required this.color});
  factory _PhotoData.fromJson(Map<String, dynamic> json) => _$PhotoDataFromJson(json);

@override final  String emoji;
@override@ColorConverter() final  Color color;

/// Create a copy of PhotoData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PhotoDataCopyWith<_PhotoData> get copyWith => __$PhotoDataCopyWithImpl<_PhotoData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PhotoDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PhotoData&&(identical(other.emoji, emoji) || other.emoji == emoji)&&(identical(other.color, color) || other.color == color));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,emoji,color);

@override
String toString() {
  return 'PhotoData(emoji: $emoji, color: $color)';
}


}

/// @nodoc
abstract mixin class _$PhotoDataCopyWith<$Res> implements $PhotoDataCopyWith<$Res> {
  factory _$PhotoDataCopyWith(_PhotoData value, $Res Function(_PhotoData) _then) = __$PhotoDataCopyWithImpl;
@override @useResult
$Res call({
 String emoji,@ColorConverter() Color color
});




}
/// @nodoc
class __$PhotoDataCopyWithImpl<$Res>
    implements _$PhotoDataCopyWith<$Res> {
  __$PhotoDataCopyWithImpl(this._self, this._then);

  final _PhotoData _self;
  final $Res Function(_PhotoData) _then;

/// Create a copy of PhotoData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? emoji = null,Object? color = null,}) {
  return _then(_PhotoData(
emoji: null == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as Color,
  ));
}


}

// dart format on
