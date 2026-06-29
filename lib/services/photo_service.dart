import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

/// 单张照片在表单中的状态
enum PhotoStatus { uploading, success, failed }

/// 表单中的照片条目：path 为本地文件绝对路径
class PhotoEntry {
  final String path;
  final PhotoStatus status;
  const PhotoEntry({required this.path, required this.status});

  PhotoEntry copyWith({String? path, PhotoStatus? status}) =>
      PhotoEntry(path: path ?? this.path, status: status ?? this.status);
}

/// 照片处理结果
class PickResult {
  final List<PhotoEntry> entries; // 本次成功加入的照片
  final String? error; // 校验失败原因（格式/大小超限等）

  const PickResult({this.entries = const [], this.error});
}

/// 照片服务：负责选图、校验、拷贝到应用文档目录。
///
/// 约束：仅接受 JPG/PNG，单张不超过 5MB，每次最多补齐到上限。
class PhotoService {
  PhotoService._();
  static final PhotoService instance = PhotoService._();

  static const int maxPhotos = 10;
  static const int maxBytes = 5 * 1024 * 1024; // 5MB

  final _picker = ImagePicker();
  final _uuid = const Uuid();

  /// 从相册多选照片，返回拷贝后的本地路径条目。
  /// [remaining] 为当前还能添加几张（上限 - 已有数）。
  /// 注意：当 remaining=1 时使用 pickImage（单选），因为 pickMultiImage 要求 limit>=2。
  Future<PickResult> pickFromGallery({required int remaining}) async {
    if (remaining <= 0) {
      return const PickResult(error: '最多添加 $maxPhotos 张照片');
    }

    if (remaining == 1) {
      // pickMultiImage 要求 limit>=2，单选时使用 pickImage
      debugPrint('[PhotoService] 单张选图，使用 pickImage');
      final x = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (x == null) return const PickResult();

      final validated = await _validate(x);
      if (validated != null) {
        debugPrint('[PhotoService] 校验失败: $validated');
        return PickResult(error: validated);
      }
      final savedPath = await _copyToDocs(x.path);
      if (savedPath == null) {
        debugPrint('[PhotoService] 保存失败: ${x.path}');
        return const PickResult(error: '图片保存失败，请重试');
      }
      debugPrint('[PhotoService] 保存成功: $savedPath');
      return PickResult(
        entries: [PhotoEntry(path: savedPath, status: PhotoStatus.success)],
      );
    }

    debugPrint('[PhotoService] 调用 pickMultiImage, limit=$remaining');
    final picked = await _picker.pickMultiImage(
      imageQuality: 85,
      limit: remaining,
    );
    debugPrint('[PhotoService] pickMultiImage 返回 ${picked.length} 张图片');
    if (picked.isEmpty) return const PickResult();

    final entries = <PhotoEntry>[];
    String? error;

    for (final x in picked) {
      debugPrint('[PhotoService] 校验图片: ${x.path}');
      final validated = await _validate(x);
      if (validated != null) {
        debugPrint('[PhotoService] 校验失败: $validated');
        error = validated;
        continue;
      }
      final savedPath = await _copyToDocs(x.path);
      if (savedPath == null) {
        debugPrint('[PhotoService] 保存失败: ${x.path}');
        error = '部分图片保存失败，请重试';
        continue;
      }
      debugPrint('[PhotoService] 保存成功: $savedPath');
      entries.add(PhotoEntry(path: savedPath, status: PhotoStatus.success));
    }

    debugPrint('[PhotoService] 选图完成: ${entries.length} 张成功, error=$error');
    return PickResult(entries: entries, error: error);
  }

  /// 调用相机拍摄单张照片。
  Future<PickResult> pickFromCamera() async {
    final x = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    if (x == null) return const PickResult();

    final validated = await _validate(x);
    if (validated != null) return PickResult(error: validated);

    final savedPath = await _copyToDocs(x.path);
    if (savedPath == null) return const PickResult(error: '图片保存失败，请重试');

    return PickResult(
      entries: [PhotoEntry(path: savedPath, status: PhotoStatus.success)],
    );
  }

  /// 校验格式与大小，返回错误信息或 null
  Future<String?> _validate(XFile file) async {
    final ext = p.extension(file.path).toLowerCase();
    if (ext != '.jpg' && ext != '.jpeg' && ext != '.png') {
      return '仅支持 JPG / PNG 格式';
    }
    final size = await file.length();
    if (size > maxBytes) {
      return '单张照片不能超过 5MB';
    }
    return null;
  }

  /// 拷贝原图到应用文档目录下的 item_photos 子目录，返回新路径。
  Future<String?> _copyToDocs(String srcPath) async {
    try {
      final docs = await getApplicationDocumentsDirectory();
      final dir = Directory(p.join(docs.path, 'item_photos'));
      if (!dir.existsSync()) {
        await dir.create(recursive: true);
      }
      final ext = p.extension(srcPath).toLowerCase();
      final dest = p.join(dir.path, '${_uuid.v4()}$ext');
      await File(srcPath).copy(dest);
      return dest;
    } catch (_) {
      return null;
    }
  }

  /// 删除已被移除的照片文件（编辑模式下清理孤儿文件）。
  Future<void> deleteFile(String path) async {
    try {
      final f = File(path);
      if (await f.exists()) await f.delete();
    } catch (_) {}
  }
}
