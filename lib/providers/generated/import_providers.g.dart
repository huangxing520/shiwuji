// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../import_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(platforms)
final platformsProvider = PlatformsProvider._();

final class PlatformsProvider
    extends
        $FunctionalProvider<
          List<PlatformData>,
          List<PlatformData>,
          List<PlatformData>
        >
    with $Provider<List<PlatformData>> {
  PlatformsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'platformsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$platformsHash();

  @$internal
  @override
  $ProviderElement<List<PlatformData>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<PlatformData> create(Ref ref) {
    return platforms(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<PlatformData> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<PlatformData>>(value),
    );
  }
}

String _$platformsHash() => r'dd4af6f5c3b7372efe5f0cad363506d4be420d69';

@ProviderFor(mockOrders)
final mockOrdersProvider = MockOrdersProvider._();

final class MockOrdersProvider
    extends
        $FunctionalProvider<List<MockOrder>, List<MockOrder>, List<MockOrder>>
    with $Provider<List<MockOrder>> {
  MockOrdersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mockOrdersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mockOrdersHash();

  @$internal
  @override
  $ProviderElement<List<MockOrder>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<MockOrder> create(Ref ref) {
    return mockOrders(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<MockOrder> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<MockOrder>>(value),
    );
  }
}

String _$mockOrdersHash() => r'cb04becafe1f2161dc42838cfc65f3ff71120069';

@ProviderFor(importHistory)
final importHistoryProvider = ImportHistoryProvider._();

final class ImportHistoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<HistoryRecord>>,
          List<HistoryRecord>,
          FutureOr<List<HistoryRecord>>
        >
    with
        $FutureModifier<List<HistoryRecord>>,
        $FutureProvider<List<HistoryRecord>> {
  ImportHistoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'importHistoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$importHistoryHash();

  @$internal
  @override
  $FutureProviderElement<List<HistoryRecord>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<HistoryRecord>> create(Ref ref) {
    return importHistory(ref);
  }
}

String _$importHistoryHash() => r'4db7eda23a18b40b407774aad4c4ed967b592ba0';

@ProviderFor(ImportActions)
final importActionsProvider = ImportActionsProvider._();

final class ImportActionsProvider
    extends $AsyncNotifierProvider<ImportActions, void> {
  ImportActionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'importActionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$importActionsHash();

  @$internal
  @override
  ImportActions create() => ImportActions();
}

String _$importActionsHash() => r'9dd18a95d8766496bac6e5f8bc0888529e78512d';

abstract class _$ImportActions extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(importStats)
final importStatsProvider = ImportStatsProvider._();

final class ImportStatsProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, int>>,
          Map<String, int>,
          FutureOr<Map<String, int>>
        >
    with $FutureModifier<Map<String, int>>, $FutureProvider<Map<String, int>> {
  ImportStatsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'importStatsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$importStatsHash();

  @$internal
  @override
  $FutureProviderElement<Map<String, int>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Map<String, int>> create(Ref ref) {
    return importStats(ref);
  }
}

String _$importStatsHash() => r'f92fbd9c25802ef55014c7eb4dc654c5d9099d18';
