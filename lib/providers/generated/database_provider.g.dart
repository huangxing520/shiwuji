// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../database_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 数据库实例 Provider

@ProviderFor(database)
final databaseProvider = DatabaseProvider._();

/// 数据库实例 Provider

final class DatabaseProvider
    extends $FunctionalProvider<AppDatabase, AppDatabase, AppDatabase>
    with $Provider<AppDatabase> {
  /// 数据库实例 Provider
  DatabaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'databaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$databaseHash();

  @$internal
  @override
  $ProviderElement<AppDatabase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppDatabase create(Ref ref) {
    return database(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppDatabase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppDatabase>(value),
    );
  }
}

String _$databaseHash() => r'b43f5a38382427710fbceefeb419518e859b35ea';

/// DAO Providers

@ProviderFor(itemDao)
final itemDaoProvider = ItemDaoProvider._();

/// DAO Providers

final class ItemDaoProvider
    extends $FunctionalProvider<ItemDao, ItemDao, ItemDao>
    with $Provider<ItemDao> {
  /// DAO Providers
  ItemDaoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'itemDaoProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$itemDaoHash();

  @$internal
  @override
  $ProviderElement<ItemDao> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ItemDao create(Ref ref) {
    return itemDao(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ItemDao value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ItemDao>(value),
    );
  }
}

String _$itemDaoHash() => r'367ecb104815b072531e6886861952a0fe4ea447';

@ProviderFor(roomDao)
final roomDaoProvider = RoomDaoProvider._();

final class RoomDaoProvider
    extends $FunctionalProvider<RoomDao, RoomDao, RoomDao>
    with $Provider<RoomDao> {
  RoomDaoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'roomDaoProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$roomDaoHash();

  @$internal
  @override
  $ProviderElement<RoomDao> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  RoomDao create(Ref ref) {
    return roomDao(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RoomDao value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RoomDao>(value),
    );
  }
}

String _$roomDaoHash() => r'47de92928b067bf155950ea95c5a0bda91940d6c';

@ProviderFor(cabinetDao)
final cabinetDaoProvider = CabinetDaoProvider._();

final class CabinetDaoProvider
    extends $FunctionalProvider<CabinetDao, CabinetDao, CabinetDao>
    with $Provider<CabinetDao> {
  CabinetDaoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cabinetDaoProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cabinetDaoHash();

  @$internal
  @override
  $ProviderElement<CabinetDao> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CabinetDao create(Ref ref) {
    return cabinetDao(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CabinetDao value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CabinetDao>(value),
    );
  }
}

String _$cabinetDaoHash() => r'fba7020f300a9f4e3b17de6c75146d8a8a03c5ee';

@ProviderFor(slotDao)
final slotDaoProvider = SlotDaoProvider._();

final class SlotDaoProvider
    extends $FunctionalProvider<SlotDao, SlotDao, SlotDao>
    with $Provider<SlotDao> {
  SlotDaoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'slotDaoProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$slotDaoHash();

  @$internal
  @override
  $ProviderElement<SlotDao> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SlotDao create(Ref ref) {
    return slotDao(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SlotDao value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SlotDao>(value),
    );
  }
}

String _$slotDaoHash() => r'bbd02a177796147dc78fb3531db2e302790eaa6d';

@ProviderFor(spaceItemDao)
final spaceItemDaoProvider = SpaceItemDaoProvider._();

final class SpaceItemDaoProvider
    extends $FunctionalProvider<SpaceItemDao, SpaceItemDao, SpaceItemDao>
    with $Provider<SpaceItemDao> {
  SpaceItemDaoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'spaceItemDaoProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$spaceItemDaoHash();

  @$internal
  @override
  $ProviderElement<SpaceItemDao> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SpaceItemDao create(Ref ref) {
    return spaceItemDao(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SpaceItemDao value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SpaceItemDao>(value),
    );
  }
}

String _$spaceItemDaoHash() => r'c5cf70011ce1c0a8ee288dba20227f9eb9ffd5a6';

@ProviderFor(importHistoryDao)
final importHistoryDaoProvider = ImportHistoryDaoProvider._();

final class ImportHistoryDaoProvider
    extends
        $FunctionalProvider<
          ImportHistoryDao,
          ImportHistoryDao,
          ImportHistoryDao
        >
    with $Provider<ImportHistoryDao> {
  ImportHistoryDaoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'importHistoryDaoProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$importHistoryDaoHash();

  @$internal
  @override
  $ProviderElement<ImportHistoryDao> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ImportHistoryDao create(Ref ref) {
    return importHistoryDao(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ImportHistoryDao value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ImportHistoryDao>(value),
    );
  }
}

String _$importHistoryDaoHash() => r'1e78d5621e767aca35ccd44767324c1516e2a331';

@ProviderFor(categoryDao)
final categoryDaoProvider = CategoryDaoProvider._();

final class CategoryDaoProvider
    extends $FunctionalProvider<CategoryDao, CategoryDao, CategoryDao>
    with $Provider<CategoryDao> {
  CategoryDaoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'categoryDaoProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$categoryDaoHash();

  @$internal
  @override
  $ProviderElement<CategoryDao> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CategoryDao create(Ref ref) {
    return categoryDao(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CategoryDao value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CategoryDao>(value),
    );
  }
}

String _$categoryDaoHash() => r'b9320ecc692e08efff3d09ced42cba69f287275f';

@ProviderFor(settingsDao)
final settingsDaoProvider = SettingsDaoProvider._();

final class SettingsDaoProvider
    extends $FunctionalProvider<SettingsDao, SettingsDao, SettingsDao>
    with $Provider<SettingsDao> {
  SettingsDaoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'settingsDaoProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$settingsDaoHash();

  @$internal
  @override
  $ProviderElement<SettingsDao> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SettingsDao create(Ref ref) {
    return settingsDao(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SettingsDao value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SettingsDao>(value),
    );
  }
}

String _$settingsDaoHash() => r'cfd216ec1b0d4c806e7a9a5ff6aca473ea425c91';
