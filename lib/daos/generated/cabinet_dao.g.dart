// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../cabinet_dao.dart';

// ignore_for_file: type=lint
mixin _$CabinetDaoMixin on DatabaseAccessor<AppDatabase> {
  $RoomsTable get rooms => attachedDatabase.rooms;
  $CabinetsTable get cabinets => attachedDatabase.cabinets;
  CabinetDaoManager get managers => CabinetDaoManager(this);
}

class CabinetDaoManager {
  final _$CabinetDaoMixin _db;
  CabinetDaoManager(this._db);
  $$RoomsTableTableManager get rooms =>
      $$RoomsTableTableManager(_db.attachedDatabase, _db.rooms);
  $$CabinetsTableTableManager get cabinets =>
      $$CabinetsTableTableManager(_db.attachedDatabase, _db.cabinets);
}
