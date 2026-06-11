// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Items)
final itemsProvider = ItemsProvider._();

final class ItemsProvider extends $NotifierProvider<Items, List<Item>> {
  ItemsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'itemsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$itemsHash();

  @$internal
  @override
  Items create() => Items();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Item> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Item>>(value),
    );
  }
}

String _$itemsHash() => r'917b6a396d4865e85dd11bda5d238ab030af2978';

abstract class _$Items extends $Notifier<List<Item>> {
  List<Item> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<List<Item>, List<Item>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<Item>, List<Item>>,
              List<Item>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(itemCount)
final itemCountProvider = ItemCountProvider._();

final class ItemCountProvider extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  ItemCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'itemCountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$itemCountHash();

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    return itemCount(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$itemCountHash() => r'106190ba183eebe291bd9577a7ffe22bd28ecce4';

@ProviderFor(pendingCount)
final pendingCountProvider = PendingCountProvider._();

final class PendingCountProvider extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  PendingCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pendingCountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pendingCountHash();

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    return pendingCount(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$pendingCountHash() => r'f287ab3620757f1b4646ede23660800bdb35772c';

@ProviderFor(warrantyCount)
final warrantyCountProvider = WarrantyCountProvider._();

final class WarrantyCountProvider extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  WarrantyCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'warrantyCountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$warrantyCountHash();

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    return warrantyCount(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$warrantyCountHash() => r'49d1a1a0106baf5f0870528a2b34e5264133c78d';

@ProviderFor(pendingItems)
final pendingItemsProvider = PendingItemsProvider._();

final class PendingItemsProvider
    extends $FunctionalProvider<List<Item>, List<Item>, List<Item>>
    with $Provider<List<Item>> {
  PendingItemsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pendingItemsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pendingItemsHash();

  @$internal
  @override
  $ProviderElement<List<Item>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<Item> create(Ref ref) {
    return pendingItems(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Item> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Item>>(value),
    );
  }
}

String _$pendingItemsHash() => r'f0b97dc0030f7fd3183351eb1439503305ddf2dd';

@ProviderFor(recentItems)
final recentItemsProvider = RecentItemsProvider._();

final class RecentItemsProvider
    extends $FunctionalProvider<List<Item>, List<Item>, List<Item>>
    with $Provider<List<Item>> {
  RecentItemsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recentItemsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recentItemsHash();

  @$internal
  @override
  $ProviderElement<List<Item>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<Item> create(Ref ref) {
    return recentItems(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Item> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Item>>(value),
    );
  }
}

String _$recentItemsHash() => r'5d65e5ed8e6b5604956fbd9b151693b07eb24833';

@ProviderFor(itemById)
final itemByIdProvider = ItemByIdFamily._();

final class ItemByIdProvider extends $FunctionalProvider<Item?, Item?, Item?>
    with $Provider<Item?> {
  ItemByIdProvider._({
    required ItemByIdFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'itemByIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$itemByIdHash();

  @override
  String toString() {
    return r'itemByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<Item?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Item? create(Ref ref) {
    final argument = this.argument as String;
    return itemById(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Item? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Item?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ItemByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$itemByIdHash() => r'd57145016ee203b8773b20c552778b750fd94555';

final class ItemByIdFamily extends $Family
    with $FunctionalFamilyOverride<Item?, String> {
  ItemByIdFamily._()
    : super(
        retry: null,
        name: r'itemByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ItemByIdProvider call(String id) =>
      ItemByIdProvider._(argument: id, from: this);

  @override
  String toString() => r'itemByIdProvider';
}
