// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../storage_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(rooms)
final roomsProvider = RoomsProvider._();

final class RoomsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<model.Room>>,
          List<model.Room>,
          FutureOr<List<model.Room>>
        >
    with $FutureModifier<List<model.Room>>, $FutureProvider<List<model.Room>> {
  RoomsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'roomsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$roomsHash();

  @$internal
  @override
  $FutureProviderElement<List<model.Room>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<model.Room>> create(Ref ref) {
    return rooms(ref);
  }
}

String _$roomsHash() => r'0069ee51bb8a3597f6ee3bf09428e6d485795d01';

/// 新增房间

@ProviderFor(RoomActions)
final roomActionsProvider = RoomActionsProvider._();

/// 新增房间
final class RoomActionsProvider
    extends $AsyncNotifierProvider<RoomActions, void> {
  /// 新增房间
  RoomActionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'roomActionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$roomActionsHash();

  @$internal
  @override
  RoomActions create() => RoomActions();
}

String _$roomActionsHash() => r'bf8197a19fbec64df97d1a7f93082ba8b3f72ae8';

/// 新增房间

abstract class _$RoomActions extends $AsyncNotifier<void> {
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

@ProviderFor(cabinetsByRoom)
final cabinetsByRoomProvider = CabinetsByRoomFamily._();

final class CabinetsByRoomProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<model.Cabinet>>,
          List<model.Cabinet>,
          FutureOr<List<model.Cabinet>>
        >
    with
        $FutureModifier<List<model.Cabinet>>,
        $FutureProvider<List<model.Cabinet>> {
  CabinetsByRoomProvider._({
    required CabinetsByRoomFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'cabinetsByRoomProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$cabinetsByRoomHash();

  @override
  String toString() {
    return r'cabinetsByRoomProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<model.Cabinet>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<model.Cabinet>> create(Ref ref) {
    final argument = this.argument as String;
    return cabinetsByRoom(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CabinetsByRoomProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$cabinetsByRoomHash() => r'75b69cccb833516538ea2cb3bcab1455e4c9d32e';

final class CabinetsByRoomFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<model.Cabinet>>, String> {
  CabinetsByRoomFamily._()
    : super(
        retry: null,
        name: r'cabinetsByRoomProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CabinetsByRoomProvider call(String roomId) =>
      CabinetsByRoomProvider._(argument: roomId, from: this);

  @override
  String toString() => r'cabinetsByRoomProvider';
}

/// 新增柜子

@ProviderFor(CabinetActions)
final cabinetActionsProvider = CabinetActionsProvider._();

/// 新增柜子
final class CabinetActionsProvider
    extends $AsyncNotifierProvider<CabinetActions, void> {
  /// 新增柜子
  CabinetActionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cabinetActionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cabinetActionsHash();

  @$internal
  @override
  CabinetActions create() => CabinetActions();
}

String _$cabinetActionsHash() => r'9cd888ed9834f7e12a738391ae4b8786aee9784a';

/// 新增柜子

abstract class _$CabinetActions extends $AsyncNotifier<void> {
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

@ProviderFor(slotsByCabinet)
final slotsByCabinetProvider = SlotsByCabinetFamily._();

final class SlotsByCabinetProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<model.Slot>>,
          List<model.Slot>,
          FutureOr<List<model.Slot>>
        >
    with $FutureModifier<List<model.Slot>>, $FutureProvider<List<model.Slot>> {
  SlotsByCabinetProvider._({
    required SlotsByCabinetFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'slotsByCabinetProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$slotsByCabinetHash();

  @override
  String toString() {
    return r'slotsByCabinetProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<model.Slot>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<model.Slot>> create(Ref ref) {
    final argument = this.argument as String;
    return slotsByCabinet(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SlotsByCabinetProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$slotsByCabinetHash() => r'4be61bd3d9c6236e546dec12191d51a2174adce3';

final class SlotsByCabinetFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<model.Slot>>, String> {
  SlotsByCabinetFamily._()
    : super(
        retry: null,
        name: r'slotsByCabinetProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SlotsByCabinetProvider call(String cabinetId) =>
      SlotsByCabinetProvider._(argument: cabinetId, from: this);

  @override
  String toString() => r'slotsByCabinetProvider';
}

/// 新增格位

@ProviderFor(SlotActions)
final slotActionsProvider = SlotActionsProvider._();

/// 新增格位
final class SlotActionsProvider
    extends $AsyncNotifierProvider<SlotActions, void> {
  /// 新增格位
  SlotActionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'slotActionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$slotActionsHash();

  @$internal
  @override
  SlotActions create() => SlotActions();
}

String _$slotActionsHash() => r'cad1e597547c8d09a4960be936913c11302f08a5';

/// 新增格位

abstract class _$SlotActions extends $AsyncNotifier<void> {
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

@ProviderFor(spaceItemsBySlot)
final spaceItemsBySlotProvider = SpaceItemsBySlotFamily._();

final class SpaceItemsBySlotProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<model.SpaceItem>>,
          List<model.SpaceItem>,
          FutureOr<List<model.SpaceItem>>
        >
    with
        $FutureModifier<List<model.SpaceItem>>,
        $FutureProvider<List<model.SpaceItem>> {
  SpaceItemsBySlotProvider._({
    required SpaceItemsBySlotFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'spaceItemsBySlotProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$spaceItemsBySlotHash();

  @override
  String toString() {
    return r'spaceItemsBySlotProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<model.SpaceItem>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<model.SpaceItem>> create(Ref ref) {
    final argument = this.argument as String;
    return spaceItemsBySlot(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SpaceItemsBySlotProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$spaceItemsBySlotHash() => r'47d535f66fe524e6791c4a47d21231f92fd9220c';

final class SpaceItemsBySlotFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<model.SpaceItem>>, String> {
  SpaceItemsBySlotFamily._()
    : super(
        retry: null,
        name: r'spaceItemsBySlotProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SpaceItemsBySlotProvider call(String slotId) =>
      SpaceItemsBySlotProvider._(argument: slotId, from: this);

  @override
  String toString() => r'spaceItemsBySlotProvider';
}

/// 格位物品操作

@ProviderFor(SpaceItemActions)
final spaceItemActionsProvider = SpaceItemActionsProvider._();

/// 格位物品操作
final class SpaceItemActionsProvider
    extends $AsyncNotifierProvider<SpaceItemActions, void> {
  /// 格位物品操作
  SpaceItemActionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'spaceItemActionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$spaceItemActionsHash();

  @$internal
  @override
  SpaceItemActions create() => SpaceItemActions();
}

String _$spaceItemActionsHash() => r'2a082e90829125791916a3f02c47a09f98ee7cc3';

/// 格位物品操作

abstract class _$SpaceItemActions extends $AsyncNotifier<void> {
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

@ProviderFor(storageStats)
final storageStatsProvider = StorageStatsProvider._();

final class StorageStatsProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, int>>,
          Map<String, int>,
          FutureOr<Map<String, int>>
        >
    with $FutureModifier<Map<String, int>>, $FutureProvider<Map<String, int>> {
  StorageStatsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'storageStatsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$storageStatsHash();

  @$internal
  @override
  $FutureProviderElement<Map<String, int>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Map<String, int>> create(Ref ref) {
    return storageStats(ref);
  }
}

String _$storageStatsHash() => r'01dde11578036e5564cb4d912b3d7620e5a8a9a5';

/// 查询所有柜体+格子，扁平化为节点列表（供选择器使用）

@ProviderFor(storageLocationTree)
final storageLocationTreeProvider = StorageLocationTreeProvider._();

/// 查询所有柜体+格子，扁平化为节点列表（供选择器使用）

final class StorageLocationTreeProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<StorageLocationNode>>,
          List<StorageLocationNode>,
          FutureOr<List<StorageLocationNode>>
        >
    with
        $FutureModifier<List<StorageLocationNode>>,
        $FutureProvider<List<StorageLocationNode>> {
  /// 查询所有柜体+格子，扁平化为节点列表（供选择器使用）
  StorageLocationTreeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'storageLocationTreeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$storageLocationTreeHash();

  @$internal
  @override
  $FutureProviderElement<List<StorageLocationNode>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<StorageLocationNode>> create(Ref ref) {
    return storageLocationTree(ref);
  }
}

String _$storageLocationTreeHash() =>
    r'a39fd8919bfa9d4dd97d72285ea9962975b5398a';
