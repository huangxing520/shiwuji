// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Item {

 String get id; String get name; double get price; String get emoji; String get category; String get location; DateTime get purchaseDate; int get warrantyDays; int get shelfLifeDays; String get status; String get categoryKey; String? get cabinetId; String? get slotId; List<String> get photos; String get brand; String get note; String get templateKey; Map<String, String> get templateData; String get source; bool get warrantyReminderOn; bool get shelfLifeReminderOn; bool get maintenanceReminderOn; String get maintenanceCycle;
/// Create a copy of Item
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ItemCopyWith<Item> get copyWith => _$ItemCopyWithImpl<Item>(this as Item, _$identity);

  /// Serializes this Item to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Item&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.price, price) || other.price == price)&&(identical(other.emoji, emoji) || other.emoji == emoji)&&(identical(other.category, category) || other.category == category)&&(identical(other.location, location) || other.location == location)&&(identical(other.purchaseDate, purchaseDate) || other.purchaseDate == purchaseDate)&&(identical(other.warrantyDays, warrantyDays) || other.warrantyDays == warrantyDays)&&(identical(other.shelfLifeDays, shelfLifeDays) || other.shelfLifeDays == shelfLifeDays)&&(identical(other.status, status) || other.status == status)&&(identical(other.categoryKey, categoryKey) || other.categoryKey == categoryKey)&&(identical(other.cabinetId, cabinetId) || other.cabinetId == cabinetId)&&(identical(other.slotId, slotId) || other.slotId == slotId)&&const DeepCollectionEquality().equals(other.photos, photos)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.note, note) || other.note == note)&&(identical(other.templateKey, templateKey) || other.templateKey == templateKey)&&const DeepCollectionEquality().equals(other.templateData, templateData)&&(identical(other.source, source) || other.source == source)&&(identical(other.warrantyReminderOn, warrantyReminderOn) || other.warrantyReminderOn == warrantyReminderOn)&&(identical(other.shelfLifeReminderOn, shelfLifeReminderOn) || other.shelfLifeReminderOn == shelfLifeReminderOn)&&(identical(other.maintenanceReminderOn, maintenanceReminderOn) || other.maintenanceReminderOn == maintenanceReminderOn)&&(identical(other.maintenanceCycle, maintenanceCycle) || other.maintenanceCycle == maintenanceCycle));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,name,price,emoji,category,location,purchaseDate,warrantyDays,shelfLifeDays,status,categoryKey,cabinetId,slotId,const DeepCollectionEquality().hash(photos),brand,note,templateKey,const DeepCollectionEquality().hash(templateData),source,warrantyReminderOn,shelfLifeReminderOn,maintenanceReminderOn,maintenanceCycle]);

@override
String toString() {
  return 'Item(id: $id, name: $name, price: $price, emoji: $emoji, category: $category, location: $location, purchaseDate: $purchaseDate, warrantyDays: $warrantyDays, shelfLifeDays: $shelfLifeDays, status: $status, categoryKey: $categoryKey, cabinetId: $cabinetId, slotId: $slotId, photos: $photos, brand: $brand, note: $note, templateKey: $templateKey, templateData: $templateData, source: $source, warrantyReminderOn: $warrantyReminderOn, shelfLifeReminderOn: $shelfLifeReminderOn, maintenanceReminderOn: $maintenanceReminderOn, maintenanceCycle: $maintenanceCycle)';
}


}

/// @nodoc
abstract mixin class $ItemCopyWith<$Res>  {
  factory $ItemCopyWith(Item value, $Res Function(Item) _then) = _$ItemCopyWithImpl;
@useResult
$Res call({
 String id, String name, double price, String emoji, String category, String location, DateTime purchaseDate, int warrantyDays, int shelfLifeDays, String status, String categoryKey, String? cabinetId, String? slotId, List<String> photos, String brand, String note, String templateKey, Map<String, String> templateData, String source, bool warrantyReminderOn, bool shelfLifeReminderOn, bool maintenanceReminderOn, String maintenanceCycle
});




}
/// @nodoc
class _$ItemCopyWithImpl<$Res>
    implements $ItemCopyWith<$Res> {
  _$ItemCopyWithImpl(this._self, this._then);

  final Item _self;
  final $Res Function(Item) _then;

/// Create a copy of Item
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? price = null,Object? emoji = null,Object? category = null,Object? location = null,Object? purchaseDate = null,Object? warrantyDays = null,Object? shelfLifeDays = null,Object? status = null,Object? categoryKey = null,Object? cabinetId = freezed,Object? slotId = freezed,Object? photos = null,Object? brand = null,Object? note = null,Object? templateKey = null,Object? templateData = null,Object? source = null,Object? warrantyReminderOn = null,Object? shelfLifeReminderOn = null,Object? maintenanceReminderOn = null,Object? maintenanceCycle = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,emoji: null == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String,purchaseDate: null == purchaseDate ? _self.purchaseDate : purchaseDate // ignore: cast_nullable_to_non_nullable
as DateTime,warrantyDays: null == warrantyDays ? _self.warrantyDays : warrantyDays // ignore: cast_nullable_to_non_nullable
as int,shelfLifeDays: null == shelfLifeDays ? _self.shelfLifeDays : shelfLifeDays // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,categoryKey: null == categoryKey ? _self.categoryKey : categoryKey // ignore: cast_nullable_to_non_nullable
as String,cabinetId: freezed == cabinetId ? _self.cabinetId : cabinetId // ignore: cast_nullable_to_non_nullable
as String?,slotId: freezed == slotId ? _self.slotId : slotId // ignore: cast_nullable_to_non_nullable
as String?,photos: null == photos ? _self.photos : photos // ignore: cast_nullable_to_non_nullable
as List<String>,brand: null == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String,note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String,templateKey: null == templateKey ? _self.templateKey : templateKey // ignore: cast_nullable_to_non_nullable
as String,templateData: null == templateData ? _self.templateData : templateData // ignore: cast_nullable_to_non_nullable
as Map<String, String>,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,warrantyReminderOn: null == warrantyReminderOn ? _self.warrantyReminderOn : warrantyReminderOn // ignore: cast_nullable_to_non_nullable
as bool,shelfLifeReminderOn: null == shelfLifeReminderOn ? _self.shelfLifeReminderOn : shelfLifeReminderOn // ignore: cast_nullable_to_non_nullable
as bool,maintenanceReminderOn: null == maintenanceReminderOn ? _self.maintenanceReminderOn : maintenanceReminderOn // ignore: cast_nullable_to_non_nullable
as bool,maintenanceCycle: null == maintenanceCycle ? _self.maintenanceCycle : maintenanceCycle // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Item].
extension ItemPatterns on Item {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Item value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Item() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Item value)  $default,){
final _that = this;
switch (_that) {
case _Item():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Item value)?  $default,){
final _that = this;
switch (_that) {
case _Item() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  double price,  String emoji,  String category,  String location,  DateTime purchaseDate,  int warrantyDays,  int shelfLifeDays,  String status,  String categoryKey,  String? cabinetId,  String? slotId,  List<String> photos,  String brand,  String note,  String templateKey,  Map<String, String> templateData,  String source,  bool warrantyReminderOn,  bool shelfLifeReminderOn,  bool maintenanceReminderOn,  String maintenanceCycle)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Item() when $default != null:
return $default(_that.id,_that.name,_that.price,_that.emoji,_that.category,_that.location,_that.purchaseDate,_that.warrantyDays,_that.shelfLifeDays,_that.status,_that.categoryKey,_that.cabinetId,_that.slotId,_that.photos,_that.brand,_that.note,_that.templateKey,_that.templateData,_that.source,_that.warrantyReminderOn,_that.shelfLifeReminderOn,_that.maintenanceReminderOn,_that.maintenanceCycle);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  double price,  String emoji,  String category,  String location,  DateTime purchaseDate,  int warrantyDays,  int shelfLifeDays,  String status,  String categoryKey,  String? cabinetId,  String? slotId,  List<String> photos,  String brand,  String note,  String templateKey,  Map<String, String> templateData,  String source,  bool warrantyReminderOn,  bool shelfLifeReminderOn,  bool maintenanceReminderOn,  String maintenanceCycle)  $default,) {final _that = this;
switch (_that) {
case _Item():
return $default(_that.id,_that.name,_that.price,_that.emoji,_that.category,_that.location,_that.purchaseDate,_that.warrantyDays,_that.shelfLifeDays,_that.status,_that.categoryKey,_that.cabinetId,_that.slotId,_that.photos,_that.brand,_that.note,_that.templateKey,_that.templateData,_that.source,_that.warrantyReminderOn,_that.shelfLifeReminderOn,_that.maintenanceReminderOn,_that.maintenanceCycle);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  double price,  String emoji,  String category,  String location,  DateTime purchaseDate,  int warrantyDays,  int shelfLifeDays,  String status,  String categoryKey,  String? cabinetId,  String? slotId,  List<String> photos,  String brand,  String note,  String templateKey,  Map<String, String> templateData,  String source,  bool warrantyReminderOn,  bool shelfLifeReminderOn,  bool maintenanceReminderOn,  String maintenanceCycle)?  $default,) {final _that = this;
switch (_that) {
case _Item() when $default != null:
return $default(_that.id,_that.name,_that.price,_that.emoji,_that.category,_that.location,_that.purchaseDate,_that.warrantyDays,_that.shelfLifeDays,_that.status,_that.categoryKey,_that.cabinetId,_that.slotId,_that.photos,_that.brand,_that.note,_that.templateKey,_that.templateData,_that.source,_that.warrantyReminderOn,_that.shelfLifeReminderOn,_that.maintenanceReminderOn,_that.maintenanceCycle);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Item extends Item {
  const _Item({required this.id, required this.name, required this.price, this.emoji = '', this.category = '未分类', this.location = '未知', required this.purchaseDate, this.warrantyDays = 0, this.shelfLifeDays = 0, this.status = 'safe', this.categoryKey = '', this.cabinetId, this.slotId, final  List<String> photos = const [], this.brand = '', this.note = '', this.templateKey = 'none', final  Map<String, String> templateData = const {}, this.source = '线下购买', this.warrantyReminderOn = false, this.shelfLifeReminderOn = false, this.maintenanceReminderOn = false, this.maintenanceCycle = ''}): _photos = photos,_templateData = templateData,super._();
  factory _Item.fromJson(Map<String, dynamic> json) => _$ItemFromJson(json);

@override final  String id;
@override final  String name;
@override final  double price;
@override@JsonKey() final  String emoji;
@override@JsonKey() final  String category;
@override@JsonKey() final  String location;
@override final  DateTime purchaseDate;
@override@JsonKey() final  int warrantyDays;
@override@JsonKey() final  int shelfLifeDays;
@override@JsonKey() final  String status;
@override@JsonKey() final  String categoryKey;
@override final  String? cabinetId;
@override final  String? slotId;
 final  List<String> _photos;
@override@JsonKey() List<String> get photos {
  if (_photos is EqualUnmodifiableListView) return _photos;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_photos);
}

@override@JsonKey() final  String brand;
@override@JsonKey() final  String note;
@override@JsonKey() final  String templateKey;
 final  Map<String, String> _templateData;
@override@JsonKey() Map<String, String> get templateData {
  if (_templateData is EqualUnmodifiableMapView) return _templateData;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_templateData);
}

@override@JsonKey() final  String source;
@override@JsonKey() final  bool warrantyReminderOn;
@override@JsonKey() final  bool shelfLifeReminderOn;
@override@JsonKey() final  bool maintenanceReminderOn;
@override@JsonKey() final  String maintenanceCycle;

/// Create a copy of Item
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ItemCopyWith<_Item> get copyWith => __$ItemCopyWithImpl<_Item>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Item&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.price, price) || other.price == price)&&(identical(other.emoji, emoji) || other.emoji == emoji)&&(identical(other.category, category) || other.category == category)&&(identical(other.location, location) || other.location == location)&&(identical(other.purchaseDate, purchaseDate) || other.purchaseDate == purchaseDate)&&(identical(other.warrantyDays, warrantyDays) || other.warrantyDays == warrantyDays)&&(identical(other.shelfLifeDays, shelfLifeDays) || other.shelfLifeDays == shelfLifeDays)&&(identical(other.status, status) || other.status == status)&&(identical(other.categoryKey, categoryKey) || other.categoryKey == categoryKey)&&(identical(other.cabinetId, cabinetId) || other.cabinetId == cabinetId)&&(identical(other.slotId, slotId) || other.slotId == slotId)&&const DeepCollectionEquality().equals(other._photos, _photos)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.note, note) || other.note == note)&&(identical(other.templateKey, templateKey) || other.templateKey == templateKey)&&const DeepCollectionEquality().equals(other._templateData, _templateData)&&(identical(other.source, source) || other.source == source)&&(identical(other.warrantyReminderOn, warrantyReminderOn) || other.warrantyReminderOn == warrantyReminderOn)&&(identical(other.shelfLifeReminderOn, shelfLifeReminderOn) || other.shelfLifeReminderOn == shelfLifeReminderOn)&&(identical(other.maintenanceReminderOn, maintenanceReminderOn) || other.maintenanceReminderOn == maintenanceReminderOn)&&(identical(other.maintenanceCycle, maintenanceCycle) || other.maintenanceCycle == maintenanceCycle));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,name,price,emoji,category,location,purchaseDate,warrantyDays,shelfLifeDays,status,categoryKey,cabinetId,slotId,const DeepCollectionEquality().hash(_photos),brand,note,templateKey,const DeepCollectionEquality().hash(_templateData),source,warrantyReminderOn,shelfLifeReminderOn,maintenanceReminderOn,maintenanceCycle]);

@override
String toString() {
  return 'Item(id: $id, name: $name, price: $price, emoji: $emoji, category: $category, location: $location, purchaseDate: $purchaseDate, warrantyDays: $warrantyDays, shelfLifeDays: $shelfLifeDays, status: $status, categoryKey: $categoryKey, cabinetId: $cabinetId, slotId: $slotId, photos: $photos, brand: $brand, note: $note, templateKey: $templateKey, templateData: $templateData, source: $source, warrantyReminderOn: $warrantyReminderOn, shelfLifeReminderOn: $shelfLifeReminderOn, maintenanceReminderOn: $maintenanceReminderOn, maintenanceCycle: $maintenanceCycle)';
}


}

/// @nodoc
abstract mixin class _$ItemCopyWith<$Res> implements $ItemCopyWith<$Res> {
  factory _$ItemCopyWith(_Item value, $Res Function(_Item) _then) = __$ItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, double price, String emoji, String category, String location, DateTime purchaseDate, int warrantyDays, int shelfLifeDays, String status, String categoryKey, String? cabinetId, String? slotId, List<String> photos, String brand, String note, String templateKey, Map<String, String> templateData, String source, bool warrantyReminderOn, bool shelfLifeReminderOn, bool maintenanceReminderOn, String maintenanceCycle
});




}
/// @nodoc
class __$ItemCopyWithImpl<$Res>
    implements _$ItemCopyWith<$Res> {
  __$ItemCopyWithImpl(this._self, this._then);

  final _Item _self;
  final $Res Function(_Item) _then;

/// Create a copy of Item
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? price = null,Object? emoji = null,Object? category = null,Object? location = null,Object? purchaseDate = null,Object? warrantyDays = null,Object? shelfLifeDays = null,Object? status = null,Object? categoryKey = null,Object? cabinetId = freezed,Object? slotId = freezed,Object? photos = null,Object? brand = null,Object? note = null,Object? templateKey = null,Object? templateData = null,Object? source = null,Object? warrantyReminderOn = null,Object? shelfLifeReminderOn = null,Object? maintenanceReminderOn = null,Object? maintenanceCycle = null,}) {
  return _then(_Item(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,emoji: null == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String,purchaseDate: null == purchaseDate ? _self.purchaseDate : purchaseDate // ignore: cast_nullable_to_non_nullable
as DateTime,warrantyDays: null == warrantyDays ? _self.warrantyDays : warrantyDays // ignore: cast_nullable_to_non_nullable
as int,shelfLifeDays: null == shelfLifeDays ? _self.shelfLifeDays : shelfLifeDays // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,categoryKey: null == categoryKey ? _self.categoryKey : categoryKey // ignore: cast_nullable_to_non_nullable
as String,cabinetId: freezed == cabinetId ? _self.cabinetId : cabinetId // ignore: cast_nullable_to_non_nullable
as String?,slotId: freezed == slotId ? _self.slotId : slotId // ignore: cast_nullable_to_non_nullable
as String?,photos: null == photos ? _self._photos : photos // ignore: cast_nullable_to_non_nullable
as List<String>,brand: null == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String,note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String,templateKey: null == templateKey ? _self.templateKey : templateKey // ignore: cast_nullable_to_non_nullable
as String,templateData: null == templateData ? _self._templateData : templateData // ignore: cast_nullable_to_non_nullable
as Map<String, String>,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,warrantyReminderOn: null == warrantyReminderOn ? _self.warrantyReminderOn : warrantyReminderOn // ignore: cast_nullable_to_non_nullable
as bool,shelfLifeReminderOn: null == shelfLifeReminderOn ? _self.shelfLifeReminderOn : shelfLifeReminderOn // ignore: cast_nullable_to_non_nullable
as bool,maintenanceReminderOn: null == maintenanceReminderOn ? _self.maintenanceReminderOn : maintenanceReminderOn // ignore: cast_nullable_to_non_nullable
as bool,maintenanceCycle: null == maintenanceCycle ? _self.maintenanceCycle : maintenanceCycle // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
