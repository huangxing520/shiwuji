// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../profile_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 用户资料（昵称 + 头像 emoji）

@ProviderFor(ProfileManager)
final profileManagerProvider = ProfileManagerProvider._();

/// 用户资料（昵称 + 头像 emoji）
final class ProfileManagerProvider
    extends $AsyncNotifierProvider<ProfileManager, Map<String, String>> {
  /// 用户资料（昵称 + 头像 emoji）
  ProfileManagerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profileManagerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profileManagerHash();

  @$internal
  @override
  ProfileManager create() => ProfileManager();
}

String _$profileManagerHash() => r'6c77444b7df98439604cbd165001b5e6d15dd1ca';

/// 用户资料（昵称 + 头像 emoji）

abstract class _$ProfileManager extends $AsyncNotifier<Map<String, String>> {
  FutureOr<Map<String, String>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<Map<String, String>>, Map<String, String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Map<String, String>>, Map<String, String>>,
              AsyncValue<Map<String, String>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// 个人中心数据统计

@ProviderFor(profileStats)
final profileStatsProvider = ProfileStatsProvider._();

/// 个人中心数据统计

final class ProfileStatsProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, dynamic>>,
          Map<String, dynamic>,
          FutureOr<Map<String, dynamic>>
        >
    with
        $FutureModifier<Map<String, dynamic>>,
        $FutureProvider<Map<String, dynamic>> {
  /// 个人中心数据统计
  ProfileStatsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profileStatsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profileStatsHash();

  @$internal
  @override
  $FutureProviderElement<Map<String, dynamic>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Map<String, dynamic>> create(Ref ref) {
    return profileStats(ref);
  }
}

String _$profileStatsHash() => r'4bf4638b3c18fd10717eb7adf02c21d4e2573efc';
