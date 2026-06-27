// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../space_item_dao.dart';

// ignore_for_file: type=lint
mixin _$SpaceItemDaoMixin on DatabaseAccessor<AppDatabase> {
  $RoomsTable get rooms => attachedDatabase.rooms;
  $CabinetsTable get cabinets => attachedDatabase.cabinets;
  $SlotsTable get slots => attachedDatabase.slots;
  $SpaceItemsTable get spaceItems => attachedDatabase.spaceItems;
  SpaceItemDaoManager get managers => SpaceItemDaoManager(this);
}

class SpaceItemDaoManager {
  final _$SpaceItemDaoMixin _db;
  SpaceItemDaoManager(this._db);
  $$RoomsTableTableManager get rooms =>
      $$RoomsTableTableManager(_db.attachedDatabase, _db.rooms);
  $$CabinetsTableTableManager get cabinets =>
      $$CabinetsTableTableManager(_db.attachedDatabase, _db.cabinets);
  $$SlotsTableTableManager get slots =>
      $$SlotsTableTableManager(_db.attachedDatabase, _db.slots);
  $$SpaceItemsTableTableManager get spaceItems =>
      $$SpaceItemsTableTableManager(_db.attachedDatabase, _db.spaceItems);
}
