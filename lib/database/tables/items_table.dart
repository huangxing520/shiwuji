part of '../database.dart';

class Items extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  RealColumn get price => real()();
  TextColumn get emoji => text().withDefault(const Constant(''))();
  TextColumn get category => text().withDefault(const Constant('未分类'))();
  TextColumn get location => text().withDefault(const Constant('未知'))();
  DateTimeColumn get purchaseDate => dateTime()();
  // 保修天数（0 表示未设置）
  IntColumn get warrantyDays => integer().withDefault(const Constant(0))();
  // 保质期天数（0 表示未设置）
  IntColumn get shelfLifeDays => integer().withDefault(const Constant(0))();
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
  // 物品来源（线下购买/亲友赠送/二手收购/闲置已有/其他）
  TextColumn get source => text().withDefault(const Constant('线下购买'))();
  // 三个智能提醒开关（用户显式设置，区别于旧的启发式判断）
  BoolColumn get warrantyReminderOn =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get shelfLifeReminderOn =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get maintenanceReminderOn =>
      boolean().withDefault(const Constant(false))();
  // 保养周期（每月/每季度/每半年/每年，空字符串表示未设置）
  TextColumn get maintenanceCycle => text().withDefault(const Constant(''))();

  @override
  Set<Column> get primaryKey => {id};
}
