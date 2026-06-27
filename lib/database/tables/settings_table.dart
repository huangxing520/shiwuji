part of '../database.dart';

/// 键值对设置表 —— 存储用户偏好、WebDAV 配置等
class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text().withDefault(const Constant(''))();

  @override
  Set<Column> get primaryKey => {key};
}
