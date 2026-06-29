part of '../database.dart';

class Cabinets extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get emoji => text()();
  IntColumn get color => integer()();
  TextColumn get roomId => text().references(Rooms, #id)();
  BoolColumn get hasPhoto => boolean().withDefault(const Constant(false))();
  TextColumn get photoPath => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
