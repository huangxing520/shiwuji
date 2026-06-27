// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../platform_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TutorialStep {

 String get title; String get desc;
/// Create a copy of TutorialStep
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TutorialStepCopyWith<TutorialStep> get copyWith => _$TutorialStepCopyWithImpl<TutorialStep>(this as TutorialStep, _$identity);

  /// Serializes this TutorialStep to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TutorialStep&&(identical(other.title, title) || other.title == title)&&(identical(other.desc, desc) || other.desc == desc));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,desc);

@override
String toString() {
  return 'TutorialStep(title: $title, desc: $desc)';
}


}

/// @nodoc
abstract mixin class $TutorialStepCopyWith<$Res>  {
  factory $TutorialStepCopyWith(TutorialStep value, $Res Function(TutorialStep) _then) = _$TutorialStepCopyWithImpl;
@useResult
$Res call({
 String title, String desc
});




}
/// @nodoc
class _$TutorialStepCopyWithImpl<$Res>
    implements $TutorialStepCopyWith<$Res> {
  _$TutorialStepCopyWithImpl(this._self, this._then);

  final TutorialStep _self;
  final $Res Function(TutorialStep) _then;

/// Create a copy of TutorialStep
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? desc = null,}) {
  return _then(_self.copyWith(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,desc: null == desc ? _self.desc : desc // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [TutorialStep].
extension TutorialStepPatterns on TutorialStep {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TutorialStep value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TutorialStep() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TutorialStep value)  $default,){
final _that = this;
switch (_that) {
case _TutorialStep():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TutorialStep value)?  $default,){
final _that = this;
switch (_that) {
case _TutorialStep() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String title,  String desc)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TutorialStep() when $default != null:
return $default(_that.title,_that.desc);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String title,  String desc)  $default,) {final _that = this;
switch (_that) {
case _TutorialStep():
return $default(_that.title,_that.desc);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String title,  String desc)?  $default,) {final _that = this;
switch (_that) {
case _TutorialStep() when $default != null:
return $default(_that.title,_that.desc);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TutorialStep implements TutorialStep {
  const _TutorialStep({required this.title, required this.desc});
  factory _TutorialStep.fromJson(Map<String, dynamic> json) => _$TutorialStepFromJson(json);

@override final  String title;
@override final  String desc;

/// Create a copy of TutorialStep
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TutorialStepCopyWith<_TutorialStep> get copyWith => __$TutorialStepCopyWithImpl<_TutorialStep>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TutorialStepToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TutorialStep&&(identical(other.title, title) || other.title == title)&&(identical(other.desc, desc) || other.desc == desc));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,desc);

@override
String toString() {
  return 'TutorialStep(title: $title, desc: $desc)';
}


}

/// @nodoc
abstract mixin class _$TutorialStepCopyWith<$Res> implements $TutorialStepCopyWith<$Res> {
  factory _$TutorialStepCopyWith(_TutorialStep value, $Res Function(_TutorialStep) _then) = __$TutorialStepCopyWithImpl;
@override @useResult
$Res call({
 String title, String desc
});




}
/// @nodoc
class __$TutorialStepCopyWithImpl<$Res>
    implements _$TutorialStepCopyWith<$Res> {
  __$TutorialStepCopyWithImpl(this._self, this._then);

  final _TutorialStep _self;
  final $Res Function(_TutorialStep) _then;

/// Create a copy of TutorialStep
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? desc = null,}) {
  return _then(_TutorialStep(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,desc: null == desc ? _self.desc : desc // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$PlatformData {

 String get key; String get name; String get emoji; String get iconText; bool get connected; int get orderEstimate;@ColorConverter() List<Color> get gradientColors; List<TutorialStep> get steps;
/// Create a copy of PlatformData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlatformDataCopyWith<PlatformData> get copyWith => _$PlatformDataCopyWithImpl<PlatformData>(this as PlatformData, _$identity);

  /// Serializes this PlatformData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlatformData&&(identical(other.key, key) || other.key == key)&&(identical(other.name, name) || other.name == name)&&(identical(other.emoji, emoji) || other.emoji == emoji)&&(identical(other.iconText, iconText) || other.iconText == iconText)&&(identical(other.connected, connected) || other.connected == connected)&&(identical(other.orderEstimate, orderEstimate) || other.orderEstimate == orderEstimate)&&const DeepCollectionEquality().equals(other.gradientColors, gradientColors)&&const DeepCollectionEquality().equals(other.steps, steps));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,key,name,emoji,iconText,connected,orderEstimate,const DeepCollectionEquality().hash(gradientColors),const DeepCollectionEquality().hash(steps));

@override
String toString() {
  return 'PlatformData(key: $key, name: $name, emoji: $emoji, iconText: $iconText, connected: $connected, orderEstimate: $orderEstimate, gradientColors: $gradientColors, steps: $steps)';
}


}

/// @nodoc
abstract mixin class $PlatformDataCopyWith<$Res>  {
  factory $PlatformDataCopyWith(PlatformData value, $Res Function(PlatformData) _then) = _$PlatformDataCopyWithImpl;
@useResult
$Res call({
 String key, String name, String emoji, String iconText, bool connected, int orderEstimate,@ColorConverter() List<Color> gradientColors, List<TutorialStep> steps
});




}
/// @nodoc
class _$PlatformDataCopyWithImpl<$Res>
    implements $PlatformDataCopyWith<$Res> {
  _$PlatformDataCopyWithImpl(this._self, this._then);

  final PlatformData _self;
  final $Res Function(PlatformData) _then;

/// Create a copy of PlatformData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? key = null,Object? name = null,Object? emoji = null,Object? iconText = null,Object? connected = null,Object? orderEstimate = null,Object? gradientColors = null,Object? steps = null,}) {
  return _then(_self.copyWith(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,emoji: null == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String,iconText: null == iconText ? _self.iconText : iconText // ignore: cast_nullable_to_non_nullable
as String,connected: null == connected ? _self.connected : connected // ignore: cast_nullable_to_non_nullable
as bool,orderEstimate: null == orderEstimate ? _self.orderEstimate : orderEstimate // ignore: cast_nullable_to_non_nullable
as int,gradientColors: null == gradientColors ? _self.gradientColors : gradientColors // ignore: cast_nullable_to_non_nullable
as List<Color>,steps: null == steps ? _self.steps : steps // ignore: cast_nullable_to_non_nullable
as List<TutorialStep>,
  ));
}

}


/// Adds pattern-matching-related methods to [PlatformData].
extension PlatformDataPatterns on PlatformData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlatformData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlatformData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlatformData value)  $default,){
final _that = this;
switch (_that) {
case _PlatformData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlatformData value)?  $default,){
final _that = this;
switch (_that) {
case _PlatformData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String key,  String name,  String emoji,  String iconText,  bool connected,  int orderEstimate, @ColorConverter()  List<Color> gradientColors,  List<TutorialStep> steps)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlatformData() when $default != null:
return $default(_that.key,_that.name,_that.emoji,_that.iconText,_that.connected,_that.orderEstimate,_that.gradientColors,_that.steps);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String key,  String name,  String emoji,  String iconText,  bool connected,  int orderEstimate, @ColorConverter()  List<Color> gradientColors,  List<TutorialStep> steps)  $default,) {final _that = this;
switch (_that) {
case _PlatformData():
return $default(_that.key,_that.name,_that.emoji,_that.iconText,_that.connected,_that.orderEstimate,_that.gradientColors,_that.steps);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String key,  String name,  String emoji,  String iconText,  bool connected,  int orderEstimate, @ColorConverter()  List<Color> gradientColors,  List<TutorialStep> steps)?  $default,) {final _that = this;
switch (_that) {
case _PlatformData() when $default != null:
return $default(_that.key,_that.name,_that.emoji,_that.iconText,_that.connected,_that.orderEstimate,_that.gradientColors,_that.steps);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PlatformData implements PlatformData {
  const _PlatformData({required this.key, required this.name, required this.emoji, required this.iconText, required this.connected, required this.orderEstimate, @ColorConverter() required final  List<Color> gradientColors, required final  List<TutorialStep> steps}): _gradientColors = gradientColors,_steps = steps;
  factory _PlatformData.fromJson(Map<String, dynamic> json) => _$PlatformDataFromJson(json);

@override final  String key;
@override final  String name;
@override final  String emoji;
@override final  String iconText;
@override final  bool connected;
@override final  int orderEstimate;
 final  List<Color> _gradientColors;
@override@ColorConverter() List<Color> get gradientColors {
  if (_gradientColors is EqualUnmodifiableListView) return _gradientColors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_gradientColors);
}

 final  List<TutorialStep> _steps;
@override List<TutorialStep> get steps {
  if (_steps is EqualUnmodifiableListView) return _steps;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_steps);
}


/// Create a copy of PlatformData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlatformDataCopyWith<_PlatformData> get copyWith => __$PlatformDataCopyWithImpl<_PlatformData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlatformDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlatformData&&(identical(other.key, key) || other.key == key)&&(identical(other.name, name) || other.name == name)&&(identical(other.emoji, emoji) || other.emoji == emoji)&&(identical(other.iconText, iconText) || other.iconText == iconText)&&(identical(other.connected, connected) || other.connected == connected)&&(identical(other.orderEstimate, orderEstimate) || other.orderEstimate == orderEstimate)&&const DeepCollectionEquality().equals(other._gradientColors, _gradientColors)&&const DeepCollectionEquality().equals(other._steps, _steps));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,key,name,emoji,iconText,connected,orderEstimate,const DeepCollectionEquality().hash(_gradientColors),const DeepCollectionEquality().hash(_steps));

@override
String toString() {
  return 'PlatformData(key: $key, name: $name, emoji: $emoji, iconText: $iconText, connected: $connected, orderEstimate: $orderEstimate, gradientColors: $gradientColors, steps: $steps)';
}


}

/// @nodoc
abstract mixin class _$PlatformDataCopyWith<$Res> implements $PlatformDataCopyWith<$Res> {
  factory _$PlatformDataCopyWith(_PlatformData value, $Res Function(_PlatformData) _then) = __$PlatformDataCopyWithImpl;
@override @useResult
$Res call({
 String key, String name, String emoji, String iconText, bool connected, int orderEstimate,@ColorConverter() List<Color> gradientColors, List<TutorialStep> steps
});




}
/// @nodoc
class __$PlatformDataCopyWithImpl<$Res>
    implements _$PlatformDataCopyWith<$Res> {
  __$PlatformDataCopyWithImpl(this._self, this._then);

  final _PlatformData _self;
  final $Res Function(_PlatformData) _then;

/// Create a copy of PlatformData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? key = null,Object? name = null,Object? emoji = null,Object? iconText = null,Object? connected = null,Object? orderEstimate = null,Object? gradientColors = null,Object? steps = null,}) {
  return _then(_PlatformData(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,emoji: null == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String,iconText: null == iconText ? _self.iconText : iconText // ignore: cast_nullable_to_non_nullable
as String,connected: null == connected ? _self.connected : connected // ignore: cast_nullable_to_non_nullable
as bool,orderEstimate: null == orderEstimate ? _self.orderEstimate : orderEstimate // ignore: cast_nullable_to_non_nullable
as int,gradientColors: null == gradientColors ? _self._gradientColors : gradientColors // ignore: cast_nullable_to_non_nullable
as List<Color>,steps: null == steps ? _self._steps : steps // ignore: cast_nullable_to_non_nullable
as List<TutorialStep>,
  ));
}


}

// dart format on
