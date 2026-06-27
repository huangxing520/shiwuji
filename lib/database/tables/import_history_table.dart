part of '../database.dart';

class ImportHistory extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get platformKey => text()();
  TextColumn get emoji => text()();
  TextColumn get title => text()();
  TextColumn get meta => text()();
  IntColumn get count => integer()();
  IntColumn get iconBg => integer()();
  DateTimeColumn get importedAt => dateTime().withDefault(currentDateAndTime)();
}
