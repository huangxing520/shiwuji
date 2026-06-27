part of '../database.dart';

class Rooms extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get emoji => text()();
  IntColumn get color => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
