// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../item_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 跨页面共享的"待选分类"——例如从分类管理页跳转到物品库时，传递需要选中的分类 key。
/// 读取方应用后应清空，避免下次进入时重复生效。
/// 使用 keepAlive 是因为：设置方（来源页）只用 ref.read 写入、不监听，
/// autoDispose 会在写入后立即销毁 provider，导致目标页 initState 读到 null。

@ProviderFor(PendingCategory)
final pendingCategoryProvider = PendingCategoryProvider._();

/// 跨页面共享的"待选分类"——例如从分类管理页跳转到物品库时，传递需要选中的分类 key。
/// 读取方应用后应清空，避免下次进入时重复生效。
/// 使用 keepAlive 是因为：设置方（来源页）只用 ref.read 写入、不监听，
/// autoDispose 会在写入后立即销毁 provider，导致目标页 initState 读到 null。
final class PendingCategoryProvider
    extends $NotifierProvider<PendingCategory, String?> {
  /// 跨页面共享的"待选分类"——例如从分类管理页跳转到物品库时，传递需要选中的分类 key。
  /// 读取方应用后应清空，避免下次进入时重复生效。
  /// 使用 keepAlive 是因为：设置方（来源页）只用 ref.read 写入、不监听，
  /// autoDispose 会在写入后立即销毁 provider，导致目标页 initState 读到 null。
  PendingCategoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pendingCategoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pendingCategoryHash();

  @$internal
  @override
  PendingCategory create() => PendingCategory();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$pendingCategoryHash() => r'aeb0c963feb512833652ef08ed57dda83af77fe7';

/// 跨页面共享的"待选分类"——例如从分类管理页跳转到物品库时，传递需要选中的分类 key。
/// 读取方应用后应清空，避免下次进入时重复生效。
/// 使用 keepAlive 是因为：设置方（来源页）只用 ref.read 写入、不监听，
/// autoDispose 会在写入后立即销毁 provider，导致目标页 initState 读到 null。

abstract class _$PendingCategory extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// 跨页面共享的"待选状态筛选"——从首页待处理事项跳转到物品库时，传递需要筛选的状态。
/// 使用 keepAlive 是因为：设置方（首页）只用 ref.read 写入、不监听，
/// autoDispose 会在写入后立即销毁 provider，导致目标页 initState 读到 null。

@ProviderFor(PendingStatusFilter)
final pendingStatusFilterProvider = PendingStatusFilterProvider._();

/// 跨页面共享的"待选状态筛选"——从首页待处理事项跳转到物品库时，传递需要筛选的状态。
/// 使用 keepAlive 是因为：设置方（首页）只用 ref.read 写入、不监听，
/// autoDispose 会在写入后立即销毁 provider，导致目标页 initState 读到 null。
final class PendingStatusFilterProvider
    extends $NotifierProvider<PendingStatusFilter, String?> {
  /// 跨页面共享的"待选状态筛选"——从首页待处理事项跳转到物品库时，传递需要筛选的状态。
  /// 使用 keepAlive 是因为：设置方（首页）只用 ref.read 写入、不监听，
  /// autoDispose 会在写入后立即销毁 provider，导致目标页 initState 读到 null。
  PendingStatusFilterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pendingStatusFilterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pendingStatusFilterHash();

  @$internal
  @override
  PendingStatusFilter create() => PendingStatusFilter();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$pendingStatusFilterHash() =>
    r'750e79178b8852ad326fd24c908f34849c88ad7b';

/// 跨页面共享的"待选状态筛选"——从首页待处理事项跳转到物品库时，传递需要筛选的状态。
/// 使用 keepAlive 是因为：设置方（首页）只用 ref.read 写入、不监听，
/// autoDispose 会在写入后立即销毁 provider，导致目标页 initState 读到 null。

abstract class _$PendingStatusFilter extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// 核心 Items Provider —— AsyncNotifier，从数据库读写

@ProviderFor(Items)
final itemsProvider = ItemsProvider._();

/// 核心 Items Provider —— AsyncNotifier，从数据库读写
final class ItemsProvider extends $AsyncNotifierProvider<Items, List<Item>> {
  /// 核心 Items Provider —— AsyncNotifier，从数据库读写
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
}

String _$itemsHash() => r'28b96db61837498f3a1951a93e071dee67b0003c';

/// 核心 Items Provider —— AsyncNotifier，从数据库读写

abstract class _$Items extends $AsyncNotifier<List<Item>> {
  FutureOr<List<Item>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Item>>, List<Item>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Item>>, List<Item>>,
              AsyncValue<List<Item>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
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

String _$itemCountHash() => r'89f231c28384a6703b16bf73c1e5cbaefd1fb9c2';

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

String _$pendingCountHash() => r'79553d7619ce49079cacee63aa23dc45646851c1';

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

String _$warrantyCountHash() => r'e154f9855e030cf1528763d4820528c3c2407626';

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

String _$pendingItemsHash() => r'2d095643672b75b173897f4d76ae49c0c7664353';

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

String _$recentItemsHash() => r'c969f1d4be8faf36ee06d1d5a2b14e2c842da153';

@ProviderFor(totalValue)
final totalValueProvider = TotalValueProvider._();

final class TotalValueProvider extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  TotalValueProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'totalValueProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$totalValueHash();

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    return totalValue(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$totalValueHash() => r'418cf1e01166b59db422477964dda17fa1fcf4f7';

@ProviderFor(idleCount)
final idleCountProvider = IdleCountProvider._();

final class IdleCountProvider extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  IdleCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'idleCountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$idleCountHash();

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    return idleCount(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$idleCountHash() => r'a75a3d577468fd32fe3b35fc1366cf82fffad4d0';

/// 本周新增物品数量（周一 00:00 至今）
/// 数据口径：Items.purchaseDate >= 本周一，与 drift 表 purchase_date 字段一致。

@ProviderFor(weeklyNewCount)
final weeklyNewCountProvider = WeeklyNewCountProvider._();

/// 本周新增物品数量（周一 00:00 至今）
/// 数据口径：Items.purchaseDate >= 本周一，与 drift 表 purchase_date 字段一致。

final class WeeklyNewCountProvider extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  /// 本周新增物品数量（周一 00:00 至今）
  /// 数据口径：Items.purchaseDate >= 本周一，与 drift 表 purchase_date 字段一致。
  WeeklyNewCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'weeklyNewCountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$weeklyNewCountHash();

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    return weeklyNewCount(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$weeklyNewCountHash() => r'0c372b2f3f571691555c3da27896e70d5f8268fe';

/// 本月新增物品总价值（1 日 00:00 至今）
/// 数据口径：Items.purchaseDate >= 本月 1 日，price 求和，与 drift 表字段一致。

@ProviderFor(monthlyGrowth)
final monthlyGrowthProvider = MonthlyGrowthProvider._();

/// 本月新增物品总价值（1 日 00:00 至今）
/// 数据口径：Items.purchaseDate >= 本月 1 日，price 求和，与 drift 表字段一致。

final class MonthlyGrowthProvider
    extends $FunctionalProvider<double, double, double>
    with $Provider<double> {
  /// 本月新增物品总价值（1 日 00:00 至今）
  /// 数据口径：Items.purchaseDate >= 本月 1 日，price 求和，与 drift 表字段一致。
  MonthlyGrowthProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'monthlyGrowthProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$monthlyGrowthHash();

  @$internal
  @override
  $ProviderElement<double> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  double create(Ref ref) {
    return monthlyGrowth(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double>(value),
    );
  }
}

String _$monthlyGrowthHash() => r'f8e794d9b7670c6e4833753ecca663ade25324d8';

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

String _$itemByIdHash() => r'35d593e24f1651ed030fda7d5e7b0f036f0f5d2b';

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
