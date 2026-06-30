import 'dart:convert';
import 'dart:io' as io;
import 'package:archive/archive.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:webdav_client/webdav_client.dart';
import '../database/database.dart';

/// WebDAV 备份文件信息
class BackupFileInfo {
  final String name;
  final String path;

  /// 解析出的备份时间（精确到分钟），解析失败为 null
  final DateTime? time;

  /// 备份时物品数量（旧格式文件名无此信息时为 null）
  final int? itemCount;

  /// 是否为 ZIP 格式（false 表示旧版 JSON）
  final bool isZip;

  BackupFileInfo({
    required this.name,
    required this.path,
    this.time,
    this.itemCount,
    this.isZip = true,
  });
}

/// WebDAV 备份服务
///
/// 备份内容以 ZIP 格式打包，内含 data.json（结构化数据）。
/// 恢复时兼容新版 .zip 与旧版 .json 两种格式。
class WebDavService {
  Client? _client;
  String _backupDir = '/shiwuji_backups';

  static const _filenamePrefix = 'shiwuji_backup_';

  /// 配置 WebDAV 客户端
  void configure(String url, String user, String password, {String? dir}) {
    _client = newClient(url, user: user, password: password, debug: false);
    // webdav_client 内部以 Dio 发起请求；writeFromFile 等以 Stream 作为请求体，
    // 而 Dio 默认的 ImplyContentTypeInterceptor 无法从 Stream 推断 content-type，
    // 会打印 "_FileStream cannot be used to imply a default content-type" 警告
    // （实际不影响上传，WebDAV PUT 无需显式 content-type）。此处移除该拦截器以消除噪音。
    _client!.c.interceptors.removeImplyContentTypeInterceptor();
    if (dir != null && dir.isNotEmpty) {
      _backupDir = dir.startsWith('/') ? dir : '/$dir';
    }
  }

  /// 测试连接
  Future<bool> testConnection() async {
    if (_client == null) return false;
    try {
      await _client!.ping();
      debugPrint('[WebDavService] 连接测试成功');
      return true;
    } catch (e) {
      debugPrint('[WebDavService] 连接测试失败: $e');
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

  /// 执行备份 —— 收集所有数据打包为 ZIP 并上传
  ///
  /// 返回生成的文件名。
  Future<String> backup(AppDatabase db) async {
    if (_client == null) throw Exception('WebDAV 未配置');
    await _ensureBackupDir();

    final now = DateTime.now();
    debugPrint('[WebDavService] 开始备份，时间: ${now.toIso8601String()}');

    // ─── 收集所有数据 ───────────────────────────
    final items = await db.select(db.items).get();
    final rooms = await db.select(db.rooms).get();
    final cabinets = await db.select(db.cabinets).get();
    final slots = await db.select(db.slots).get();
    final spaceItems = await db.select(db.spaceItems).get();
    final categories = await db.select(db.categories).get();
    final importHistory = await db.select(db.importHistory).get();
    final settings = await db.select(db.settings).get();

    final itemCount = items.length;
    debugPrint(
      '[WebDavService] 数据统计: 物品 $itemCount, 分类 ${categories.length}, '
      '房间 ${rooms.length}, 柜体 ${cabinets.length}, 格位 ${slots.length}, '
      '收纳物品 ${spaceItems.length}, 导入记录 ${importHistory.length}',
    );

    final data = {
      'version': db.schemaVersion,
      'timestamp': now.toIso8601String(),
      'itemCount': itemCount,
      'items': items.map((e) => e.toJson()).toList(),
      'rooms': rooms.map((e) => e.toJson()).toList(),
      'cabinets': cabinets.map((e) => e.toJson()).toList(),
      'slots': slots.map((e) => e.toJson()).toList(),
      'spaceItems': spaceItems.map((e) => e.toJson()).toList(),
      'categories': categories.map((e) => e.toJson()).toList(),
      'importHistory': importHistory.map((e) => e.toJson()).toList(),
      'settings': settings
          .map((e) => {'key': e.key, 'value': e.value})
          .toList(),
    };

    final jsonStr = jsonEncode(data);
    final filename =
        '$_filenamePrefix${now.year}${_pad(now.month)}${_pad(now.day)}_'
        '${_pad(now.hour)}${_pad(now.minute)}${_pad(now.second)}'
        '_n$itemCount.zip';
    final remotePath = '$_backupDir/$filename';

    // ─── 打包 ZIP ───────────────────────────────
    final archive = Archive();
    archive.addFile(ArchiveFile.string('data.json', jsonStr));
    final zipBytes = ZipEncoder().encode(archive);

    // 写入临时文件再上传
    final tempDir = await getTemporaryDirectory();
    final tempFile = io.File('${tempDir.path}/$filename');
    await tempFile.writeAsBytes(zipBytes);

    try {
      await _client!.writeFromFile(tempFile.path, remotePath);
      debugPrint(
        '[WebDavService] 备份上传成功: $filename (${zipBytes.length} bytes)',
      );
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
      final backups = <BackupFileInfo>[];
      for (final f in files) {
        final name = f.name ?? '';
        final isZip = name.endsWith('.zip');
        final isJson = name.endsWith('.json');
        if (!isZip && !isJson) continue;
        backups.add(
          BackupFileInfo(
            name: name,
            path: f.path ?? '',
            isZip: isZip,
            time: _parseFilenameTime(name),
            itemCount: _parseFilenameCount(name),
          ),
        );
      }
      backups.sort((a, b) {
        // 按时间倒序，无时间的排最后
        final at = a.time;
        final bt = b.time;
        if (at == null && bt == null) return b.name.compareTo(a.name);
        if (at == null) return 1;
        if (bt == null) return -1;
        return bt.compareTo(at);
      });
      debugPrint('[WebDavService] 列出备份 ${backups.length} 条');
      return backups;
    } catch (e) {
      debugPrint('[WebDavService] 列出备份失败: $e');
      return [];
    }
  }

  /// 恢复备份 —— 下载并还原所有数据
  ///
  /// 返回恢复的物品数量。
  Future<int> restore(AppDatabase db, String remotePath) async {
    if (_client == null) throw Exception('WebDAV 未配置');
    final name = remotePath.split('/').last;
    debugPrint('[WebDavService] 开始恢复: $name');

    final bytes = await _client!.read(remotePath);
    final Map<String, dynamic> data;

    if (name.endsWith('.zip')) {
      // ZIP 格式：解压取出 data.json
      final archive = ZipDecoder().decodeBytes(bytes);
      final dataFile = archive.findFile('data.json');
      if (dataFile == null) throw Exception('备份文件缺少 data.json');
      final jsonBytes = dataFile.content;
      data = jsonDecode(utf8.decode(jsonBytes)) as Map<String, dynamic>;
    } else {
      // 旧版 JSON 格式
      data = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
    }

    final restoredItemCount = await _restoreData(db, data);
    debugPrint('[WebDavService] 恢复完成，物品 $restoredItemCount 件');
    return restoredItemCount;
  }

  /// 实际数据还原逻辑（事务内执行）
  Future<int> _restoreData(AppDatabase db, Map<String, dynamic> data) async {
    await db.transaction(() async {
      // ─── 清空所有表（按依赖逆序）───
      await db.delete(db.spaceItems).go();
      await db.delete(db.slots).go();
      await db.delete(db.cabinets).go();
      await db.delete(db.rooms).go();
      await db.delete(db.importHistory).go();
      await db.delete(db.items).go();
      await db.delete(db.categories).go();
      // settings 使用 upsert，不清空（保留 webdav_ 配置等未备份项）

      // ─── 恢复 rooms ───────────────────────────
      if (data['rooms'] != null) {
        for (final j in (data['rooms'] as List).cast<Map<String, dynamic>>()) {
          await db
              .into(db.rooms)
              .insert(
                RoomsCompanion.insert(
                  id: j['id'] as String,
                  name: j['name'] as String,
                  emoji: j['emoji'] as String,
                  color: j['color'] as int,
                ),
              );
        }
      }

      // ─── 恢复 cabinets（含 photoPath）─────────
      if (data['cabinets'] != null) {
        for (final j
            in (data['cabinets'] as List).cast<Map<String, dynamic>>()) {
          await db
              .into(db.cabinets)
              .insert(
                CabinetsCompanion.insert(
                  id: j['id'] as String,
                  name: j['name'] as String,
                  emoji: j['emoji'] as String,
                  color: j['color'] as int,
                  roomId: j['roomId'] as String,
                  hasPhoto: Value(j['hasPhoto'] as bool? ?? false),
                  photoPath: Value(j['photoPath'] as String?),
                ),
              );
        }
      }

      // ─── 恢复 slots（含 expectedItems）─────────
      if (data['slots'] != null) {
        for (final j in (data['slots'] as List).cast<Map<String, dynamic>>()) {
          await db
              .into(db.slots)
              .insert(
                SlotsCompanion.insert(
                  id: j['id'] as String,
                  name: j['name'] as String,
                  emoji: j['emoji'] as String,
                  color: j['color'] as int,
                  cabinetId: j['cabinetId'] as String,
                  expectedItems: Value(j['expectedItems'] as int? ?? 1),
                ),
              );
        }
      }

      // ─── 恢复 spaceItems ──────────────────────
      if (data['spaceItems'] != null) {
        for (final j
            in (data['spaceItems'] as List).cast<Map<String, dynamic>>()) {
          await db
              .into(db.spaceItems)
              .insert(
                SpaceItemsCompanion.insert(
                  emoji: j['emoji'] as String,
                  name: j['name'] as String,
                  meta: j['meta'] as String,
                  slotId: j['slotId'] as String,
                ),
              );
        }
      }

      // ─── 恢复 items（含全部字段）──────────────
      if (data['items'] != null) {
        for (final j in (data['items'] as List).cast<Map<String, dynamic>>()) {
          await db
              .into(db.items)
              .insert(
                ItemsCompanion.insert(
                  id: j['id'] as String,
                  name: j['name'] as String,
                  price: (j['price'] as num).toDouble(),
                  purchaseDate: DateTime.parse(j['purchaseDate'] as String),
                  emoji: Value(j['emoji'] as String? ?? ''),
                  category: Value(j['category'] as String? ?? '未分类'),
                  location: Value(j['location'] as String? ?? '未知'),
                  warrantyDays: Value(j['warrantyDays'] as int? ?? 0),
                  shelfLifeDays: Value(j['shelfLifeDays'] as int? ?? 0),
                  status: Value(j['status'] as String? ?? 'safe'),
                  categoryKey: Value(j['categoryKey'] as String? ?? ''),
                  cabinetId: Value(j['cabinetId'] as String?),
                  slotId: Value(j['slotId'] as String?),
                  photos: Value(j['photos'] as String? ?? '[]'),
                  brand: Value(j['brand'] as String? ?? ''),
                  note: Value(j['note'] as String? ?? ''),
                  templateKey: Value(j['templateKey'] as String? ?? 'none'),
                  templateData: Value(j['templateData'] as String? ?? '{}'),
                  source: Value(j['source'] as String? ?? '线下购买'),
                  warrantyReminderOn: Value(
                    j['warrantyReminderOn'] as bool? ?? false,
                  ),
                  shelfLifeReminderOn: Value(
                    j['shelfLifeReminderOn'] as bool? ?? false,
                  ),
                  maintenanceReminderOn: Value(
                    j['maintenanceReminderOn'] as bool? ?? false,
                  ),
                  maintenanceCycle: Value(
                    j['maintenanceCycle'] as String? ?? '',
                  ),
                ),
              );
        }
      }

      // ─── 恢复 categories ──────────────────────
      if (data['categories'] != null) {
        for (final j
            in (data['categories'] as List).cast<Map<String, dynamic>>()) {
          await db
              .into(db.categories)
              .insert(
                CategoriesCompanion.insert(
                  id: j['id'] as String,
                  label: j['label'] as String,
                  emoji: j['emoji'] as String,
                  isBuiltIn: Value(j['isBuiltIn'] as bool? ?? false),
                  sortOrder: Value(j['sortOrder'] as int? ?? 0),
                ),
              );
        }
      }

      // ─── 恢复 importHistory ───────────────────
      if (data['importHistory'] != null) {
        for (final j
            in (data['importHistory'] as List).cast<Map<String, dynamic>>()) {
          await db
              .into(db.importHistory)
              .insert(
                ImportHistoryCompanion.insert(
                  platformKey: j['platformKey'] as String,
                  emoji: j['emoji'] as String,
                  title: j['title'] as String,
                  meta: j['meta'] as String,
                  count: j['count'] as int,
                  iconBg: j['iconBg'] as int,
                  importedAt: Value(DateTime.parse(j['importedAt'] as String)),
                ),
              );
        }
      }

      // ─── 恢复 settings（排除 webdav_ 配置）────
      if (data['settings'] != null) {
        for (final s
            in (data['settings'] as List).cast<Map<String, dynamic>>()) {
          final key = s['key'] as String;
          if (!key.startsWith('webdav_')) {
            await db
                .into(db.settings)
                .insertOnConflictUpdate(
                  SettingsCompanion.insert(
                    key: key,
                    value: Value(s['value'] as String),
                  ),
                );
          }
        }
      }
    });

    // 返回物品数量（优先用元数据，否则从实际数据计算）
    final metaCount = data['itemCount'] as int?;
    if (metaCount != null) return metaCount;
    final itemsList = data['items'] as List?;
    return itemsList?.length ?? 0;
  }

  /// 删除备份
  Future<void> deleteBackup(String remotePath) async {
    if (_client == null) throw Exception('WebDAV 未配置');
    await _client!.remove(remotePath);
    debugPrint('[WebDavService] 已删除备份: ${remotePath.split('/').last}');
  }

  // ─── 文件名解析 ──────────────────────────────

  /// 从文件名解析备份时间
  ///
  /// 支持格式：
  /// - shiwuji_backup_20260627_143000_n42.zip
  /// - shiwuji_backup_20260627_143000.zip
  /// - shiwuji_backup_20260627_143000.json（旧版）
  static DateTime? _parseFilenameTime(String name) {
    try {
      var base = _stripExtension(name);
      if (base.startsWith(_filenamePrefix)) {
        base = base.substring(_filenamePrefix.length);
      }
      // 去掉 _n{count} 后缀
      final nIdx = base.lastIndexOf('_n');
      if (nIdx > 0 && RegExp(r'^_n\d+$').hasMatch(base.substring(nIdx))) {
        base = base.substring(0, nIdx);
      }
      // base = YYYYMMDD_HHmmss
      final parts = base.split('_');
      if (parts.length < 2) return null;
      final date = parts[0];
      final time = parts[1];
      return DateTime(
        int.parse(date.substring(0, 4)),
        int.parse(date.substring(4, 6)),
        int.parse(date.substring(6, 8)),
        int.parse(time.substring(0, 2)),
        int.parse(time.substring(2, 4)),
        int.parse(time.substring(4, 6)),
      );
    } catch (_) {
      return null;
    }
  }

  /// 从文件名解析物品数量
  static int? _parseFilenameCount(String name) {
    try {
      var base = _stripExtension(name);
      final nMatch = RegExp(r'_n(\d+)$').firstMatch(base);
      if (nMatch != null) {
        return int.tryParse(nMatch.group(1)!);
      }
    } catch (_) {}
    return null;
  }

  static String _stripExtension(String name) {
    if (name.endsWith('.zip')) return name.substring(0, name.length - 4);
    if (name.endsWith('.json')) return name.substring(0, name.length - 5);
    return name;
  }

  String _pad(int n) => n.toString().padLeft(2, '0');
}
