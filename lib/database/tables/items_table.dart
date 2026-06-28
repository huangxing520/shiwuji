part of '../database.dart';

class Items extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  RealColumn get price => real()();
  TextColumn get emoji => text().withDefault(const Constant(''))();
  TextColumn get category => text().withDefault(const Constant('未分类'))();
  TextColumn get location => text().withDefault(const Constant('未知'))();
  DateTimeColumn get purchaseDate => dateTime()();
  IntColumn get warrantyDays => integer().withDefault(const Constant(365))();
  TextColumn get status => text().withDefault(const Constant('safe'))();
  TextColumn get categoryKey => text().withDefault(const Constant(''))();
  TextColumn get cabinetId => text().nullable()();
  TextColumn get slotId => text().nullable()();
  // 照片路径列表（JSON 数组）
  TextColumn get photos => text().withDefault(const Constant('[]'))();
  // 品牌备注等扩展信息（支持编辑预填充）
  TextColumn get brand => text().withDefault(const Constant(''))();
  TextColumn get note => text().withDefault(const Constant(''))();
  TextColumn get templateKey => text().withDefault(const Constant('none'))();
  // 模板专属字段值（JSON 对象 {fieldId: value}）
  TextColumn get templateData => text().withDefault(const Constant('{}'))();

  @override
  Set<Column> get primaryKey => {id};
}
