// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../room_dao.dart';

// ignore_for_file: type=lint
mixin _$RoomDaoMixin on DatabaseAccessor<AppDatabase> {
  $RoomsTable get rooms => attachedDatabase.rooms;
  RoomDaoManager get managers => RoomDaoManager(this);
}

class RoomDaoManager {
  final _$RoomDaoMixin _db;
  RoomDaoManager(this._db);
  $$RoomsTableTableManager get rooms =>
      $$RoomsTableTableManager(_db.attachedDatabase, _db.rooms);
}
