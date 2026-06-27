// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../history_record.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$HistoryRecord {

 String get emoji; String get title; String get meta; int get count;@ColorConverter() Color get iconBg;
/// Create a copy of HistoryRecord
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HistoryRecordCopyWith<HistoryRecord> get copyWith => _$HistoryRecordCopyWithImpl<HistoryRecord>(this as HistoryRecord, _$identity);

  /// Serializes this HistoryRecord to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HistoryRecord&&(identical(other.emoji, emoji) || other.emoji == emoji)&&(identical(other.title, title) || other.title == title)&&(identical(other.meta, meta) || other.meta == meta)&&(identical(other.count, count) || other.count == count)&&(identical(other.iconBg, iconBg) || other.iconBg == iconBg));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,emoji,title,meta,count,iconBg);

@override
String toString() {
  return 'HistoryRecord(emoji: $emoji, title: $title, meta: $meta, count: $count, iconBg: $iconBg)';
}


}

/// @nodoc
abstract mixin class $HistoryRecordCopyWith<$Res>  {
  factory $HistoryRecordCopyWith(HistoryRecord value, $Res Function(HistoryRecord) _then) = _$HistoryRecordCopyWithImpl;
@useResult
$Res call({
 String emoji, String title, String meta, int count,@ColorConverter() Color iconBg
});




}
/// @nodoc
class _$HistoryRecordCopyWithImpl<$Res>
    implements $HistoryRecordCopyWith<$Res> {
  _$HistoryRecordCopyWithImpl(this._self, this._then);

  final HistoryRecord _self;
  final $Res Function(HistoryRecord) _then;

/// Create a copy of HistoryRecord
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? emoji = null,Object? title = null,Object? meta = null,Object? count = null,Object? iconBg = null,}) {
  return _then(_self.copyWith(
emoji: null == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,meta: null == meta ? _self.meta : meta // ignore: cast_nullable_to_non_nullable
as String,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,iconBg: null == iconBg ? _self.iconBg : iconBg // ignore: cast_nullable_to_non_nullable
as Color,
  ));
}

}


/// Adds pattern-matching-related methods to [HistoryRecord].
extension HistoryRecordPatterns on HistoryRecord {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HistoryRecord value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HistoryRecord() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HistoryRecord value)  $default,){
final _that = this;
switch (_that) {
case _HistoryRecord():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HistoryRecord value)?  $default,){
final _that = this;
switch (_that) {
case _HistoryRecord() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String emoji,  String title,  String meta,  int count, @ColorConverter()  Color iconBg)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HistoryRecord() when $default != null:
return $default(_that.emoji,_that.title,_that.meta,_that.count,_that.iconBg);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String emoji,  String title,  String meta,  int count, @ColorConverter()  Color iconBg)  $default,) {final _that = this;
switch (_that) {
case _HistoryRecord():
return $default(_that.emoji,_that.title,_that.meta,_that.count,_that.iconBg);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String emoji,  String title,  String meta,  int count, @ColorConverter()  Color iconBg)?  $default,) {final _that = this;
switch (_that) {
case _HistoryRecord() when $default != null:
return $default(_that.emoji,_that.title,_that.meta,_that.count,_that.iconBg);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HistoryRecord implements HistoryRecord {
  const _HistoryRecord({required this.emoji, required this.title, required this.meta, required this.count, @ColorConverter() required this.iconBg});
  factory _HistoryRecord.fromJson(Map<String, dynamic> json) => _$HistoryRecordFromJson(json);

@override final  String emoji;
@override final  String title;
@override final  String meta;
@override final  int count;
@override@ColorConverter() final  Color iconBg;

/// Create a copy of HistoryRecord
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HistoryRecordCopyWith<_HistoryRecord> get copyWith => __$HistoryRecordCopyWithImpl<_HistoryRecord>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HistoryRecordToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HistoryRecord&&(identical(other.emoji, emoji) || other.emoji == emoji)&&(identical(other.title, title) || other.title == title)&&(identical(other.meta, meta) || other.meta == meta)&&(identical(other.count, count) || other.count == count)&&(identical(other.iconBg, iconBg) || other.iconBg == iconBg));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,emoji,title,meta,count,iconBg);

@override
String toString() {
  return 'HistoryRecord(emoji: $emoji, title: $title, meta: $meta, count: $count, iconBg: $iconBg)';
}


}

/// @nodoc
abstract mixin class _$HistoryRecordCopyWith<$Res> implements $HistoryRecordCopyWith<$Res> {
  factory _$HistoryRecordCopyWith(_HistoryRecord value, $Res Function(_HistoryRecord) _then) = __$HistoryRecordCopyWithImpl;
@override @useResult
$Res call({
 String emoji, String title, String meta, int count,@ColorConverter() Color iconBg
});




}
/// @nodoc
class __$HistoryRecordCopyWithImpl<$Res>
    implements _$HistoryRecordCopyWith<$Res> {
  __$HistoryRecordCopyWithImpl(this._self, this._then);

  final _HistoryRecord _self;
  final $Res Function(_HistoryRecord) _then;

/// Create a copy of HistoryRecord
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? emoji = null,Object? title = null,Object? meta = null,Object? count = null,Object? iconBg = null,}) {
  return _then(_HistoryRecord(
emoji: null == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,meta: null == meta ? _self.meta : meta // ignore: cast_nullable_to_non_nullable
as String,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,iconBg: null == iconBg ? _self.iconBg : iconBg // ignore: cast_nullable_to_non_nullable
as Color,
  ));
}


}

// dart format on
