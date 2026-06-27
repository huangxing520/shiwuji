import 'dart:convert';
import 'dart:io' as io;
import 'package:drift/drift.dart' hide Column;
import 'package:path_provider/path_provider.dart';
import 'package:webdav_client/webdav_client.dart';
import '../database/database.dart';

/// WebDAV 备份文件信息
class BackupFileInfo {
  final String name;
  final String path;

  BackupFileInfo({required this.name, required this.path});
}

/// WebDAV 备份服务
class WebDavService {
  Client? _client;
  String _backupDir = '/shiwuji_backups';

  /// 配置 WebDAV 客户端
  void configure(String url, String user, String password, {String? dir}) {
    _client = newClient(
      url,
      user: user,
      password: password,
      debug: false,
    );
    if (dir != null && dir.isNotEmpty) {
      _backupDir = dir.startsWith('/') ? dir : '/$dir';
    }
  }

  /// 测试连接
  Future<bool> testConnection() async {
    if (_client == null) return false;
    try {
      await _client!.ping();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// 确保备份目录存在
  Future<void> _ensureBackupDir() async {
    if (_client == null) throw Exception('WebDAV 未配置');
    try {
      await _client!.mkdirAll(_backupDir);
    } catch (_) {
      // 目录可能已存在
    }
  }

  /// 执行备份
  Future<String> backup(AppDatabase db) async {
    if (_client == null) throw Exception('WebDAV 未配置');
    await _ensureBackupDir();

    // 收集所有数据
    final items = await db.select(db.items).get();
    final rooms = await db.select(db.rooms).get();
    final cabinets = await db.select(db.cabinets).get();
    final slots = await db.select(db.slots).get();
    final spaceItems = await db.select(db.spaceItems).get();
    final categories = await db.select(db.categories).get();
    final settings = await db.select(db.settings).get();

    final data = {
      'version': 1,
      'timestamp': DateTime.now().toIso8601String(),
      'items': items.map((e) => e.toJson()).toList(),
      'rooms': rooms.map((e) => e.toJson()).toList(),
      'cabinets': cabinets.map((e) => e.toJson()).toList(),
      'slots': slots.map((e) => e.toJson()).toList(),
      'spaceItems': spaceItems.map((e) => e.toJson()).toList(),
      'categories': categories.map((e) => e.toJson()).toList(),
      'settings': settings.map((e) => {'key': e.key, 'value': e.value}).toList(),
    };

    final jsonStr = jsonEncode(data);
    final now = DateTime.now();
    final filename =
        'shiwuji_backup_${now.year}${_pad(now.month)}${_pad(now.day)}_${_pad(now.hour)}${_pad(now.minute)}${_pad(now.second)}.json';
    final remotePath = '$_backupDir/$filename';

    // 写入临时文件再上传
    final tempDir = await getTemporaryDirectory();
    final tempFile = io.File('${tempDir.path}/$filename');
    await tempFile.writeAsString(jsonStr, encoding: utf8);

    try {
      await _client!.writeFromFile(tempFile.path, remotePath);
    } finally {
      if (tempFile.existsSync()) tempFile.deleteSync();
    }

    return filename;
  }

  /// 列出备份历史
  Future<List<BackupFileInfo>> listBackups() async {
    if (_client == null) throw Exception('WebDAV 未配置');
    try {
      final files = await _client!.readDir(_backupDir);
      return files
          .where((f) => f.name?.endsWith('.json') ?? false)
          .map((f) => BackupFileInfo(
                name: f.name ?? '',
                path: f.path ?? '',
              ))
          .toList()
        ..sort((a, b) => b.name.compareTo(a.name));
    } catch (_) {
      return [];
    }
  }

  /// 恢复备份
  Future<void> restore(AppDatabase db, String remotePath) async {
    if (_client == null) throw Exception('WebDAV 未配置');

    final bytes = await _client!.read(remotePath);
    final jsonStr = utf8.decode(bytes);
    final data = jsonDecode(jsonStr) as Map<String, dynamic>;

    await db.transaction(() async {
      // 清空所有表
      await db.delete(db.spaceItems).go();
      await db.delete(db.slots).go();
      await db.delete(db.cabinets).go();
      await db.delete(db.rooms).go();
      await db.delete(db.items).go();
      await db.delete(db.categories).go();

      // 恢复 rooms（先恢复被引用的表）
      if (data['rooms'] != null) {
        for (final j in (data['rooms'] as List).cast<Map<String, dynamic>>()) {
          await db.into(db.rooms).insert(RoomsCompanion.insert(
                id: j['id'] as String,
                name: j['name'] as String,
                emoji: j['emoji'] as String,
                color: j['color'] as int,
              ));
        }
      }

      // 恢复 cabinets
      if (data['cabinets'] != null) {
        for (final j in (data['cabinets'] as List).cast<Map<String, dynamic>>()) {
          await db.into(db.cabinets).insert(CabinetsCompanion.insert(
                id: j['id'] as String,
                name: j['name'] as String,
                emoji: j['emoji'] as String,
                color: j['color'] as int,
                roomId: j['roomId'] as String,
                hasPhoto: Value(j['hasPhoto'] as bool? ?? false),
              ));
        }
      }

      // 恢复 slots
      if (data['slots'] != null) {
        for (final j in (data['slots'] as List).cast<Map<String, dynamic>>()) {
          await db.into(db.slots).insert(SlotsCompanion.insert(
                id: j['id'] as String,
                name: j['name'] as String,
                emoji: j['emoji'] as String,
                color: j['color'] as int,
                cabinetId: j['cabinetId'] as String,
              ));
        }
      }

      // 恢复 spaceItems
      if (data['spaceItems'] != null) {
        for (final j in (data['spaceItems'] as List).cast<Map<String, dynamic>>()) {
          await db.into(db.spaceItems).insert(SpaceItemsCompanion.insert(
                emoji: j['emoji'] as String,
                name: j['name'] as String,
                meta: j['meta'] as String,
                slotId: j['slotId'] as String,
              ));
        }
      }

      // 恢复 items
      if (data['items'] != null) {
        for (final j in (data['items'] as List).cast<Map<String, dynamic>>()) {
          await db.into(db.items).insert(ItemsCompanion.insert(
                id: j['id'] as String,
                name: j['name'] as String,
                price: (j['price'] as num).toDouble(),
                purchaseDate: DateTime.parse(j['purchaseDate'] as String),
                emoji: Value(j['emoji'] as String? ?? ''),
                category: Value(j['category'] as String? ?? '未分类'),
                location: Value(j['location'] as String? ?? '未知'),
                warrantyDays: Value(j['warrantyDays'] as int? ?? 365),
                status: Value(j['status'] as String? ?? 'safe'),
                categoryKey: Value(j['categoryKey'] as String? ?? ''),
              ));
        }
      }

      // 恢复 categories
      if (data['categories'] != null) {
        for (final j in (data['categories'] as List).cast<Map<String, dynamic>>()) {
          await db.into(db.categories).insert(CategoriesCompanion.insert(
                id: j['id'] as String,
                label: j['label'] as String,
                emoji: j['emoji'] as String,
                isBuiltIn: Value(j['isBuiltIn'] as bool? ?? false),
                sortOrder: Value(j['sortOrder'] as int? ?? 0),
              ));
        }
      }

      // 恢复 settings（排除 webdav 相关配置）
      if (data['settings'] != null) {
        for (final s in (data['settings'] as List).cast<Map<String, dynamic>>()) {
          final key = s['key'] as String;
          if (!key.startsWith('webdav_')) {
            await db.into(db.settings).insertOnConflictUpdate(
                  SettingsCompanion.insert(
                    key: key,
                    value: Value(s['value'] as String),
                  ),
                );
          }
        }
      }
    });
  }

  /// 删除备份
  Future<void> deleteBackup(String remotePath) async {
    if (_client == null) throw Exception('WebDAV 未配置');
    await _client!.remove(remotePath);
  }

  String _pad(int n) => n.toString().padLeft(2, '0');
}
