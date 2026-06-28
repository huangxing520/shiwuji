// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../database.dart';

// ignore_for_file: type=lint
class $ItemsTable extends Items with TableInfo<$ItemsTable, Item> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _priceMeta = const VerificationMeta('price');
  @override
  late final GeneratedColumn<double> price = GeneratedColumn<double>(
    'price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emojiMeta = const VerificationMeta('emoji');
  @override
  late final GeneratedColumn<String> emoji = GeneratedColumn<String>(
    'emoji',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('未分类'),
  );
  static const VerificationMeta _locationMeta = const VerificationMeta(
    'location',
  );
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
    'location',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('未知'),
  );
  static const VerificationMeta _purchaseDateMeta = const VerificationMeta(
    'purchaseDate',
  );
  @override
  late final GeneratedColumn<DateTime> purchaseDate = GeneratedColumn<DateTime>(
    'purchase_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _warrantyDaysMeta = const VerificationMeta(
    'warrantyDays',
  );
  @override
  late final GeneratedColumn<int> warrantyDays = GeneratedColumn<int>(
    'warranty_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(365),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('safe'),
  );
  static const VerificationMeta _categoryKeyMeta = const VerificationMeta(
    'categoryKey',
  );
  @override
  late final GeneratedColumn<String> categoryKey = GeneratedColumn<String>(
    'category_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _cabinetIdMeta = const VerificationMeta(
    'cabinetId',
  );
  @override
  late final GeneratedColumn<String> cabinetId = GeneratedColumn<String>(
    'cabinet_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _slotIdMeta = const VerificationMeta('slotId');
  @override
  late final GeneratedColumn<String> slotId = GeneratedColumn<String>(
    'slot_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _photosMeta = const VerificationMeta('photos');
  @override
  late final GeneratedColumn<String> photos = GeneratedColumn<String>(
    'photos',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _brandMeta = const VerificationMeta('brand');
  @override
  late final GeneratedColumn<String> brand = GeneratedColumn<String>(
    'brand',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _templateKeyMeta = const VerificationMeta(
    'templateKey',
  );
  @override
  late final GeneratedColumn<String> templateKey = GeneratedColumn<String>(
    'template_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('none'),
  );
  static const VerificationMeta _templateDataMeta = const VerificationMeta(
    'templateData',
  );
  @override
  late final GeneratedColumn<String> templateData = GeneratedColumn<String>(
    'template_data',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    price,
    emoji,
    category,
    location,
    purchaseDate,
    warrantyDays,
    status,
    categoryKey,
    cabinetId,
    slotId,
    photos,
    brand,
    note,
    templateKey,
    templateData,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'items';
  @override
  VerificationContext validateIntegrity(
    Insertable<Item> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('price')) {
      context.handle(
        _priceMeta,
        price.isAcceptableOrUnknown(data['price']!, _priceMeta),
      );
    } else if (isInserting) {
      context.missing(_priceMeta);
    }
    if (data.containsKey('emoji')) {
      context.handle(
        _emojiMeta,
        emoji.isAcceptableOrUnknown(data['emoji']!, _emojiMeta),
      );
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('location')) {
      context.handle(
        _locationMeta,
        location.isAcceptableOrUnknown(data['location']!, _locationMeta),
      );
    }
    if (data.containsKey('purchase_date')) {
      context.handle(
        _purchaseDateMeta,
        purchaseDate.isAcceptableOrUnknown(
          data['purchase_date']!,
          _purchaseDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_purchaseDateMeta);
    }
    if (data.containsKey('warranty_days')) {
      context.handle(
        _warrantyDaysMeta,
        warrantyDays.isAcceptableOrUnknown(
          data['warranty_days']!,
          _warrantyDaysMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('category_key')) {
      context.handle(
        _categoryKeyMeta,
        categoryKey.isAcceptableOrUnknown(
          data['category_key']!,
          _categoryKeyMeta,
        ),
      );
    }
    if (data.containsKey('cabinet_id')) {
      context.handle(
        _cabinetIdMeta,
        cabinetId.isAcceptableOrUnknown(data['cabinet_id']!, _cabinetIdMeta),
      );
    }
    if (data.containsKey('slot_id')) {
      context.handle(
        _slotIdMeta,
        slotId.isAcceptableOrUnknown(data['slot_id']!, _slotIdMeta),
      );
    }
    if (data.containsKey('photos')) {
      context.handle(
        _photosMeta,
        photos.isAcceptableOrUnknown(data['photos']!, _photosMeta),
      );
    }
    if (data.containsKey('brand')) {
      context.handle(
        _brandMeta,
        brand.isAcceptableOrUnknown(data['brand']!, _brandMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('template_key')) {
      context.handle(
        _templateKeyMeta,
        templateKey.isAcceptableOrUnknown(
          data['template_key']!,
          _templateKeyMeta,
        ),
      );
    }
    if (data.containsKey('template_data')) {
      context.handle(
        _templateDataMeta,
        templateData.isAcceptableOrUnknown(
          data['template_data']!,
          _templateDataMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Item map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Item(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      price: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}price'],
      )!,
      emoji: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}emoji'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      location: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location'],
      )!,
      purchaseDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}purchase_date'],
      )!,
      warrantyDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}warranty_days'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      categoryKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_key'],
      )!,
      cabinetId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cabinet_id'],
      ),
      slotId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}slot_id'],
      ),
      photos: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photos'],
      )!,
      brand: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}brand'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      )!,
      templateKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}template_key'],
      )!,
      templateData: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}template_data'],
      )!,
    );
  }

  @override
  $ItemsTable createAlias(String alias) {
    return $ItemsTable(attachedDatabase, alias);
  }
}

class Item extends DataClass implements Insertable<Item> {
  final String id;
  final String name;
  final double price;
  final String emoji;
  final String category;
  final String location;
  final DateTime purchaseDate;
  final int warrantyDays;
  final String status;
  final String categoryKey;
  final String? cabinetId;
  final String? slotId;
  final String photos;
  final String brand;
  final String note;
  final String templateKey;
  final String templateData;
  const Item({
    required this.id,
    required this.name,
    required this.price,
    required this.emoji,
    required this.category,
    required this.location,
    required this.purchaseDate,
    required this.warrantyDays,
    required this.status,
    required this.categoryKey,
    this.cabinetId,
    this.slotId,
    required this.photos,
    required this.brand,
    required this.note,
    required this.templateKey,
    required this.templateData,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['price'] = Variable<double>(price);
    map['emoji'] = Variable<String>(emoji);
    map['category'] = Variable<String>(category);
    map['location'] = Variable<String>(location);
    map['purchase_date'] = Variable<DateTime>(purchaseDate);
    map['warranty_days'] = Variable<int>(warrantyDays);
    map['status'] = Variable<String>(status);
    map['category_key'] = Variable<String>(categoryKey);
    if (!nullToAbsent || cabinetId != null) {
      map['cabinet_id'] = Variable<String>(cabinetId);
    }
    if (!nullToAbsent || slotId != null) {
      map['slot_id'] = Variable<String>(slotId);
    }
    map['photos'] = Variable<String>(photos);
    map['brand'] = Variable<String>(brand);
    map['note'] = Variable<String>(note);
    map['template_key'] = Variable<String>(templateKey);
    map['template_data'] = Variable<String>(templateData);
    return map;
  }

  ItemsCompanion toCompanion(bool nullToAbsent) {
    return ItemsCompanion(
      id: Value(id),
      name: Value(name),
      price: Value(price),
      emoji: Value(emoji),
      category: Value(category),
      location: Value(location),
      purchaseDate: Value(purchaseDate),
      warrantyDays: Value(warrantyDays),
      status: Value(status),
      categoryKey: Value(categoryKey),
      cabinetId: cabinetId == null && nullToAbsent
          ? const Value.absent()
          : Value(cabinetId),
      slotId: slotId == null && nullToAbsent
          ? const Value.absent()
          : Value(slotId),
      photos: Value(photos),
      brand: Value(brand),
      note: Value(note),
      templateKey: Value(templateKey),
      templateData: Value(templateData),
    );
  }

  factory Item.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Item(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      price: serializer.fromJson<double>(json['price']),
      emoji: serializer.fromJson<String>(json['emoji']),
      category: serializer.fromJson<String>(json['category']),
      location: serializer.fromJson<String>(json['location']),
      purchaseDate: serializer.fromJson<DateTime>(json['purchaseDate']),
      warrantyDays: serializer.fromJson<int>(json['warrantyDays']),
      status: serializer.fromJson<String>(json['status']),
      categoryKey: serializer.fromJson<String>(json['categoryKey']),
      cabinetId: serializer.fromJson<String?>(json['cabinetId']),
      slotId: serializer.fromJson<String?>(json['slotId']),
      photos: serializer.fromJson<String>(json['photos']),
      brand: serializer.fromJson<String>(json['brand']),
      note: serializer.fromJson<String>(json['note']),
      templateKey: serializer.fromJson<String>(json['templateKey']),
      templateData: serializer.fromJson<String>(json['templateData']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'price': serializer.toJson<double>(price),
      'emoji': serializer.toJson<String>(emoji),
      'category': serializer.toJson<String>(category),
      'location': serializer.toJson<String>(location),
      'purchaseDate': serializer.toJson<DateTime>(purchaseDate),
      'warrantyDays': serializer.toJson<int>(warrantyDays),
      'status': serializer.toJson<String>(status),
      'categoryKey': serializer.toJson<String>(categoryKey),
      'cabinetId': serializer.toJson<String?>(cabinetId),
      'slotId': serializer.toJson<String?>(slotId),
      'photos': serializer.toJson<String>(photos),
      'brand': serializer.toJson<String>(brand),
      'note': serializer.toJson<String>(note),
      'templateKey': serializer.toJson<String>(templateKey),
      'templateData': serializer.toJson<String>(templateData),
    };
  }

  Item copyWith({
    String? id,
    String? name,
    double? price,
    String? emoji,
    String? category,
    String? location,
    DateTime? purchaseDate,
    int? warrantyDays,
    String? status,
    String? categoryKey,
    Value<String?> cabinetId = const Value.absent(),
    Value<String?> slotId = const Value.absent(),
    String? photos,
    String? brand,
    String? note,
    String? templateKey,
    String? templateData,
  }) => Item(
    id: id ?? this.id,
    name: name ?? this.name,
    price: price ?? this.price,
    emoji: emoji ?? this.emoji,
    category: category ?? this.category,
    location: location ?? this.location,
    purchaseDate: purchaseDate ?? this.purchaseDate,
    warrantyDays: warrantyDays ?? this.warrantyDays,
    status: status ?? this.status,
    categoryKey: categoryKey ?? this.categoryKey,
    cabinetId: cabinetId.present ? cabinetId.value : this.cabinetId,
    slotId: slotId.present ? slotId.value : this.slotId,
    photos: photos ?? this.photos,
    brand: brand ?? this.brand,
    note: note ?? this.note,
    templateKey: templateKey ?? this.templateKey,
    templateData: templateData ?? this.templateData,
  );
  Item copyWithCompanion(ItemsCompanion data) {
    return Item(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      price: data.price.present ? data.price.value : this.price,
      emoji: data.emoji.present ? data.emoji.value : this.emoji,
      category: data.category.present ? data.category.value : this.category,
      location: data.location.present ? data.location.value : this.location,
      purchaseDate: data.purchaseDate.present
          ? data.purchaseDate.value
          : this.purchaseDate,
      warrantyDays: data.warrantyDays.present
          ? data.warrantyDays.value
          : this.warrantyDays,
      status: data.status.present ? data.status.value : this.status,
      categoryKey: data.categoryKey.present
          ? data.categoryKey.value
          : this.categoryKey,
      cabinetId: data.cabinetId.present ? data.cabinetId.value : this.cabinetId,
      slotId: data.slotId.present ? data.slotId.value : this.slotId,
      photos: data.photos.present ? data.photos.value : this.photos,
      brand: data.brand.present ? data.brand.value : this.brand,
      note: data.note.present ? data.note.value : this.note,
      templateKey: data.templateKey.present
          ? data.templateKey.value
          : this.templateKey,
      templateData: data.templateData.present
          ? data.templateData.value
          : this.templateData,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Item(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('price: $price, ')
          ..write('emoji: $emoji, ')
          ..write('category: $category, ')
          ..write('location: $location, ')
          ..write('purchaseDate: $purchaseDate, ')
          ..write('warrantyDays: $warrantyDays, ')
          ..write('status: $status, ')
          ..write('categoryKey: $categoryKey, ')
          ..write('cabinetId: $cabinetId, ')
          ..write('slotId: $slotId, ')
          ..write('photos: $photos, ')
          ..write('brand: $brand, ')
          ..write('note: $note, ')
          ..write('templateKey: $templateKey, ')
          ..write('templateData: $templateData')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    price,
    emoji,
    category,
    location,
    purchaseDate,
    warrantyDays,
    status,
    categoryKey,
    cabinetId,
    slotId,
    photos,
    brand,
    note,
    templateKey,
    templateData,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Item &&
          other.id == this.id &&
          other.name == this.name &&
          other.price == this.price &&
          other.emoji == this.emoji &&
          other.category == this.category &&
          other.location == this.location &&
          other.purchaseDate == this.purchaseDate &&
          other.warrantyDays == this.warrantyDays &&
          other.status == this.status &&
          other.categoryKey == this.categoryKey &&
          other.cabinetId == this.cabinetId &&
          other.slotId == this.slotId &&
          other.photos == this.photos &&
          other.brand == this.brand &&
          other.note == this.note &&
          other.templateKey == this.templateKey &&
          other.templateData == this.templateData);
}

class ItemsCompanion extends UpdateCompanion<Item> {
  final Value<String> id;
  final Value<String> name;
  final Value<double> price;
  final Value<String> emoji;
  final Value<String> category;
  final Value<String> location;
  final Value<DateTime> purchaseDate;
  final Value<int> warrantyDays;
  final Value<String> status;
  final Value<String> categoryKey;
  final Value<String?> cabinetId;
  final Value<String?> slotId;
  final Value<String> photos;
  final Value<String> brand;
  final Value<String> note;
  final Value<String> templateKey;
  final Value<String> templateData;
  final Value<int> rowid;
  const ItemsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.price = const Value.absent(),
    this.emoji = const Value.absent(),
    this.category = const Value.absent(),
    this.location = const Value.absent(),
    this.purchaseDate = const Value.absent(),
    this.warrantyDays = const Value.absent(),
    this.status = const Value.absent(),
    this.categoryKey = const Value.absent(),
    this.cabinetId = const Value.absent(),
    this.slotId = const Value.absent(),
    this.photos = const Value.absent(),
    this.brand = const Value.absent(),
    this.note = const Value.absent(),
    this.templateKey = const Value.absent(),
    this.templateData = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ItemsCompanion.insert({
    required String id,
    required String name,
    required double price,
    this.emoji = const Value.absent(),
    this.category = const Value.absent(),
    this.location = const Value.absent(),
    required DateTime purchaseDate,
    this.warrantyDays = const Value.absent(),
    this.status = const Value.absent(),
    this.categoryKey = const Value.absent(),
    this.cabinetId = const Value.absent(),
    this.slotId = const Value.absent(),
    this.photos = const Value.absent(),
    this.brand = const Value.absent(),
    this.note = const Value.absent(),
    this.templateKey = const Value.absent(),
    this.templateData = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       price = Value(price),
       purchaseDate = Value(purchaseDate);
  static Insertable<Item> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<double>? price,
    Expression<String>? emoji,
    Expression<String>? category,
    Expression<String>? location,
    Expression<DateTime>? purchaseDate,
    Expression<int>? warrantyDays,
    Expression<String>? status,
    Expression<String>? categoryKey,
    Expression<String>? cabinetId,
    Expression<String>? slotId,
    Expression<String>? photos,
    Expression<String>? brand,
    Expression<String>? note,
    Expression<String>? templateKey,
    Expression<String>? templateData,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (price != null) 'price': price,
      if (emoji != null) 'emoji': emoji,
      if (category != null) 'category': category,
      if (location != null) 'location': location,
      if (purchaseDate != null) 'purchase_date': purchaseDate,
      if (warrantyDays != null) 'warranty_days': warrantyDays,
      if (status != null) 'status': status,
      if (categoryKey != null) 'category_key': categoryKey,
      if (cabinetId != null) 'cabinet_id': cabinetId,
      if (slotId != null) 'slot_id': slotId,
      if (photos != null) 'photos': photos,
      if (brand != null) 'brand': brand,
      if (note != null) 'note': note,
      if (templateKey != null) 'template_key': templateKey,
      if (templateData != null) 'template_data': templateData,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<double>? price,
    Value<String>? emoji,
    Value<String>? category,
    Value<String>? location,
    Value<DateTime>? purchaseDate,
    Value<int>? warrantyDays,
    Value<String>? status,
    Value<String>? categoryKey,
    Value<String?>? cabinetId,
    Value<String?>? slotId,
    Value<String>? photos,
    Value<String>? brand,
    Value<String>? note,
    Value<String>? templateKey,
    Value<String>? templateData,
    Value<int>? rowid,
  }) {
    return ItemsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      emoji: emoji ?? this.emoji,
      category: category ?? this.category,
      location: location ?? this.location,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      warrantyDays: warrantyDays ?? this.warrantyDays,
      status: status ?? this.status,
      categoryKey: categoryKey ?? this.categoryKey,
      cabinetId: cabinetId ?? this.cabinetId,
      slotId: slotId ?? this.slotId,
      photos: photos ?? this.photos,
      brand: brand ?? this.brand,
      note: note ?? this.note,
      templateKey: templateKey ?? this.templateKey,
      templateData: templateData ?? this.templateData,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (price.present) {
      map['price'] = Variable<double>(price.value);
    }
    if (emoji.present) {
      map['emoji'] = Variable<String>(emoji.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (purchaseDate.present) {
      map['purchase_date'] = Variable<DateTime>(purchaseDate.value);
    }
    if (warrantyDays.present) {
      map['warranty_days'] = Variable<int>(warrantyDays.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (categoryKey.present) {
      map['category_key'] = Variable<String>(categoryKey.value);
    }
    if (cabinetId.present) {
      map['cabinet_id'] = Variable<String>(cabinetId.value);
    }
    if (slotId.present) {
      map['slot_id'] = Variable<String>(slotId.value);
    }
    if (photos.present) {
      map['photos'] = Variable<String>(photos.value);
    }
    if (brand.present) {
      map['brand'] = Variable<String>(brand.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (templateKey.present) {
      map['template_key'] = Variable<String>(templateKey.value);
    }
    if (templateData.present) {
      map['template_data'] = Variable<String>(templateData.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ItemsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('price: $price, ')
          ..write('emoji: $emoji, ')
          ..write('category: $category, ')
          ..write('location: $location, ')
          ..write('purchaseDate: $purchaseDate, ')
          ..write('warrantyDays: $warrantyDays, ')
          ..write('status: $status, ')
          ..write('categoryKey: $categoryKey, ')
          ..write('cabinetId: $cabinetId, ')
          ..write('slotId: $slotId, ')
          ..write('photos: $photos, ')
          ..write('brand: $brand, ')
          ..write('note: $note, ')
          ..write('templateKey: $templateKey, ')
          ..write('templateData: $templateData, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RoomsTable extends Rooms with TableInfo<$RoomsTable, Room> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoomsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emojiMeta = const VerificationMeta('emoji');
  @override
  late final GeneratedColumn<String> emoji = GeneratedColumn<String>(
    'emoji',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<int> color = GeneratedColumn<int>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, emoji, color];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'rooms';
  @override
  VerificationContext validateIntegrity(
    Insertable<Room> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('emoji')) {
      context.handle(
        _emojiMeta,
        emoji.isAcceptableOrUnknown(data['emoji']!, _emojiMeta),
      );
    } else if (isInserting) {
      context.missing(_emojiMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    } else if (isInserting) {
      context.missing(_colorMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Room map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Room(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      emoji: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}emoji'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color'],
      )!,
    );
  }

  @override
  $RoomsTable createAlias(String alias) {
    return $RoomsTable(attachedDatabase, alias);
  }
}

class Room extends DataClass implements Insertable<Room> {
  final String id;
  final String name;
  final String emoji;
  final int color;
  const Room({
    required this.id,
    required this.name,
    required this.emoji,
    required this.color,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['emoji'] = Variable<String>(emoji);
    map['color'] = Variable<int>(color);
    return map;
  }

  RoomsCompanion toCompanion(bool nullToAbsent) {
    return RoomsCompanion(
      id: Value(id),
      name: Value(name),
      emoji: Value(emoji),
      color: Value(color),
    );
  }

  factory Room.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Room(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      emoji: serializer.fromJson<String>(json['emoji']),
      color: serializer.fromJson<int>(json['color']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'emoji': serializer.toJson<String>(emoji),
      'color': serializer.toJson<int>(color),
    };
  }

  Room copyWith({String? id, String? name, String? emoji, int? color}) => Room(
    id: id ?? this.id,
    name: name ?? this.name,
    emoji: emoji ?? this.emoji,
    color: color ?? this.color,
  );
  Room copyWithCompanion(RoomsCompanion data) {
    return Room(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      emoji: data.emoji.present ? data.emoji.value : this.emoji,
      color: data.color.present ? data.color.value : this.color,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Room(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('emoji: $emoji, ')
          ..write('color: $color')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, emoji, color);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Room &&
          other.id == this.id &&
          other.name == this.name &&
          other.emoji == this.emoji &&
          other.color == this.color);
}

class RoomsCompanion extends UpdateCompanion<Room> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> emoji;
  final Value<int> color;
  final Value<int> rowid;
  const RoomsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.emoji = const Value.absent(),
    this.color = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RoomsCompanion.insert({
    required String id,
    required String name,
    required String emoji,
    required int color,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       emoji = Value(emoji),
       color = Value(color);
  static Insertable<Room> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? emoji,
    Expression<int>? color,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (emoji != null) 'emoji': emoji,
      if (color != null) 'color': color,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RoomsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? emoji,
    Value<int>? color,
    Value<int>? rowid,
  }) {
    return RoomsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      color: color ?? this.color,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (emoji.present) {
      map['emoji'] = Variable<String>(emoji.value);
    }
    if (color.present) {
      map['color'] = Variable<int>(color.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoomsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('emoji: $emoji, ')
          ..write('color: $color, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CabinetsTable extends Cabinets with TableInfo<$CabinetsTable, Cabinet> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CabinetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emojiMeta = const VerificationMeta('emoji');
  @override
  late final GeneratedColumn<String> emoji = GeneratedColumn<String>(
    'emoji',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<int> color = GeneratedColumn<int>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roomIdMeta = const VerificationMeta('roomId');
  @override
  late final GeneratedColumn<String> roomId = GeneratedColumn<String>(
    'room_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES rooms (id)',
    ),
  );
  static const VerificationMeta _hasPhotoMeta = const VerificationMeta(
    'hasPhoto',
  );
  @override
  late final GeneratedColumn<bool> hasPhoto = GeneratedColumn<bool>(
    'has_photo',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("has_photo" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    emoji,
    color,
    roomId,
    hasPhoto,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cabinets';
  @override
  VerificationContext validateIntegrity(
    Insertable<Cabinet> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('emoji')) {
      context.handle(
        _emojiMeta,
        emoji.isAcceptableOrUnknown(data['emoji']!, _emojiMeta),
      );
    } else if (isInserting) {
      context.missing(_emojiMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    } else if (isInserting) {
      context.missing(_colorMeta);
    }
    if (data.containsKey('room_id')) {
      context.handle(
        _roomIdMeta,
        roomId.isAcceptableOrUnknown(data['room_id']!, _roomIdMeta),
      );
    } else if (isInserting) {
      context.missing(_roomIdMeta);
    }
    if (data.containsKey('has_photo')) {
      context.handle(
        _hasPhotoMeta,
        hasPhoto.isAcceptableOrUnknown(data['has_photo']!, _hasPhotoMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Cabinet map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Cabinet(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      emoji: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}emoji'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color'],
      )!,
      roomId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}room_id'],
      )!,
      hasPhoto: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}has_photo'],
      )!,
    );
  }

  @override
  $CabinetsTable createAlias(String alias) {
    return $CabinetsTable(attachedDatabase, alias);
  }
}

class Cabinet extends DataClass implements Insertable<Cabinet> {
  final String id;
  final String name;
  final String emoji;
  final int color;
  final String roomId;
  final bool hasPhoto;
  const Cabinet({
    required this.id,
    required this.name,
    required this.emoji,
    required this.color,
    required this.roomId,
    required this.hasPhoto,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['emoji'] = Variable<String>(emoji);
    map['color'] = Variable<int>(color);
    map['room_id'] = Variable<String>(roomId);
    map['has_photo'] = Variable<bool>(hasPhoto);
    return map;
  }

  CabinetsCompanion toCompanion(bool nullToAbsent) {
    return CabinetsCompanion(
      id: Value(id),
      name: Value(name),
      emoji: Value(emoji),
      color: Value(color),
      roomId: Value(roomId),
      hasPhoto: Value(hasPhoto),
    );
  }

  factory Cabinet.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Cabinet(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      emoji: serializer.fromJson<String>(json['emoji']),
      color: serializer.fromJson<int>(json['color']),
      roomId: serializer.fromJson<String>(json['roomId']),
      hasPhoto: serializer.fromJson<bool>(json['hasPhoto']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'emoji': serializer.toJson<String>(emoji),
      'color': serializer.toJson<int>(color),
      'roomId': serializer.toJson<String>(roomId),
      'hasPhoto': serializer.toJson<bool>(hasPhoto),
    };
  }

  Cabinet copyWith({
    String? id,
    String? name,
    String? emoji,
    int? color,
    String? roomId,
    bool? hasPhoto,
  }) => Cabinet(
    id: id ?? this.id,
    name: name ?? this.name,
    emoji: emoji ?? this.emoji,
    color: color ?? this.color,
    roomId: roomId ?? this.roomId,
    hasPhoto: hasPhoto ?? this.hasPhoto,
  );
  Cabinet copyWithCompanion(CabinetsCompanion data) {
    return Cabinet(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      emoji: data.emoji.present ? data.emoji.value : this.emoji,
      color: data.color.present ? data.color.value : this.color,
      roomId: data.roomId.present ? data.roomId.value : this.roomId,
      hasPhoto: data.hasPhoto.present ? data.hasPhoto.value : this.hasPhoto,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Cabinet(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('emoji: $emoji, ')
          ..write('color: $color, ')
          ..write('roomId: $roomId, ')
          ..write('hasPhoto: $hasPhoto')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, emoji, color, roomId, hasPhoto);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Cabinet &&
          other.id == this.id &&
          other.name == this.name &&
          other.emoji == this.emoji &&
          other.color == this.color &&
          other.roomId == this.roomId &&
          other.hasPhoto == this.hasPhoto);
}

class CabinetsCompanion extends UpdateCompanion<Cabinet> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> emoji;
  final Value<int> color;
  final Value<String> roomId;
  final Value<bool> hasPhoto;
  final Value<int> rowid;
  const CabinetsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.emoji = const Value.absent(),
    this.color = const Value.absent(),
    this.roomId = const Value.absent(),
    this.hasPhoto = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CabinetsCompanion.insert({
    required String id,
    required String name,
    required String emoji,
    required int color,
    required String roomId,
    this.hasPhoto = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       emoji = Value(emoji),
       color = Value(color),
       roomId = Value(roomId);
  static Insertable<Cabinet> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? emoji,
    Expression<int>? color,
    Expression<String>? roomId,
    Expression<bool>? hasPhoto,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (emoji != null) 'emoji': emoji,
      if (color != null) 'color': color,
      if (roomId != null) 'room_id': roomId,
      if (hasPhoto != null) 'has_photo': hasPhoto,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CabinetsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? emoji,
    Value<int>? color,
    Value<String>? roomId,
    Value<bool>? hasPhoto,
    Value<int>? rowid,
  }) {
    return CabinetsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      color: color ?? this.color,
      roomId: roomId ?? this.roomId,
      hasPhoto: hasPhoto ?? this.hasPhoto,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (emoji.present) {
      map['emoji'] = Variable<String>(emoji.value);
    }
    if (color.present) {
      map['color'] = Variable<int>(color.value);
    }
    if (roomId.present) {
      map['room_id'] = Variable<String>(roomId.value);
    }
    if (hasPhoto.present) {
      map['has_photo'] = Variable<bool>(hasPhoto.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CabinetsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('emoji: $emoji, ')
          ..write('color: $color, ')
          ..write('roomId: $roomId, ')
          ..write('hasPhoto: $hasPhoto, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SlotsTable extends Slots with TableInfo<$SlotsTable, Slot> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SlotsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emojiMeta = const VerificationMeta('emoji');
  @override
  late final GeneratedColumn<String> emoji = GeneratedColumn<String>(
    'emoji',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<int> color = GeneratedColumn<int>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cabinetIdMeta = const VerificationMeta(
    'cabinetId',
  );
  @override
  late final GeneratedColumn<String> cabinetId = GeneratedColumn<String>(
    'cabinet_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES cabinets (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, emoji, color, cabinetId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'slots';
  @override
  VerificationContext validateIntegrity(
    Insertable<Slot> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('emoji')) {
      context.handle(
        _emojiMeta,
        emoji.isAcceptableOrUnknown(data['emoji']!, _emojiMeta),
      );
    } else if (isInserting) {
      context.missing(_emojiMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    } else if (isInserting) {
      context.missing(_colorMeta);
    }
    if (data.containsKey('cabinet_id')) {
      context.handle(
        _cabinetIdMeta,
        cabinetId.isAcceptableOrUnknown(data['cabinet_id']!, _cabinetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cabinetIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Slot map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Slot(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      emoji: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}emoji'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color'],
      )!,
      cabinetId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cabinet_id'],
      )!,
    );
  }

  @override
  $SlotsTable createAlias(String alias) {
    return $SlotsTable(attachedDatabase, alias);
  }
}

class Slot extends DataClass implements Insertable<Slot> {
  final String id;
  final String name;
  final String emoji;
  final int color;
  final String cabinetId;
  const Slot({
    required this.id,
    required this.name,
    required this.emoji,
    required this.color,
    required this.cabinetId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['emoji'] = Variable<String>(emoji);
    map['color'] = Variable<int>(color);
    map['cabinet_id'] = Variable<String>(cabinetId);
    return map;
  }

  SlotsCompanion toCompanion(bool nullToAbsent) {
    return SlotsCompanion(
      id: Value(id),
      name: Value(name),
      emoji: Value(emoji),
      color: Value(color),
      cabinetId: Value(cabinetId),
    );
  }

  factory Slot.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Slot(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      emoji: serializer.fromJson<String>(json['emoji']),
      color: serializer.fromJson<int>(json['color']),
      cabinetId: serializer.fromJson<String>(json['cabinetId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'emoji': serializer.toJson<String>(emoji),
      'color': serializer.toJson<int>(color),
      'cabinetId': serializer.toJson<String>(cabinetId),
    };
  }

  Slot copyWith({
    String? id,
    String? name,
    String? emoji,
    int? color,
    String? cabinetId,
  }) => Slot(
    id: id ?? this.id,
    name: name ?? this.name,
    emoji: emoji ?? this.emoji,
    color: color ?? this.color,
    cabinetId: cabinetId ?? this.cabinetId,
  );
  Slot copyWithCompanion(SlotsCompanion data) {
    return Slot(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      emoji: data.emoji.present ? data.emoji.value : this.emoji,
      color: data.color.present ? data.color.value : this.color,
      cabinetId: data.cabinetId.present ? data.cabinetId.value : this.cabinetId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Slot(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('emoji: $emoji, ')
          ..write('color: $color, ')
          ..write('cabinetId: $cabinetId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, emoji, color, cabinetId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Slot &&
          other.id == this.id &&
          other.name == this.name &&
          other.emoji == this.emoji &&
          other.color == this.color &&
          other.cabinetId == this.cabinetId);
}

class SlotsCompanion extends UpdateCompanion<Slot> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> emoji;
  final Value<int> color;
  final Value<String> cabinetId;
  final Value<int> rowid;
  const SlotsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.emoji = const Value.absent(),
    this.color = const Value.absent(),
    this.cabinetId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SlotsCompanion.insert({
    required String id,
    required String name,
    required String emoji,
    required int color,
    required String cabinetId,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       emoji = Value(emoji),
       color = Value(color),
       cabinetId = Value(cabinetId);
  static Insertable<Slot> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? emoji,
    Expression<int>? color,
    Expression<String>? cabinetId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (emoji != null) 'emoji': emoji,
      if (color != null) 'color': color,
      if (cabinetId != null) 'cabinet_id': cabinetId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SlotsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? emoji,
    Value<int>? color,
    Value<String>? cabinetId,
    Value<int>? rowid,
  }) {
    return SlotsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      color: color ?? this.color,
      cabinetId: cabinetId ?? this.cabinetId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (emoji.present) {
      map['emoji'] = Variable<String>(emoji.value);
    }
    if (color.present) {
      map['color'] = Variable<int>(color.value);
    }
    if (cabinetId.present) {
      map['cabinet_id'] = Variable<String>(cabinetId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SlotsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('emoji: $emoji, ')
          ..write('color: $color, ')
          ..write('cabinetId: $cabinetId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SpaceItemsTable extends SpaceItems
    with TableInfo<$SpaceItemsTable, SpaceItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SpaceItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _emojiMeta = const VerificationMeta('emoji');
  @override
  late final GeneratedColumn<String> emoji = GeneratedColumn<String>(
    'emoji',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _metaMeta = const VerificationMeta('meta');
  @override
  late final GeneratedColumn<String> meta = GeneratedColumn<String>(
    'meta',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _slotIdMeta = const VerificationMeta('slotId');
  @override
  late final GeneratedColumn<String> slotId = GeneratedColumn<String>(
    'slot_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES slots (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [id, emoji, name, meta, slotId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'space_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<SpaceItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('emoji')) {
      context.handle(
        _emojiMeta,
        emoji.isAcceptableOrUnknown(data['emoji']!, _emojiMeta),
      );
    } else if (isInserting) {
      context.missing(_emojiMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('meta')) {
      context.handle(
        _metaMeta,
        meta.isAcceptableOrUnknown(data['meta']!, _metaMeta),
      );
    } else if (isInserting) {
      context.missing(_metaMeta);
    }
    if (data.containsKey('slot_id')) {
      context.handle(
        _slotIdMeta,
        slotId.isAcceptableOrUnknown(data['slot_id']!, _slotIdMeta),
      );
    } else if (isInserting) {
      context.missing(_slotIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SpaceItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SpaceItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      emoji: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}emoji'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      meta: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meta'],
      )!,
      slotId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}slot_id'],
      )!,
    );
  }

  @override
  $SpaceItemsTable createAlias(String alias) {
    return $SpaceItemsTable(attachedDatabase, alias);
  }
}

class SpaceItem extends DataClass implements Insertable<SpaceItem> {
  final int id;
  final String emoji;
  final String name;
  final String meta;
  final String slotId;
  const SpaceItem({
    required this.id,
    required this.emoji,
    required this.name,
    required this.meta,
    required this.slotId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['emoji'] = Variable<String>(emoji);
    map['name'] = Variable<String>(name);
    map['meta'] = Variable<String>(meta);
    map['slot_id'] = Variable<String>(slotId);
    return map;
  }

  SpaceItemsCompanion toCompanion(bool nullToAbsent) {
    return SpaceItemsCompanion(
      id: Value(id),
      emoji: Value(emoji),
      name: Value(name),
      meta: Value(meta),
      slotId: Value(slotId),
    );
  }

  factory SpaceItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SpaceItem(
      id: serializer.fromJson<int>(json['id']),
      emoji: serializer.fromJson<String>(json['emoji']),
      name: serializer.fromJson<String>(json['name']),
      meta: serializer.fromJson<String>(json['meta']),
      slotId: serializer.fromJson<String>(json['slotId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'emoji': serializer.toJson<String>(emoji),
      'name': serializer.toJson<String>(name),
      'meta': serializer.toJson<String>(meta),
      'slotId': serializer.toJson<String>(slotId),
    };
  }

  SpaceItem copyWith({
    int? id,
    String? emoji,
    String? name,
    String? meta,
    String? slotId,
  }) => SpaceItem(
    id: id ?? this.id,
    emoji: emoji ?? this.emoji,
    name: name ?? this.name,
    meta: meta ?? this.meta,
    slotId: slotId ?? this.slotId,
  );
  SpaceItem copyWithCompanion(SpaceItemsCompanion data) {
    return SpaceItem(
      id: data.id.present ? data.id.value : this.id,
      emoji: data.emoji.present ? data.emoji.value : this.emoji,
      name: data.name.present ? data.name.value : this.name,
      meta: data.meta.present ? data.meta.value : this.meta,
      slotId: data.slotId.present ? data.slotId.value : this.slotId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SpaceItem(')
          ..write('id: $id, ')
          ..write('emoji: $emoji, ')
          ..write('name: $name, ')
          ..write('meta: $meta, ')
          ..write('slotId: $slotId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, emoji, name, meta, slotId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SpaceItem &&
          other.id == this.id &&
          other.emoji == this.emoji &&
          other.name == this.name &&
          other.meta == this.meta &&
          other.slotId == this.slotId);
}

class SpaceItemsCompanion extends UpdateCompanion<SpaceItem> {
  final Value<int> id;
  final Value<String> emoji;
  final Value<String> name;
  final Value<String> meta;
  final Value<String> slotId;
  const SpaceItemsCompanion({
    this.id = const Value.absent(),
    this.emoji = const Value.absent(),
    this.name = const Value.absent(),
    this.meta = const Value.absent(),
    this.slotId = const Value.absent(),
  });
  SpaceItemsCompanion.insert({
    this.id = const Value.absent(),
    required String emoji,
    required String name,
    required String meta,
    required String slotId,
  }) : emoji = Value(emoji),
       name = Value(name),
       meta = Value(meta),
       slotId = Value(slotId);
  static Insertable<SpaceItem> custom({
    Expression<int>? id,
    Expression<String>? emoji,
    Expression<String>? name,
    Expression<String>? meta,
    Expression<String>? slotId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (emoji != null) 'emoji': emoji,
      if (name != null) 'name': name,
      if (meta != null) 'meta': meta,
      if (slotId != null) 'slot_id': slotId,
    });
  }

  SpaceItemsCompanion copyWith({
    Value<int>? id,
    Value<String>? emoji,
    Value<String>? name,
    Value<String>? meta,
    Value<String>? slotId,
  }) {
    return SpaceItemsCompanion(
      id: id ?? this.id,
      emoji: emoji ?? this.emoji,
      name: name ?? this.name,
      meta: meta ?? this.meta,
      slotId: slotId ?? this.slotId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (emoji.present) {
      map['emoji'] = Variable<String>(emoji.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (meta.present) {
      map['meta'] = Variable<String>(meta.value);
    }
    if (slotId.present) {
      map['slot_id'] = Variable<String>(slotId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SpaceItemsCompanion(')
          ..write('id: $id, ')
          ..write('emoji: $emoji, ')
          ..write('name: $name, ')
          ..write('meta: $meta, ')
          ..write('slotId: $slotId')
          ..write(')'))
        .toString();
  }
}

class $ImportHistoryTable extends ImportHistory
    with TableInfo<$ImportHistoryTable, ImportHistoryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ImportHistoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _platformKeyMeta = const VerificationMeta(
    'platformKey',
  );
  @override
  late final GeneratedColumn<String> platformKey = GeneratedColumn<String>(
    'platform_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emojiMeta = const VerificationMeta('emoji');
  @override
  late final GeneratedColumn<String> emoji = GeneratedColumn<String>(
    'emoji',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _metaMeta = const VerificationMeta('meta');
  @override
  late final GeneratedColumn<String> meta = GeneratedColumn<String>(
    'meta',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _countMeta = const VerificationMeta('count');
  @override
  late final GeneratedColumn<int> count = GeneratedColumn<int>(
    'count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconBgMeta = const VerificationMeta('iconBg');
  @override
  late final GeneratedColumn<int> iconBg = GeneratedColumn<int>(
    'icon_bg',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _importedAtMeta = const VerificationMeta(
    'importedAt',
  );
  @override
  late final GeneratedColumn<DateTime> importedAt = GeneratedColumn<DateTime>(
    'imported_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    platformKey,
    emoji,
    title,
    meta,
    count,
    iconBg,
    importedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'import_history';
  @override
  VerificationContext validateIntegrity(
    Insertable<ImportHistoryData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('platform_key')) {
      context.handle(
        _platformKeyMeta,
        platformKey.isAcceptableOrUnknown(
          data['platform_key']!,
          _platformKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_platformKeyMeta);
    }
    if (data.containsKey('emoji')) {
      context.handle(
        _emojiMeta,
        emoji.isAcceptableOrUnknown(data['emoji']!, _emojiMeta),
      );
    } else if (isInserting) {
      context.missing(_emojiMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('meta')) {
      context.handle(
        _metaMeta,
        meta.isAcceptableOrUnknown(data['meta']!, _metaMeta),
      );
    } else if (isInserting) {
      context.missing(_metaMeta);
    }
    if (data.containsKey('count')) {
      context.handle(
        _countMeta,
        count.isAcceptableOrUnknown(data['count']!, _countMeta),
      );
    } else if (isInserting) {
      context.missing(_countMeta);
    }
    if (data.containsKey('icon_bg')) {
      context.handle(
        _iconBgMeta,
        iconBg.isAcceptableOrUnknown(data['icon_bg']!, _iconBgMeta),
      );
    } else if (isInserting) {
      context.missing(_iconBgMeta);
    }
    if (data.containsKey('imported_at')) {
      context.handle(
        _importedAtMeta,
        importedAt.isAcceptableOrUnknown(data['imported_at']!, _importedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ImportHistoryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ImportHistoryData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      platformKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}platform_key'],
      )!,
      emoji: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}emoji'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      meta: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meta'],
      )!,
      count: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}count'],
      )!,
      iconBg: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}icon_bg'],
      )!,
      importedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}imported_at'],
      )!,
    );
  }

  @override
  $ImportHistoryTable createAlias(String alias) {
    return $ImportHistoryTable(attachedDatabase, alias);
  }
}

class ImportHistoryData extends DataClass
    implements Insertable<ImportHistoryData> {
  final int id;
  final String platformKey;
  final String emoji;
  final String title;
  final String meta;
  final int count;
  final int iconBg;
  final DateTime importedAt;
  const ImportHistoryData({
    required this.id,
    required this.platformKey,
    required this.emoji,
    required this.title,
    required this.meta,
    required this.count,
    required this.iconBg,
    required this.importedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['platform_key'] = Variable<String>(platformKey);
    map['emoji'] = Variable<String>(emoji);
    map['title'] = Variable<String>(title);
    map['meta'] = Variable<String>(meta);
    map['count'] = Variable<int>(count);
    map['icon_bg'] = Variable<int>(iconBg);
    map['imported_at'] = Variable<DateTime>(importedAt);
    return map;
  }

  ImportHistoryCompanion toCompanion(bool nullToAbsent) {
    return ImportHistoryCompanion(
      id: Value(id),
      platformKey: Value(platformKey),
      emoji: Value(emoji),
      title: Value(title),
      meta: Value(meta),
      count: Value(count),
      iconBg: Value(iconBg),
      importedAt: Value(importedAt),
    );
  }

  factory ImportHistoryData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ImportHistoryData(
      id: serializer.fromJson<int>(json['id']),
      platformKey: serializer.fromJson<String>(json['platformKey']),
      emoji: serializer.fromJson<String>(json['emoji']),
      title: serializer.fromJson<String>(json['title']),
      meta: serializer.fromJson<String>(json['meta']),
      count: serializer.fromJson<int>(json['count']),
      iconBg: serializer.fromJson<int>(json['iconBg']),
      importedAt: serializer.fromJson<DateTime>(json['importedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'platformKey': serializer.toJson<String>(platformKey),
      'emoji': serializer.toJson<String>(emoji),
      'title': serializer.toJson<String>(title),
      'meta': serializer.toJson<String>(meta),
      'count': serializer.toJson<int>(count),
      'iconBg': serializer.toJson<int>(iconBg),
      'importedAt': serializer.toJson<DateTime>(importedAt),
    };
  }

  ImportHistoryData copyWith({
    int? id,
    String? platformKey,
    String? emoji,
    String? title,
    String? meta,
    int? count,
    int? iconBg,
    DateTime? importedAt,
  }) => ImportHistoryData(
    id: id ?? this.id,
    platformKey: platformKey ?? this.platformKey,
    emoji: emoji ?? this.emoji,
    title: title ?? this.title,
    meta: meta ?? this.meta,
    count: count ?? this.count,
    iconBg: iconBg ?? this.iconBg,
    importedAt: importedAt ?? this.importedAt,
  );
  ImportHistoryData copyWithCompanion(ImportHistoryCompanion data) {
    return ImportHistoryData(
      id: data.id.present ? data.id.value : this.id,
      platformKey: data.platformKey.present
          ? data.platformKey.value
          : this.platformKey,
      emoji: data.emoji.present ? data.emoji.value : this.emoji,
      title: data.title.present ? data.title.value : this.title,
      meta: data.meta.present ? data.meta.value : this.meta,
      count: data.count.present ? data.count.value : this.count,
      iconBg: data.iconBg.present ? data.iconBg.value : this.iconBg,
      importedAt: data.importedAt.present
          ? data.importedAt.value
          : this.importedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ImportHistoryData(')
          ..write('id: $id, ')
          ..write('platformKey: $platformKey, ')
          ..write('emoji: $emoji, ')
          ..write('title: $title, ')
          ..write('meta: $meta, ')
          ..write('count: $count, ')
          ..write('iconBg: $iconBg, ')
          ..write('importedAt: $importedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    platformKey,
    emoji,
    title,
    meta,
    count,
    iconBg,
    importedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ImportHistoryData &&
          other.id == this.id &&
          other.platformKey == this.platformKey &&
          other.emoji == this.emoji &&
          other.title == this.title &&
          other.meta == this.meta &&
          other.count == this.count &&
          other.iconBg == this.iconBg &&
          other.importedAt == this.importedAt);
}

class ImportHistoryCompanion extends UpdateCompanion<ImportHistoryData> {
  final Value<int> id;
  final Value<String> platformKey;
  final Value<String> emoji;
  final Value<String> title;
  final Value<String> meta;
  final Value<int> count;
  final Value<int> iconBg;
  final Value<DateTime> importedAt;
  const ImportHistoryCompanion({
    this.id = const Value.absent(),
    this.platformKey = const Value.absent(),
    this.emoji = const Value.absent(),
    this.title = const Value.absent(),
    this.meta = const Value.absent(),
    this.count = const Value.absent(),
    this.iconBg = const Value.absent(),
    this.importedAt = const Value.absent(),
  });
  ImportHistoryCompanion.insert({
    this.id = const Value.absent(),
    required String platformKey,
    required String emoji,
    required String title,
    required String meta,
    required int count,
    required int iconBg,
    this.importedAt = const Value.absent(),
  }) : platformKey = Value(platformKey),
       emoji = Value(emoji),
       title = Value(title),
       meta = Value(meta),
       count = Value(count),
       iconBg = Value(iconBg);
  static Insertable<ImportHistoryData> custom({
    Expression<int>? id,
    Expression<String>? platformKey,
    Expression<String>? emoji,
    Expression<String>? title,
    Expression<String>? meta,
    Expression<int>? count,
    Expression<int>? iconBg,
    Expression<DateTime>? importedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (platformKey != null) 'platform_key': platformKey,
      if (emoji != null) 'emoji': emoji,
      if (title != null) 'title': title,
      if (meta != null) 'meta': meta,
      if (count != null) 'count': count,
      if (iconBg != null) 'icon_bg': iconBg,
      if (importedAt != null) 'imported_at': importedAt,
    });
  }

  ImportHistoryCompanion copyWith({
    Value<int>? id,
    Value<String>? platformKey,
    Value<String>? emoji,
    Value<String>? title,
    Value<String>? meta,
    Value<int>? count,
    Value<int>? iconBg,
    Value<DateTime>? importedAt,
  }) {
    return ImportHistoryCompanion(
      id: id ?? this.id,
      platformKey: platformKey ?? this.platformKey,
      emoji: emoji ?? this.emoji,
      title: title ?? this.title,
      meta: meta ?? this.meta,
      count: count ?? this.count,
      iconBg: iconBg ?? this.iconBg,
      importedAt: importedAt ?? this.importedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (platformKey.present) {
      map['platform_key'] = Variable<String>(platformKey.value);
    }
    if (emoji.present) {
      map['emoji'] = Variable<String>(emoji.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (meta.present) {
      map['meta'] = Variable<String>(meta.value);
    }
    if (count.present) {
      map['count'] = Variable<int>(count.value);
    }
    if (iconBg.present) {
      map['icon_bg'] = Variable<int>(iconBg.value);
    }
    if (importedAt.present) {
      map['imported_at'] = Variable<DateTime>(importedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ImportHistoryCompanion(')
          ..write('id: $id, ')
          ..write('platformKey: $platformKey, ')
          ..write('emoji: $emoji, ')
          ..write('title: $title, ')
          ..write('meta: $meta, ')
          ..write('count: $count, ')
          ..write('iconBg: $iconBg, ')
          ..write('importedAt: $importedAt')
          ..write(')'))
        .toString();
  }
}

class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, Category> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emojiMeta = const VerificationMeta('emoji');
  @override
  late final GeneratedColumn<String> emoji = GeneratedColumn<String>(
    'emoji',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isBuiltInMeta = const VerificationMeta(
    'isBuiltIn',
  );
  @override
  late final GeneratedColumn<bool> isBuiltIn = GeneratedColumn<bool>(
    'is_built_in',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_built_in" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    label,
    emoji,
    isBuiltIn,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<Category> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('emoji')) {
      context.handle(
        _emojiMeta,
        emoji.isAcceptableOrUnknown(data['emoji']!, _emojiMeta),
      );
    } else if (isInserting) {
      context.missing(_emojiMeta);
    }
    if (data.containsKey('is_built_in')) {
      context.handle(
        _isBuiltInMeta,
        isBuiltIn.isAcceptableOrUnknown(data['is_built_in']!, _isBuiltInMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Category map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Category(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      emoji: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}emoji'],
      )!,
      isBuiltIn: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_built_in'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class Category extends DataClass implements Insertable<Category> {
  final String id;
  final String label;
  final String emoji;
  final bool isBuiltIn;
  final int sortOrder;
  const Category({
    required this.id,
    required this.label,
    required this.emoji,
    required this.isBuiltIn,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['label'] = Variable<String>(label);
    map['emoji'] = Variable<String>(emoji);
    map['is_built_in'] = Variable<bool>(isBuiltIn);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      label: Value(label),
      emoji: Value(emoji),
      isBuiltIn: Value(isBuiltIn),
      sortOrder: Value(sortOrder),
    );
  }

  factory Category.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Category(
      id: serializer.fromJson<String>(json['id']),
      label: serializer.fromJson<String>(json['label']),
      emoji: serializer.fromJson<String>(json['emoji']),
      isBuiltIn: serializer.fromJson<bool>(json['isBuiltIn']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'label': serializer.toJson<String>(label),
      'emoji': serializer.toJson<String>(emoji),
      'isBuiltIn': serializer.toJson<bool>(isBuiltIn),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  Category copyWith({
    String? id,
    String? label,
    String? emoji,
    bool? isBuiltIn,
    int? sortOrder,
  }) => Category(
    id: id ?? this.id,
    label: label ?? this.label,
    emoji: emoji ?? this.emoji,
    isBuiltIn: isBuiltIn ?? this.isBuiltIn,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  Category copyWithCompanion(CategoriesCompanion data) {
    return Category(
      id: data.id.present ? data.id.value : this.id,
      label: data.label.present ? data.label.value : this.label,
      emoji: data.emoji.present ? data.emoji.value : this.emoji,
      isBuiltIn: data.isBuiltIn.present ? data.isBuiltIn.value : this.isBuiltIn,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Category(')
          ..write('id: $id, ')
          ..write('label: $label, ')
          ..write('emoji: $emoji, ')
          ..write('isBuiltIn: $isBuiltIn, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, label, emoji, isBuiltIn, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Category &&
          other.id == this.id &&
          other.label == this.label &&
          other.emoji == this.emoji &&
          other.isBuiltIn == this.isBuiltIn &&
          other.sortOrder == this.sortOrder);
}

class CategoriesCompanion extends UpdateCompanion<Category> {
  final Value<String> id;
  final Value<String> label;
  final Value<String> emoji;
  final Value<bool> isBuiltIn;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.label = const Value.absent(),
    this.emoji = const Value.absent(),
    this.isBuiltIn = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoriesCompanion.insert({
    required String id,
    required String label,
    required String emoji,
    this.isBuiltIn = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       label = Value(label),
       emoji = Value(emoji);
  static Insertable<Category> custom({
    Expression<String>? id,
    Expression<String>? label,
    Expression<String>? emoji,
    Expression<bool>? isBuiltIn,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (label != null) 'label': label,
      if (emoji != null) 'emoji': emoji,
      if (isBuiltIn != null) 'is_built_in': isBuiltIn,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoriesCompanion copyWith({
    Value<String>? id,
    Value<String>? label,
    Value<String>? emoji,
    Value<bool>? isBuiltIn,
    Value<int>? sortOrder,
    Value<int>? rowid,
  }) {
    return CategoriesCompanion(
      id: id ?? this.id,
      label: label ?? this.label,
      emoji: emoji ?? this.emoji,
      isBuiltIn: isBuiltIn ?? this.isBuiltIn,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (emoji.present) {
      map['emoji'] = Variable<String>(emoji.value);
    }
    if (isBuiltIn.present) {
      map['is_built_in'] = Variable<bool>(isBuiltIn.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('label: $label, ')
          ..write('emoji: $emoji, ')
          ..write('isBuiltIn: $isBuiltIn, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettingsTable extends Settings with TableInfo<$SettingsTable, Setting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<Setting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  Setting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Setting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class Setting extends DataClass implements Insertable<Setting> {
  final String key;
  final String value;
  const Setting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(key: Value(key), value: Value(value));
  }

  factory Setting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Setting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  Setting copyWith({String? key, String? value}) =>
      Setting(key: key ?? this.key, value: value ?? this.value);
  Setting copyWithCompanion(SettingsCompanion data) {
    return Setting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Setting(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Setting && other.key == this.key && other.value == this.value);
}

class SettingsCompanion extends UpdateCompanion<Setting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsCompanion.insert({
    required String key,
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : key = Value(key);
  static Insertable<Setting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return SettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ItemsTable items = $ItemsTable(this);
  late final $RoomsTable rooms = $RoomsTable(this);
  late final $CabinetsTable cabinets = $CabinetsTable(this);
  late final $SlotsTable slots = $SlotsTable(this);
  late final $SpaceItemsTable spaceItems = $SpaceItemsTable(this);
  late final $ImportHistoryTable importHistory = $ImportHistoryTable(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    items,
    rooms,
    cabinets,
    slots,
    spaceItems,
    importHistory,
    categories,
    settings,
  ];
}

typedef $$ItemsTableCreateCompanionBuilder =
    ItemsCompanion Function({
      required String id,
      required String name,
      required double price,
      Value<String> emoji,
      Value<String> category,
      Value<String> location,
      required DateTime purchaseDate,
      Value<int> warrantyDays,
      Value<String> status,
      Value<String> categoryKey,
      Value<String?> cabinetId,
      Value<String?> slotId,
      Value<String> photos,
      Value<String> brand,
      Value<String> note,
      Value<String> templateKey,
      Value<String> templateData,
      Value<int> rowid,
    });
typedef $$ItemsTableUpdateCompanionBuilder =
    ItemsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<double> price,
      Value<String> emoji,
      Value<String> category,
      Value<String> location,
      Value<DateTime> purchaseDate,
      Value<int> warrantyDays,
      Value<String> status,
      Value<String> categoryKey,
      Value<String?> cabinetId,
      Value<String?> slotId,
      Value<String> photos,
      Value<String> brand,
      Value<String> note,
      Value<String> templateKey,
      Value<String> templateData,
      Value<int> rowid,
    });

class $$ItemsTableFilterComposer extends Composer<_$AppDatabase, $ItemsTable> {
  $$ItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get emoji => $composableBuilder(
    column: $table.emoji,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get purchaseDate => $composableBuilder(
    column: $table.purchaseDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get warrantyDays => $composableBuilder(
    column: $table.warrantyDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryKey => $composableBuilder(
    column: $table.categoryKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cabinetId => $composableBuilder(
    column: $table.cabinetId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get slotId => $composableBuilder(
    column: $table.slotId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photos => $composableBuilder(
    column: $table.photos,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get templateKey => $composableBuilder(
    column: $table.templateKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get templateData => $composableBuilder(
    column: $table.templateData,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $ItemsTable> {
  $$ItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get emoji => $composableBuilder(
    column: $table.emoji,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get purchaseDate => $composableBuilder(
    column: $table.purchaseDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get warrantyDays => $composableBuilder(
    column: $table.warrantyDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryKey => $composableBuilder(
    column: $table.categoryKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cabinetId => $composableBuilder(
    column: $table.cabinetId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get slotId => $composableBuilder(
    column: $table.slotId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photos => $composableBuilder(
    column: $table.photos,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get templateKey => $composableBuilder(
    column: $table.templateKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get templateData => $composableBuilder(
    column: $table.templateData,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ItemsTable> {
  $$ItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get price =>
      $composableBuilder(column: $table.price, builder: (column) => column);

  GeneratedColumn<String> get emoji =>
      $composableBuilder(column: $table.emoji, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<DateTime> get purchaseDate => $composableBuilder(
    column: $table.purchaseDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get warrantyDays => $composableBuilder(
    column: $table.warrantyDays,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get categoryKey => $composableBuilder(
    column: $table.categoryKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get cabinetId =>
      $composableBuilder(column: $table.cabinetId, builder: (column) => column);

  GeneratedColumn<String> get slotId =>
      $composableBuilder(column: $table.slotId, builder: (column) => column);

  GeneratedColumn<String> get photos =>
      $composableBuilder(column: $table.photos, builder: (column) => column);

  GeneratedColumn<String> get brand =>
      $composableBuilder(column: $table.brand, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get templateKey => $composableBuilder(
    column: $table.templateKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get templateData => $composableBuilder(
    column: $table.templateData,
    builder: (column) => column,
  );
}

class $$ItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ItemsTable,
          Item,
          $$ItemsTableFilterComposer,
          $$ItemsTableOrderingComposer,
          $$ItemsTableAnnotationComposer,
          $$ItemsTableCreateCompanionBuilder,
          $$ItemsTableUpdateCompanionBuilder,
          (Item, BaseReferences<_$AppDatabase, $ItemsTable, Item>),
          Item,
          PrefetchHooks Function()
        > {
  $$ItemsTableTableManager(_$AppDatabase db, $ItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<double> price = const Value.absent(),
                Value<String> emoji = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> location = const Value.absent(),
                Value<DateTime> purchaseDate = const Value.absent(),
                Value<int> warrantyDays = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> categoryKey = const Value.absent(),
                Value<String?> cabinetId = const Value.absent(),
                Value<String?> slotId = const Value.absent(),
                Value<String> photos = const Value.absent(),
                Value<String> brand = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<String> templateKey = const Value.absent(),
                Value<String> templateData = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ItemsCompanion(
                id: id,
                name: name,
                price: price,
                emoji: emoji,
                category: category,
                location: location,
                purchaseDate: purchaseDate,
                warrantyDays: warrantyDays,
                status: status,
                categoryKey: categoryKey,
                cabinetId: cabinetId,
                slotId: slotId,
                photos: photos,
                brand: brand,
                note: note,
                templateKey: templateKey,
                templateData: templateData,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required double price,
                Value<String> emoji = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> location = const Value.absent(),
                required DateTime purchaseDate,
                Value<int> warrantyDays = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> categoryKey = const Value.absent(),
                Value<String?> cabinetId = const Value.absent(),
                Value<String?> slotId = const Value.absent(),
                Value<String> photos = const Value.absent(),
                Value<String> brand = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<String> templateKey = const Value.absent(),
                Value<String> templateData = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ItemsCompanion.insert(
                id: id,
                name: name,
                price: price,
                emoji: emoji,
                category: category,
                location: location,
                purchaseDate: purchaseDate,
                warrantyDays: warrantyDays,
                status: status,
                categoryKey: categoryKey,
                cabinetId: cabinetId,
                slotId: slotId,
                photos: photos,
                brand: brand,
                note: note,
                templateKey: templateKey,
                templateData: templateData,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ItemsTable,
      Item,
      $$ItemsTableFilterComposer,
      $$ItemsTableOrderingComposer,
      $$ItemsTableAnnotationComposer,
      $$ItemsTableCreateCompanionBuilder,
      $$ItemsTableUpdateCompanionBuilder,
      (Item, BaseReferences<_$AppDatabase, $ItemsTable, Item>),
      Item,
      PrefetchHooks Function()
    >;
typedef $$RoomsTableCreateCompanionBuilder =
    RoomsCompanion Function({
      required String id,
      required String name,
      required String emoji,
      required int color,
      Value<int> rowid,
    });
typedef $$RoomsTableUpdateCompanionBuilder =
    RoomsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> emoji,
      Value<int> color,
      Value<int> rowid,
    });

final class $$RoomsTableReferences
    extends BaseReferences<_$AppDatabase, $RoomsTable, Room> {
  $$RoomsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$CabinetsTable, List<Cabinet>> _cabinetsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.cabinets,
    aliasName: 'rooms__id__cabinets__room_id',
  );

  $$CabinetsTableProcessedTableManager get cabinetsRefs {
    final manager = $$CabinetsTableTableManager(
      $_db,
      $_db.cabinets,
    ).filter((f) => f.roomId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_cabinetsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$RoomsTableFilterComposer extends Composer<_$AppDatabase, $RoomsTable> {
  $$RoomsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get emoji => $composableBuilder(
    column: $table.emoji,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> cabinetsRefs(
    Expression<bool> Function($$CabinetsTableFilterComposer f) f,
  ) {
    final $$CabinetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cabinets,
      getReferencedColumn: (t) => t.roomId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CabinetsTableFilterComposer(
            $db: $db,
            $table: $db.cabinets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RoomsTableOrderingComposer
    extends Composer<_$AppDatabase, $RoomsTable> {
  $$RoomsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get emoji => $composableBuilder(
    column: $table.emoji,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RoomsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RoomsTable> {
  $$RoomsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get emoji =>
      $composableBuilder(column: $table.emoji, builder: (column) => column);

  GeneratedColumn<int> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  Expression<T> cabinetsRefs<T extends Object>(
    Expression<T> Function($$CabinetsTableAnnotationComposer a) f,
  ) {
    final $$CabinetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cabinets,
      getReferencedColumn: (t) => t.roomId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CabinetsTableAnnotationComposer(
            $db: $db,
            $table: $db.cabinets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RoomsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RoomsTable,
          Room,
          $$RoomsTableFilterComposer,
          $$RoomsTableOrderingComposer,
          $$RoomsTableAnnotationComposer,
          $$RoomsTableCreateCompanionBuilder,
          $$RoomsTableUpdateCompanionBuilder,
          (Room, $$RoomsTableReferences),
          Room,
          PrefetchHooks Function({bool cabinetsRefs})
        > {
  $$RoomsTableTableManager(_$AppDatabase db, $RoomsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RoomsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RoomsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RoomsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> emoji = const Value.absent(),
                Value<int> color = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RoomsCompanion(
                id: id,
                name: name,
                emoji: emoji,
                color: color,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String emoji,
                required int color,
                Value<int> rowid = const Value.absent(),
              }) => RoomsCompanion.insert(
                id: id,
                name: name,
                emoji: emoji,
                color: color,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$RoomsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({cabinetsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (cabinetsRefs) db.cabinets],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (cabinetsRefs)
                    await $_getPrefetchedData<Room, $RoomsTable, Cabinet>(
                      currentTable: table,
                      referencedTable: $$RoomsTableReferences
                          ._cabinetsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$RoomsTableReferences(db, table, p0).cabinetsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.roomId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$RoomsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RoomsTable,
      Room,
      $$RoomsTableFilterComposer,
      $$RoomsTableOrderingComposer,
      $$RoomsTableAnnotationComposer,
      $$RoomsTableCreateCompanionBuilder,
      $$RoomsTableUpdateCompanionBuilder,
      (Room, $$RoomsTableReferences),
      Room,
      PrefetchHooks Function({bool cabinetsRefs})
    >;
typedef $$CabinetsTableCreateCompanionBuilder =
    CabinetsCompanion Function({
      required String id,
      required String name,
      required String emoji,
      required int color,
      required String roomId,
      Value<bool> hasPhoto,
      Value<int> rowid,
    });
typedef $$CabinetsTableUpdateCompanionBuilder =
    CabinetsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> emoji,
      Value<int> color,
      Value<String> roomId,
      Value<bool> hasPhoto,
      Value<int> rowid,
    });

final class $$CabinetsTableReferences
    extends BaseReferences<_$AppDatabase, $CabinetsTable, Cabinet> {
  $$CabinetsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $RoomsTable _roomIdTable(_$AppDatabase db) =>
      db.rooms.createAlias('cabinets__room_id__rooms__id');

  $$RoomsTableProcessedTableManager get roomId {
    final $_column = $_itemColumn<String>('room_id')!;

    final manager = $$RoomsTableTableManager(
      $_db,
      $_db.rooms,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_roomIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$SlotsTable, List<Slot>> _slotsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.slots,
    aliasName: 'cabinets__id__slots__cabinet_id',
  );

  $$SlotsTableProcessedTableManager get slotsRefs {
    final manager = $$SlotsTableTableManager(
      $_db,
      $_db.slots,
    ).filter((f) => f.cabinetId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_slotsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CabinetsTableFilterComposer
    extends Composer<_$AppDatabase, $CabinetsTable> {
  $$CabinetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get emoji => $composableBuilder(
    column: $table.emoji,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hasPhoto => $composableBuilder(
    column: $table.hasPhoto,
    builder: (column) => ColumnFilters(column),
  );

  $$RoomsTableFilterComposer get roomId {
    final $$RoomsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.roomId,
      referencedTable: $db.rooms,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoomsTableFilterComposer(
            $db: $db,
            $table: $db.rooms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> slotsRefs(
    Expression<bool> Function($$SlotsTableFilterComposer f) f,
  ) {
    final $$SlotsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.slots,
      getReferencedColumn: (t) => t.cabinetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SlotsTableFilterComposer(
            $db: $db,
            $table: $db.slots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CabinetsTableOrderingComposer
    extends Composer<_$AppDatabase, $CabinetsTable> {
  $$CabinetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get emoji => $composableBuilder(
    column: $table.emoji,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hasPhoto => $composableBuilder(
    column: $table.hasPhoto,
    builder: (column) => ColumnOrderings(column),
  );

  $$RoomsTableOrderingComposer get roomId {
    final $$RoomsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.roomId,
      referencedTable: $db.rooms,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoomsTableOrderingComposer(
            $db: $db,
            $table: $db.rooms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CabinetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CabinetsTable> {
  $$CabinetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get emoji =>
      $composableBuilder(column: $table.emoji, builder: (column) => column);

  GeneratedColumn<int> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<bool> get hasPhoto =>
      $composableBuilder(column: $table.hasPhoto, builder: (column) => column);

  $$RoomsTableAnnotationComposer get roomId {
    final $$RoomsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.roomId,
      referencedTable: $db.rooms,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoomsTableAnnotationComposer(
            $db: $db,
            $table: $db.rooms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> slotsRefs<T extends Object>(
    Expression<T> Function($$SlotsTableAnnotationComposer a) f,
  ) {
    final $$SlotsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.slots,
      getReferencedColumn: (t) => t.cabinetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SlotsTableAnnotationComposer(
            $db: $db,
            $table: $db.slots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CabinetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CabinetsTable,
          Cabinet,
          $$CabinetsTableFilterComposer,
          $$CabinetsTableOrderingComposer,
          $$CabinetsTableAnnotationComposer,
          $$CabinetsTableCreateCompanionBuilder,
          $$CabinetsTableUpdateCompanionBuilder,
          (Cabinet, $$CabinetsTableReferences),
          Cabinet,
          PrefetchHooks Function({bool roomId, bool slotsRefs})
        > {
  $$CabinetsTableTableManager(_$AppDatabase db, $CabinetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CabinetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CabinetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CabinetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> emoji = const Value.absent(),
                Value<int> color = const Value.absent(),
                Value<String> roomId = const Value.absent(),
                Value<bool> hasPhoto = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CabinetsCompanion(
                id: id,
                name: name,
                emoji: emoji,
                color: color,
                roomId: roomId,
                hasPhoto: hasPhoto,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String emoji,
                required int color,
                required String roomId,
                Value<bool> hasPhoto = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CabinetsCompanion.insert(
                id: id,
                name: name,
                emoji: emoji,
                color: color,
                roomId: roomId,
                hasPhoto: hasPhoto,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CabinetsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({roomId = false, slotsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (slotsRefs) db.slots],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (roomId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.roomId,
                                referencedTable: $$CabinetsTableReferences
                                    ._roomIdTable(db),
                                referencedColumn: $$CabinetsTableReferences
                                    ._roomIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (slotsRefs)
                    await $_getPrefetchedData<Cabinet, $CabinetsTable, Slot>(
                      currentTable: table,
                      referencedTable: $$CabinetsTableReferences
                          ._slotsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$CabinetsTableReferences(db, table, p0).slotsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.cabinetId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$CabinetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CabinetsTable,
      Cabinet,
      $$CabinetsTableFilterComposer,
      $$CabinetsTableOrderingComposer,
      $$CabinetsTableAnnotationComposer,
      $$CabinetsTableCreateCompanionBuilder,
      $$CabinetsTableUpdateCompanionBuilder,
      (Cabinet, $$CabinetsTableReferences),
      Cabinet,
      PrefetchHooks Function({bool roomId, bool slotsRefs})
    >;
typedef $$SlotsTableCreateCompanionBuilder =
    SlotsCompanion Function({
      required String id,
      required String name,
      required String emoji,
      required int color,
      required String cabinetId,
      Value<int> rowid,
    });
typedef $$SlotsTableUpdateCompanionBuilder =
    SlotsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> emoji,
      Value<int> color,
      Value<String> cabinetId,
      Value<int> rowid,
    });

final class $$SlotsTableReferences
    extends BaseReferences<_$AppDatabase, $SlotsTable, Slot> {
  $$SlotsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CabinetsTable _cabinetIdTable(_$AppDatabase db) =>
      db.cabinets.createAlias('slots__cabinet_id__cabinets__id');

  $$CabinetsTableProcessedTableManager get cabinetId {
    final $_column = $_itemColumn<String>('cabinet_id')!;

    final manager = $$CabinetsTableTableManager(
      $_db,
      $_db.cabinets,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_cabinetIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$SpaceItemsTable, List<SpaceItem>>
  _spaceItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.spaceItems,
    aliasName: 'slots__id__space_items__slot_id',
  );

  $$SpaceItemsTableProcessedTableManager get spaceItemsRefs {
    final manager = $$SpaceItemsTableTableManager(
      $_db,
      $_db.spaceItems,
    ).filter((f) => f.slotId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_spaceItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SlotsTableFilterComposer extends Composer<_$AppDatabase, $SlotsTable> {
  $$SlotsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get emoji => $composableBuilder(
    column: $table.emoji,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  $$CabinetsTableFilterComposer get cabinetId {
    final $$CabinetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cabinetId,
      referencedTable: $db.cabinets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CabinetsTableFilterComposer(
            $db: $db,
            $table: $db.cabinets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> spaceItemsRefs(
    Expression<bool> Function($$SpaceItemsTableFilterComposer f) f,
  ) {
    final $$SpaceItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.spaceItems,
      getReferencedColumn: (t) => t.slotId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SpaceItemsTableFilterComposer(
            $db: $db,
            $table: $db.spaceItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SlotsTableOrderingComposer
    extends Composer<_$AppDatabase, $SlotsTable> {
  $$SlotsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get emoji => $composableBuilder(
    column: $table.emoji,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  $$CabinetsTableOrderingComposer get cabinetId {
    final $$CabinetsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cabinetId,
      referencedTable: $db.cabinets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CabinetsTableOrderingComposer(
            $db: $db,
            $table: $db.cabinets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SlotsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SlotsTable> {
  $$SlotsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get emoji =>
      $composableBuilder(column: $table.emoji, builder: (column) => column);

  GeneratedColumn<int> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  $$CabinetsTableAnnotationComposer get cabinetId {
    final $$CabinetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cabinetId,
      referencedTable: $db.cabinets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CabinetsTableAnnotationComposer(
            $db: $db,
            $table: $db.cabinets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> spaceItemsRefs<T extends Object>(
    Expression<T> Function($$SpaceItemsTableAnnotationComposer a) f,
  ) {
    final $$SpaceItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.spaceItems,
      getReferencedColumn: (t) => t.slotId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SpaceItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.spaceItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SlotsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SlotsTable,
          Slot,
          $$SlotsTableFilterComposer,
          $$SlotsTableOrderingComposer,
          $$SlotsTableAnnotationComposer,
          $$SlotsTableCreateCompanionBuilder,
          $$SlotsTableUpdateCompanionBuilder,
          (Slot, $$SlotsTableReferences),
          Slot,
          PrefetchHooks Function({bool cabinetId, bool spaceItemsRefs})
        > {
  $$SlotsTableTableManager(_$AppDatabase db, $SlotsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SlotsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SlotsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SlotsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> emoji = const Value.absent(),
                Value<int> color = const Value.absent(),
                Value<String> cabinetId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SlotsCompanion(
                id: id,
                name: name,
                emoji: emoji,
                color: color,
                cabinetId: cabinetId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String emoji,
                required int color,
                required String cabinetId,
                Value<int> rowid = const Value.absent(),
              }) => SlotsCompanion.insert(
                id: id,
                name: name,
                emoji: emoji,
                color: color,
                cabinetId: cabinetId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$SlotsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({cabinetId = false, spaceItemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (spaceItemsRefs) db.spaceItems],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (cabinetId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.cabinetId,
                                referencedTable: $$SlotsTableReferences
                                    ._cabinetIdTable(db),
                                referencedColumn: $$SlotsTableReferences
                                    ._cabinetIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (spaceItemsRefs)
                    await $_getPrefetchedData<Slot, $SlotsTable, SpaceItem>(
                      currentTable: table,
                      referencedTable: $$SlotsTableReferences
                          ._spaceItemsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$SlotsTableReferences(db, table, p0).spaceItemsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.slotId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$SlotsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SlotsTable,
      Slot,
      $$SlotsTableFilterComposer,
      $$SlotsTableOrderingComposer,
      $$SlotsTableAnnotationComposer,
      $$SlotsTableCreateCompanionBuilder,
      $$SlotsTableUpdateCompanionBuilder,
      (Slot, $$SlotsTableReferences),
      Slot,
      PrefetchHooks Function({bool cabinetId, bool spaceItemsRefs})
    >;
typedef $$SpaceItemsTableCreateCompanionBuilder =
    SpaceItemsCompanion Function({
      Value<int> id,
      required String emoji,
      required String name,
      required String meta,
      required String slotId,
    });
typedef $$SpaceItemsTableUpdateCompanionBuilder =
    SpaceItemsCompanion Function({
      Value<int> id,
      Value<String> emoji,
      Value<String> name,
      Value<String> meta,
      Value<String> slotId,
    });

final class $$SpaceItemsTableReferences
    extends BaseReferences<_$AppDatabase, $SpaceItemsTable, SpaceItem> {
  $$SpaceItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SlotsTable _slotIdTable(_$AppDatabase db) =>
      db.slots.createAlias('space_items__slot_id__slots__id');

  $$SlotsTableProcessedTableManager get slotId {
    final $_column = $_itemColumn<String>('slot_id')!;

    final manager = $$SlotsTableTableManager(
      $_db,
      $_db.slots,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_slotIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SpaceItemsTableFilterComposer
    extends Composer<_$AppDatabase, $SpaceItemsTable> {
  $$SpaceItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get emoji => $composableBuilder(
    column: $table.emoji,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get meta => $composableBuilder(
    column: $table.meta,
    builder: (column) => ColumnFilters(column),
  );

  $$SlotsTableFilterComposer get slotId {
    final $$SlotsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.slotId,
      referencedTable: $db.slots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SlotsTableFilterComposer(
            $db: $db,
            $table: $db.slots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SpaceItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $SpaceItemsTable> {
  $$SpaceItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get emoji => $composableBuilder(
    column: $table.emoji,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get meta => $composableBuilder(
    column: $table.meta,
    builder: (column) => ColumnOrderings(column),
  );

  $$SlotsTableOrderingComposer get slotId {
    final $$SlotsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.slotId,
      referencedTable: $db.slots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SlotsTableOrderingComposer(
            $db: $db,
            $table: $db.slots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SpaceItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SpaceItemsTable> {
  $$SpaceItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get emoji =>
      $composableBuilder(column: $table.emoji, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get meta =>
      $composableBuilder(column: $table.meta, builder: (column) => column);

  $$SlotsTableAnnotationComposer get slotId {
    final $$SlotsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.slotId,
      referencedTable: $db.slots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SlotsTableAnnotationComposer(
            $db: $db,
            $table: $db.slots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SpaceItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SpaceItemsTable,
          SpaceItem,
          $$SpaceItemsTableFilterComposer,
          $$SpaceItemsTableOrderingComposer,
          $$SpaceItemsTableAnnotationComposer,
          $$SpaceItemsTableCreateCompanionBuilder,
          $$SpaceItemsTableUpdateCompanionBuilder,
          (SpaceItem, $$SpaceItemsTableReferences),
          SpaceItem,
          PrefetchHooks Function({bool slotId})
        > {
  $$SpaceItemsTableTableManager(_$AppDatabase db, $SpaceItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SpaceItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SpaceItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SpaceItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> emoji = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> meta = const Value.absent(),
                Value<String> slotId = const Value.absent(),
              }) => SpaceItemsCompanion(
                id: id,
                emoji: emoji,
                name: name,
                meta: meta,
                slotId: slotId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String emoji,
                required String name,
                required String meta,
                required String slotId,
              }) => SpaceItemsCompanion.insert(
                id: id,
                emoji: emoji,
                name: name,
                meta: meta,
                slotId: slotId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SpaceItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({slotId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (slotId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.slotId,
                                referencedTable: $$SpaceItemsTableReferences
                                    ._slotIdTable(db),
                                referencedColumn: $$SpaceItemsTableReferences
                                    ._slotIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SpaceItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SpaceItemsTable,
      SpaceItem,
      $$SpaceItemsTableFilterComposer,
      $$SpaceItemsTableOrderingComposer,
      $$SpaceItemsTableAnnotationComposer,
      $$SpaceItemsTableCreateCompanionBuilder,
      $$SpaceItemsTableUpdateCompanionBuilder,
      (SpaceItem, $$SpaceItemsTableReferences),
      SpaceItem,
      PrefetchHooks Function({bool slotId})
    >;
typedef $$ImportHistoryTableCreateCompanionBuilder =
    ImportHistoryCompanion Function({
      Value<int> id,
      required String platformKey,
      required String emoji,
      required String title,
      required String meta,
      required int count,
      required int iconBg,
      Value<DateTime> importedAt,
    });
typedef $$ImportHistoryTableUpdateCompanionBuilder =
    ImportHistoryCompanion Function({
      Value<int> id,
      Value<String> platformKey,
      Value<String> emoji,
      Value<String> title,
      Value<String> meta,
      Value<int> count,
      Value<int> iconBg,
      Value<DateTime> importedAt,
    });

class $$ImportHistoryTableFilterComposer
    extends Composer<_$AppDatabase, $ImportHistoryTable> {
  $$ImportHistoryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get platformKey => $composableBuilder(
    column: $table.platformKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get emoji => $composableBuilder(
    column: $table.emoji,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get meta => $composableBuilder(
    column: $table.meta,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get count => $composableBuilder(
    column: $table.count,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get iconBg => $composableBuilder(
    column: $table.iconBg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ImportHistoryTableOrderingComposer
    extends Composer<_$AppDatabase, $ImportHistoryTable> {
  $$ImportHistoryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get platformKey => $composableBuilder(
    column: $table.platformKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get emoji => $composableBuilder(
    column: $table.emoji,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get meta => $composableBuilder(
    column: $table.meta,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get count => $composableBuilder(
    column: $table.count,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get iconBg => $composableBuilder(
    column: $table.iconBg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ImportHistoryTableAnnotationComposer
    extends Composer<_$AppDatabase, $ImportHistoryTable> {
  $$ImportHistoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get platformKey => $composableBuilder(
    column: $table.platformKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get emoji =>
      $composableBuilder(column: $table.emoji, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get meta =>
      $composableBuilder(column: $table.meta, builder: (column) => column);

  GeneratedColumn<int> get count =>
      $composableBuilder(column: $table.count, builder: (column) => column);

  GeneratedColumn<int> get iconBg =>
      $composableBuilder(column: $table.iconBg, builder: (column) => column);

  GeneratedColumn<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => column,
  );
}

class $$ImportHistoryTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ImportHistoryTable,
          ImportHistoryData,
          $$ImportHistoryTableFilterComposer,
          $$ImportHistoryTableOrderingComposer,
          $$ImportHistoryTableAnnotationComposer,
          $$ImportHistoryTableCreateCompanionBuilder,
          $$ImportHistoryTableUpdateCompanionBuilder,
          (
            ImportHistoryData,
            BaseReferences<
              _$AppDatabase,
              $ImportHistoryTable,
              ImportHistoryData
            >,
          ),
          ImportHistoryData,
          PrefetchHooks Function()
        > {
  $$ImportHistoryTableTableManager(_$AppDatabase db, $ImportHistoryTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ImportHistoryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ImportHistoryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ImportHistoryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> platformKey = const Value.absent(),
                Value<String> emoji = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> meta = const Value.absent(),
                Value<int> count = const Value.absent(),
                Value<int> iconBg = const Value.absent(),
                Value<DateTime> importedAt = const Value.absent(),
              }) => ImportHistoryCompanion(
                id: id,
                platformKey: platformKey,
                emoji: emoji,
                title: title,
                meta: meta,
                count: count,
                iconBg: iconBg,
                importedAt: importedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String platformKey,
                required String emoji,
                required String title,
                required String meta,
                required int count,
                required int iconBg,
                Value<DateTime> importedAt = const Value.absent(),
              }) => ImportHistoryCompanion.insert(
                id: id,
                platformKey: platformKey,
                emoji: emoji,
                title: title,
                meta: meta,
                count: count,
                iconBg: iconBg,
                importedAt: importedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ImportHistoryTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ImportHistoryTable,
      ImportHistoryData,
      $$ImportHistoryTableFilterComposer,
      $$ImportHistoryTableOrderingComposer,
      $$ImportHistoryTableAnnotationComposer,
      $$ImportHistoryTableCreateCompanionBuilder,
      $$ImportHistoryTableUpdateCompanionBuilder,
      (
        ImportHistoryData,
        BaseReferences<_$AppDatabase, $ImportHistoryTable, ImportHistoryData>,
      ),
      ImportHistoryData,
      PrefetchHooks Function()
    >;
typedef $$CategoriesTableCreateCompanionBuilder =
    CategoriesCompanion Function({
      required String id,
      required String label,
      required String emoji,
      Value<bool> isBuiltIn,
      Value<int> sortOrder,
      Value<int> rowid,
    });
typedef $$CategoriesTableUpdateCompanionBuilder =
    CategoriesCompanion Function({
      Value<String> id,
      Value<String> label,
      Value<String> emoji,
      Value<bool> isBuiltIn,
      Value<int> sortOrder,
      Value<int> rowid,
    });

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get emoji => $composableBuilder(
    column: $table.emoji,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isBuiltIn => $composableBuilder(
    column: $table.isBuiltIn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get emoji => $composableBuilder(
    column: $table.emoji,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isBuiltIn => $composableBuilder(
    column: $table.isBuiltIn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get emoji =>
      $composableBuilder(column: $table.emoji, builder: (column) => column);

  GeneratedColumn<bool> get isBuiltIn =>
      $composableBuilder(column: $table.isBuiltIn, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);
}

class $$CategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoriesTable,
          Category,
          $$CategoriesTableFilterComposer,
          $$CategoriesTableOrderingComposer,
          $$CategoriesTableAnnotationComposer,
          $$CategoriesTableCreateCompanionBuilder,
          $$CategoriesTableUpdateCompanionBuilder,
          (Category, BaseReferences<_$AppDatabase, $CategoriesTable, Category>),
          Category,
          PrefetchHooks Function()
        > {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<String> emoji = const Value.absent(),
                Value<bool> isBuiltIn = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion(
                id: id,
                label: label,
                emoji: emoji,
                isBuiltIn: isBuiltIn,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String label,
                required String emoji,
                Value<bool> isBuiltIn = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion.insert(
                id: id,
                label: label,
                emoji: emoji,
                isBuiltIn: isBuiltIn,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoriesTable,
      Category,
      $$CategoriesTableFilterComposer,
      $$CategoriesTableOrderingComposer,
      $$CategoriesTableAnnotationComposer,
      $$CategoriesTableCreateCompanionBuilder,
      $$CategoriesTableUpdateCompanionBuilder,
      (Category, BaseReferences<_$AppDatabase, $CategoriesTable, Category>),
      Category,
      PrefetchHooks Function()
    >;
typedef $$SettingsTableCreateCompanionBuilder =
    SettingsCompanion Function({
      required String key,
      Value<String> value,
      Value<int> rowid,
    });
typedef $$SettingsTableUpdateCompanionBuilder =
    SettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$SettingsTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsTable,
          Setting,
          $$SettingsTableFilterComposer,
          $$SettingsTableOrderingComposer,
          $$SettingsTableAnnotationComposer,
          $$SettingsTableCreateCompanionBuilder,
          $$SettingsTableUpdateCompanionBuilder,
          (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
          Setting,
          PrefetchHooks Function()
        > {
  $$SettingsTableTableManager(_$AppDatabase db, $SettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SettingsCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsTable,
      Setting,
      $$SettingsTableFilterComposer,
      $$SettingsTableOrderingComposer,
      $$SettingsTableAnnotationComposer,
      $$SettingsTableCreateCompanionBuilder,
      $$SettingsTableUpdateCompanionBuilder,
      (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
      Setting,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ItemsTableTableManager get items =>
      $$ItemsTableTableManager(_db, _db.items);
  $$RoomsTableTableManager get rooms =>
      $$RoomsTableTableManager(_db, _db.rooms);
  $$CabinetsTableTableManager get cabinets =>
      $$CabinetsTableTableManager(_db, _db.cabinets);
  $$SlotsTableTableManager get slots =>
      $$SlotsTableTableManager(_db, _db.slots);
  $$SpaceItemsTableTableManager get spaceItems =>
      $$SpaceItemsTableTableManager(_db, _db.spaceItems);
  $$ImportHistoryTableTableManager get importHistory =>
      $$ImportHistoryTableTableManager(_db, _db.importHistory);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
}
