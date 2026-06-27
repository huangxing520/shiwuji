part of '../database.dart';

class Slots extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get emoji => text()();
  IntColumn get color => integer()();
  TextColumn get cabinetId => text().references(Cabinets, #id)();

  @override
  Set<Column> get primaryKey => {id};
}
