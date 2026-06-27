// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../slot_dao.dart';

// ignore_for_file: type=lint
mixin _$SlotDaoMixin on DatabaseAccessor<AppDatabase> {
  $RoomsTable get rooms => attachedDatabase.rooms;
  $CabinetsTable get cabinets => attachedDatabase.cabinets;
  $SlotsTable get slots => attachedDatabase.slots;
  SlotDaoManager get managers => SlotDaoManager(this);
}

class SlotDaoManager {
  final _$SlotDaoMixin _db;
  SlotDaoManager(this._db);
  $$RoomsTableTableManager get rooms =>
      $$RoomsTableTableManager(_db.attachedDatabase, _db.rooms);
  $$CabinetsTableTableManager get cabinets =>
      $$CabinetsTableTableManager(_db.attachedDatabase, _db.cabinets);
  $$SlotsTableTableManager get slots =>
      $$SlotsTableTableManager(_db.attachedDatabase, _db.slots);
}
