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

  @override
  Set<Column> get primaryKey => {id};
}
