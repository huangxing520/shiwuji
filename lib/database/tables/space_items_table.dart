part of '../database.dart';

class SpaceItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get emoji => text()();
  TextColumn get name => text()();
  TextColumn get meta => text()();
  TextColumn get slotId => text().references(Slots, #id)();
}
