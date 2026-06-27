// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../template.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TemplateField {

 String get label; String get placeholder; String get id; bool get isDate;
/// Create a copy of TemplateField
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TemplateFieldCopyWith<TemplateField> get copyWith => _$TemplateFieldCopyWithImpl<TemplateField>(this as TemplateField, _$identity);

  /// Serializes this TemplateField to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TemplateField&&(identical(other.label, label) || other.label == label)&&(identical(other.placeholder, placeholder) || other.placeholder == placeholder)&&(identical(other.id, id) || other.id == id)&&(identical(other.isDate, isDate) || other.isDate == isDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,label,placeholder,id,isDate);

@override
String toString() {
  return 'TemplateField(label: $label, placeholder: $placeholder, id: $id, isDate: $isDate)';
}


}

/// @nodoc
abstract mixin class $TemplateFieldCopyWith<$Res>  {
  factory $TemplateFieldCopyWith(TemplateField value, $Res Function(TemplateField) _then) = _$TemplateFieldCopyWithImpl;
@useResult
$Res call({
 String label, String placeholder, String id, bool isDate
});




}
/// @nodoc
class _$TemplateFieldCopyWithImpl<$Res>
    implements $TemplateFieldCopyWith<$Res> {
  _$TemplateFieldCopyWithImpl(this._self, this._then);

  final TemplateField _self;
  final $Res Function(TemplateField) _then;

/// Create a copy of TemplateField
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? label = null,Object? placeholder = null,Object? id = null,Object? isDate = null,}) {
  return _then(_self.copyWith(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,placeholder: null == placeholder ? _self.placeholder : placeholder // ignore: cast_nullable_to_non_nullable
as String,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,isDate: null == isDate ? _self.isDate : isDate // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [TemplateField].
extension TemplateFieldPatterns on TemplateField {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TemplateField value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TemplateField() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TemplateField value)  $default,){
final _that = this;
switch (_that) {
case _TemplateField():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TemplateField value)?  $default,){
final _that = this;
switch (_that) {
case _TemplateField() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String label,  String placeholder,  String id,  bool isDate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TemplateField() when $default != null:
return $default(_that.label,_that.placeholder,_that.id,_that.isDate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String label,  String placeholder,  String id,  bool isDate)  $default,) {final _that = this;
switch (_that) {
case _TemplateField():
return $default(_that.label,_that.placeholder,_that.id,_that.isDate);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String label,  String placeholder,  String id,  bool isDate)?  $default,) {final _that = this;
switch (_that) {
case _TemplateField() when $default != null:
return $default(_that.label,_that.placeholder,_that.id,_that.isDate);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TemplateField implements TemplateField {
  const _TemplateField({required this.label, required this.placeholder, required this.id, this.isDate = false});
  factory _TemplateField.fromJson(Map<String, dynamic> json) => _$TemplateFieldFromJson(json);

@override final  String label;
@override final  String placeholder;
@override final  String id;
@override@JsonKey() final  bool isDate;

/// Create a copy of TemplateField
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TemplateFieldCopyWith<_TemplateField> get copyWith => __$TemplateFieldCopyWithImpl<_TemplateField>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TemplateFieldToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TemplateField&&(identical(other.label, label) || other.label == label)&&(identical(other.placeholder, placeholder) || other.placeholder == placeholder)&&(identical(other.id, id) || other.id == id)&&(identical(other.isDate, isDate) || other.isDate == isDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,label,placeholder,id,isDate);

@override
String toString() {
  return 'TemplateField(label: $label, placeholder: $placeholder, id: $id, isDate: $isDate)';
}


}

/// @nodoc
abstract mixin class _$TemplateFieldCopyWith<$Res> implements $TemplateFieldCopyWith<$Res> {
  factory _$TemplateFieldCopyWith(_TemplateField value, $Res Function(_TemplateField) _then) = __$TemplateFieldCopyWithImpl;
@override @useResult
$Res call({
 String label, String placeholder, String id, bool isDate
});




}
/// @nodoc
class __$TemplateFieldCopyWithImpl<$Res>
    implements _$TemplateFieldCopyWith<$Res> {
  __$TemplateFieldCopyWithImpl(this._self, this._then);

  final _TemplateField _self;
  final $Res Function(_TemplateField) _then;

/// Create a copy of TemplateField
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? label = null,Object? placeholder = null,Object? id = null,Object? isDate = null,}) {
  return _then(_TemplateField(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,placeholder: null == placeholder ? _self.placeholder : placeholder // ignore: cast_nullable_to_non_nullable
as String,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,isDate: null == isDate ? _self.isDate : isDate // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$TemplateData {

 String get name; List<TemplateField> get fields;
/// Create a copy of TemplateData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TemplateDataCopyWith<TemplateData> get copyWith => _$TemplateDataCopyWithImpl<TemplateData>(this as TemplateData, _$identity);

  /// Serializes this TemplateData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TemplateData&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.fields, fields));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,const DeepCollectionEquality().hash(fields));

@override
String toString() {
  return 'TemplateData(name: $name, fields: $fields)';
}


}

/// @nodoc
abstract mixin class $TemplateDataCopyWith<$Res>  {
  factory $TemplateDataCopyWith(TemplateData value, $Res Function(TemplateData) _then) = _$TemplateDataCopyWithImpl;
@useResult
$Res call({
 String name, List<TemplateField> fields
});




}
/// @nodoc
class _$TemplateDataCopyWithImpl<$Res>
    implements $TemplateDataCopyWith<$Res> {
  _$TemplateDataCopyWithImpl(this._self, this._then);

  final TemplateData _self;
  final $Res Function(TemplateData) _then;

/// Create a copy of TemplateData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? fields = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,fields: null == fields ? _self.fields : fields // ignore: cast_nullable_to_non_nullable
as List<TemplateField>,
  ));
}

}


/// Adds pattern-matching-related methods to [TemplateData].
extension TemplateDataPatterns on TemplateData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TemplateData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TemplateData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TemplateData value)  $default,){
final _that = this;
switch (_that) {
case _TemplateData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TemplateData value)?  $default,){
final _that = this;
switch (_that) {
case _TemplateData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  List<TemplateField> fields)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TemplateData() when $default != null:
return $default(_that.name,_that.fields);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  List<TemplateField> fields)  $default,) {final _that = this;
switch (_that) {
case _TemplateData():
return $default(_that.name,_that.fields);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  List<TemplateField> fields)?  $default,) {final _that = this;
switch (_that) {
case _TemplateData() when $default != null:
return $default(_that.name,_that.fields);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TemplateData implements TemplateData {
  const _TemplateData({required this.name, required final  List<TemplateField> fields}): _fields = fields;
  factory _TemplateData.fromJson(Map<String, dynamic> json) => _$TemplateDataFromJson(json);

@override final  String name;
 final  List<TemplateField> _fields;
@override List<TemplateField> get fields {
  if (_fields is EqualUnmodifiableListView) return _fields;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_fields);
}


/// Create a copy of TemplateData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TemplateDataCopyWith<_TemplateData> get copyWith => __$TemplateDataCopyWithImpl<_TemplateData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TemplateDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TemplateData&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other._fields, _fields));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,const DeepCollectionEquality().hash(_fields));

@override
String toString() {
  return 'TemplateData(name: $name, fields: $fields)';
}


}

/// @nodoc
abstract mixin class _$TemplateDataCopyWith<$Res> implements $TemplateDataCopyWith<$Res> {
  factory _$TemplateDataCopyWith(_TemplateData value, $Res Function(_TemplateData) _then) = __$TemplateDataCopyWithImpl;
@override @useResult
$Res call({
 String name, List<TemplateField> fields
});




}
/// @nodoc
class __$TemplateDataCopyWithImpl<$Res>
    implements _$TemplateDataCopyWith<$Res> {
  __$TemplateDataCopyWithImpl(this._self, this._then);

  final _TemplateData _self;
  final $Res Function(_TemplateData) _then;

/// Create a copy of TemplateData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? fields = null,}) {
  return _then(_TemplateData(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,fields: null == fields ? _self._fields : fields // ignore: cast_nullable_to_non_nullable
as List<TemplateField>,
  ));
}


}

// dart format on
