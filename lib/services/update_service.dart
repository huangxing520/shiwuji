import 'package:dio/dio.dart';
import 'package:shi_wu_ji/services/http_service.dart';

/// 版本信息（从 GitHub Release 解析）
class UpdateInfo {
  /// 最新版本号（已去除 'v' 前缀），例如 '1.1.0'
  final String latestVersion;

  /// 原始 tag，例如 'v1.1.0'
  final String tag;

  /// Release 标题
  final String name;

  /// 更新日志（Release body，markdown 原文）
  final String releaseNotes;

  /// Release 页面 URL（浏览器可打开）
  final String htmlUrl;

  /// APK 下载地址（若 assets 中存在则取第一个 .apk，否则为空）
  final String downloadUrl;

  /// 是否强制更新（GitHub Release 无此字段，恒为 false）
  final bool forceUpdate;

  UpdateInfo({
    required this.latestVersion,
    required this.tag,
    required this.name,
    required this.releaseNotes,
    required this.htmlUrl,
    required this.downloadUrl,
    this.forceUpdate = false,
  });

  @override
  String toString() =>
      'UpdateInfo(latestVersion: $latestVersion, tag: $tag, htmlUrl: $htmlUrl)';
}

/// 检查更新结果
enum CheckResult { upToDate, newVersion, error }

class CheckUpdateOutcome {
  final CheckResult result;
  final UpdateInfo? info;
  final String? errorMessage;

  CheckUpdateOutcome({required this.result, this.info, this.errorMessage});
}

/// 更新服务
///
/// 通过 GitHub Releases API 获取最新版本信息：
/// `GET https://api.github.com/repos/huangxing520/shiwuji/releases/latest`
///
/// GitHub API 返回结构（节选）：
/// ```json
/// {
///   "tag_name": "v1.1.0",
///   "name": "v1.1.0 - 新版本",
///   "body": "## 更新内容\n1. 新增 XX\n2. 修复 XX",
///   "html_url": "https://github.com/huangxing520/shiwuji/releases/tag/v1.1.0",
///   "assets": [{"name": "app-release.apk", "browser_download_url": "..."}]
/// }
/// ```
class UpdateService {
  UpdateService._();
  static final UpdateService instance = UpdateService._();

  /// GitHub Releases API 地址（latest release）
  static const String githubApiUrl =
      'https://api.github.com/repos/huangxing520/shiwuji/releases/latest';

  /// GitHub Release 浏览器页面（fallback / "去更新"按钮跳转地址）
  static const String githubReleasesUrl =
      'https://github.com/huangxing520/shiwuji/releases';

  /// 检查更新
  ///
  /// [currentVersion] 当前 App 版本号，例如 '1.0.0' 或 '1.0.0+1'
  Future<CheckUpdateOutcome> check(String currentVersion) async {
    try {
      final response = await HttpService.instance.getRaw<Map<String, dynamic>>(
        githubApiUrl,
        options: Options(
          headers: {
            // GitHub API 强制要求 User-Agent
            'User-Agent': 'shi-wu-ji-app',
            'Accept': 'application/vnd.github+json',
          },
        ),
      );

      final data = response.data;
      if (data == null) {
        return  CheckUpdateOutcome(
          result: CheckResult.error,
          errorMessage: '服务器返回数据为空',
        );
      }

      final info = parseGitHubRelease(data);
      if (info.latestVersion.isEmpty) {
        return  CheckUpdateOutcome(
          result: CheckResult.error,
          errorMessage: '无法解析版本号',
        );
      }

      final hasNew = compareVersion(info.latestVersion, currentVersion) > 0;
      return CheckUpdateOutcome(
        result: hasNew ? CheckResult.newVersion : CheckResult.upToDate,
        info: info,
      );
    } on ApiException catch (e) {
      return CheckUpdateOutcome(
        result: CheckResult.error,
        errorMessage: e.message,
      );
    } on DioException catch (e) {
      return CheckUpdateOutcome(
        result: CheckResult.error,
        errorMessage: '网络请求失败：${e.message}',
      );
    } catch (e) {
      return CheckUpdateOutcome(
        result: CheckResult.error,
        errorMessage: '检查失败：$e',
      );
    }
  }

  // ─── 可测试的纯函数 ─────────────────────────

  /// 解析 GitHub Release JSON 为 [UpdateInfo]
  ///
  /// 容错处理：任何字段缺失都返回空字符串，不抛异常。
  static UpdateInfo parseGitHubRelease(Map<String, dynamic> json) {
    final tag = json['tag_name'] as String? ?? '';
    final name = json['name'] as String? ?? '';
    final body = json['body'] as String? ?? '';
    final htmlUrl = json['html_url'] as String? ?? '';

    // 从 assets 中查找第一个 .apk 下载地址
    String apkUrl = '';
    final assets = json['assets'];
    if (assets is List) {
      for (final a in assets) {
        if (a is Map<String, dynamic>) {
          final assetName = a['name'] as String? ?? '';
          if (assetName.toLowerCase().endsWith('.apk')) {
            apkUrl = a['browser_download_url'] as String? ?? '';
            break;
          }
        }
      }
    }

    return UpdateInfo(
      tag: tag,
      latestVersion: stripVersionPrefix(tag),
      name: name,
      releaseNotes: body,
      htmlUrl: htmlUrl,
      downloadUrl: apkUrl,
    );
  }

  /// 去掉版本号前的 'v' 或 'V' 前缀
  ///
  /// 'v1.0.0' → '1.0.0'，'1.0.0' → '1.0.0'
  static String stripVersionPrefix(String tag) {
    if (tag.isEmpty) return tag;
    if (tag.startsWith('v') || tag.startsWith('V')) {
      return tag.substring(1);
    }
    return tag;
  }

  /// 版本号比较
  ///
  /// 返回值：> 0 表示 [a] 更新；< 0 表示 [b] 更新；0 表示相同。
  /// 支持 '1.0.0'、'v1.0.0'、'1.0.0+1'、'1.0.0-beta' 等格式。
  /// 非数字段视为 0，长度不一致时短的补 0。
  static int compareVersion(String a, String b) {
    final partsA = parseVersion(a);
    final partsB = parseVersion(b);

    final maxLen = partsA.length > partsB.length
        ? partsA.length
        : partsB.length;
    for (var i = 0; i < maxLen; i++) {
      final va = i < partsA.length ? partsA[i] : 0;
      final vb = i < partsB.length ? partsB[i] : 0;
      if (va != vb) return va - vb;
    }
    return 0;
  }

  /// 解析版本号为数字列表
  ///
  /// 'v1.0.0+1-beta' → [1, 0, 0]
  static List<int> parseVersion(String v) {
    if (v.isEmpty) return [0];
    // 去掉 'v'/'V' 前缀
    var clean = v;
    if (clean.startsWith('v') || clean.startsWith('V')) {
      clean = clean.substring(1);
    }
    // 去掉 build 号 (+1) 和预发布标识 (-beta)
    clean = clean.split('+').first.split('-').first;
    return clean.split('.').map((e) => int.tryParse(e.trim()) ?? 0).toList();
  }
}
