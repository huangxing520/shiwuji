// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../import_history_dao.dart';

// ignore_for_file: type=lint
mixin _$ImportHistoryDaoMixin on DatabaseAccessor<AppDatabase> {
  $ImportHistoryTable get importHistory => attachedDatabase.importHistory;
  ImportHistoryDaoManager get managers => ImportHistoryDaoManager(this);
}

class ImportHistoryDaoManager {
  final _$ImportHistoryDaoMixin _db;
  ImportHistoryDaoManager(this._db);
  $$ImportHistoryTableTableManager get importHistory =>
      $$ImportHistoryTableTableManager(_db.attachedDatabase, _db.importHistory);
}
