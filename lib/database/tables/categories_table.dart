part of '../database.dart';

class Categories extends Table {
  TextColumn get id => text()();
  TextColumn get label => text()();
  TextColumn get emoji => text()();
  BoolColumn get isBuiltIn => boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}
