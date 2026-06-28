import 'package:drift/drift.dart' hide Column;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../database/database.dart' as db;
import '../daos/category_dao.dart';
import '../models/category.dart';
import '../models/category_item.dart';
import 'database_provider.dart';

part 'generated/category_provider.g.dart';

// ─── Provider ─────────────────────────────────────────

/// 物品库 tab 与新增物品页分类选择器共用的合并分类列表。
/// 派生自 [CategoryManager]（数据库分类，含用户增删改）+ [Category.virtualCategories]（固定虚拟物品分类）。
/// 用户在分类管理页的新增/编辑/删除会通过此 provider 实时反映到所有使用方。
@riverpod
List<Category> availableCategories(Ref ref) {
  final asyncDb = ref.watch(categoryManagerProvider);
  final dbCats = asyncDb.value ?? const <CategoryItem>[];
  return [
    // 数据库分类：id 作为 key（与物品 categoryKey 一致），label/emoji 来自数据库
    for (final c in dbCats) Category(c.id, c.label, emoji: c.emoji),
    // 虚拟物品分类：固定项，不参与用户增删
    ...Category.virtualCategories,
  ];
}

@riverpod
class CategoryManager extends _$CategoryManager {
  @override
  Future<List<CategoryItem>> build() async {
    final dao = ref.watch(categoryDaoProvider);
    final rows = await dao.getAllCategories();
    return rows
        .map((r) => CategoryItem(
              id: r.id,
              label: r.label,
              emoji: r.emoji,
              isBuiltIn: r.isBuiltIn,
              sortOrder: r.sortOrder,
            ))
        .toList();
  }

  CategoryDao get _dao => ref.read(categoryDaoProvider);

  /// 新增分类
  Future<void> addCategory({
    required String label,
    required String emoji,
  }) async {
    final id = 'custom_${DateTime.now().millisecondsSinceEpoch}';
    final nextOrder = await _dao.nextSortOrder();
    await _dao.insertCategory(db.CategoriesCompanion.insert(
      id: id,
      label: label,
      emoji: emoji,
      sortOrder: Value(nextOrder),
    ));
    ref.invalidateSelf();
  }

  /// 更新分类（标签、emoji）
  Future<void> updateCategory(
    String id, {
    String? label,
    String? emoji,
  }) async {
    final existing = await _dao.getById(id);
    if (existing == null) return;
    await _dao.updateCategory(existing.copyWith(
      label: label ?? existing.label,
      emoji: emoji ?? existing.emoji,
    ).toCompanion(false));
    ref.invalidateSelf();
  }

  /// 删除分类（同时将该分类下的物品改为「未分类」）
  Future<void> deleteCategory(String id) async {
    final existing = await _dao.getById(id);
    if (existing == null) return;
    await _dao.unassignItems(existing.label);
    await _dao.deleteCategory(id);
    ref.invalidateSelf();
  }

  /// 重排自定义分类
  Future<void> reorderCustom(int oldIndex, int newIndex) async {
    final all = state.value ?? [];
    final customs = all.where((c) => !c.isBuiltIn).toList();

    if (oldIndex < newIndex) newIndex -= 1;
    final item = customs.removeAt(oldIndex);
    customs.insert(newIndex, item);

    // 从内置分类数量开始编号
    final builtInCount = all.where((c) => c.isBuiltIn).length;
    final Map<String, int> orderMap = {};
    for (int i = 0; i < customs.length; i++) {
      orderMap[customs[i].id] = builtInCount + i;
    }
    await _dao.updateSortOrder(orderMap);
    ref.invalidateSelf();
  }

  /// 统计某分类下的物品数量
  Future<int> itemCountForCategory(String categoryLabel) =>
      _dao.itemCount(categoryLabel);

  /// 获取所有分类的物品计数映射
  Future<Map<String, int>> allItemCounts() => _dao.allItemCounts();
}
