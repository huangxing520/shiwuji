import 'package:drift/drift.dart';
import '../database/database.dart';

part 'generated/category_dao.g.dart';

@DriftAccessor(tables: [Categories, Items])
class CategoryDao extends DatabaseAccessor<AppDatabase>
    with _$CategoryDaoMixin {
  CategoryDao(super.db);

  /// 获取所有分类，按 sortOrder 排序
  Future<List<Category>> getAllCategories() =>
      (select(categories)..orderBy([(t) => OrderingTerm.asc(t.sortOrder)])).get();

  /// 监听分类变化
  Stream<List<Category>> watchAllCategories() =>
      (select(categories)..orderBy([(t) => OrderingTerm.asc(t.sortOrder)])).watch();

  /// 按 id 获取
  Future<Category?> getById(String id) =>
      (select(categories)..where((t) => t.id.equals(id))).getSingleOrNull();

  /// 新增分类
  Future<int> insertCategory(CategoriesCompanion category) =>
      into(categories).insert(category);

  /// 更新分类
  Future<bool> updateCategory(CategoriesCompanion category) =>
      update(categories).replace(category);

  /// 删除分类
  Future<int> deleteCategory(String id) =>
      (delete(categories)..where((t) => t.id.equals(id))).go();

  /// 批量更新 sortOrder（用于拖拽排序后一次性写入）
  Future<void> updateSortOrder(Map<String, int> idToOrder) async {
    await batch((b) {
      idToOrder.forEach((id, order) {
        b.update(
          categories,
          CategoriesCompanion(sortOrder: Value(order)),
          where: (t) => t.id.equals(id),
        );
      });
    });
  }

  /// 获取下一个 sortOrder（自定义分类追加用）
  Future<int> nextSortOrder() async {
    final result = await customSelect(
      'SELECT COALESCE(MAX(sort_order), 0) + 1 AS next_order FROM categories',
    ).get();
    return result.first.read<int>('next_order');
  }

  /// 统计某分类 label 下的物品数量
  Future<int> itemCount(String categoryLabel) async {
    final result = await customSelect(
      'SELECT COUNT(*) AS total FROM items WHERE category = ?',
      variables: [Variable.withString(categoryLabel)],
    ).get();
    return result.first.read<int>('total');
  }

  /// 获取所有分类的物品计数
  Future<Map<String, int>> allItemCounts() async {
    final result = await customSelect(
      'SELECT category, COUNT(*) AS total FROM items GROUP BY category',
    ).get();
    return {
      for (final row in result)
        row.read<String>('category'): row.read<int>('total'),
    };
  }

  /// 将某分类下的所有物品改为「未分类」（删除分类前调用）
  Future<int> unassignItems(String categoryLabel) async {
    return await customUpdate(
      'UPDATE items SET category = ?, category_key = ? WHERE category = ?',
      variables: [
        Variable.withString('未分类'),
        Variable.withString(''),
        Variable.withString(categoryLabel),
      ],
      updates: {items},
    );
  }
}
