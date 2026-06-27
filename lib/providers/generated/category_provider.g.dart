// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../category_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CategoryManager)
final categoryManagerProvider = CategoryManagerProvider._();

final class CategoryManagerProvider
    extends $AsyncNotifierProvider<CategoryManager, List<CategoryItem>> {
  CategoryManagerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'categoryManagerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$categoryManagerHash();

  @$internal
  @override
  CategoryManager create() => CategoryManager();
}

String _$categoryManagerHash() => r'f4430b8b5d51ae5f3a7ffcf1039b3dce18fb8b38';

abstract class _$CategoryManager extends $AsyncNotifier<List<CategoryItem>> {
  FutureOr<List<CategoryItem>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<CategoryItem>>, List<CategoryItem>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<CategoryItem>>, List<CategoryItem>>,
              AsyncValue<List<CategoryItem>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
