import 'package:flutter_test/flutter_test.dart';
import 'package:shi_wu_ji/services/update_service.dart';

void main() {
  group('UpdateService.parseVersion', () {
    test('解析标准三段版本号', () {
      expect(UpdateService.parseVersion('1.2.3'), [1, 2, 3]);
    });

    test('解析带 v 前缀', () {
      expect(UpdateService.parseVersion('v1.2.3'), [1, 2, 3]);
      expect(UpdateService.parseVersion('V1.2.3'), [1, 2, 3]);
    });

    test('解析带 build 号', () {
      expect(UpdateService.parseVersion('1.2.3+1'), [1, 2, 3]);
      expect(UpdateService.parseVersion('v1.0.0+42'), [1, 0, 0]);
    });

    test('解析带预发布标识', () {
      expect(UpdateService.parseVersion('1.2.3-beta'), [1, 2, 3]);
      expect(UpdateService.parseVersion('v1.0.0-rc.1'), [1, 0, 0]);
    });

    test('同时带 build 号和预发布标识', () {
      expect(UpdateService.parseVersion('v1.2.3+4-beta'), [1, 2, 3]);
    });

    test('空字符串返回 [0]', () {
      expect(UpdateService.parseVersion(''), [0]);
    });

    test('非数字段视为 0', () {
      expect(UpdateService.parseVersion('1.x.3'), [1, 0, 3]);
    });

    test('两段版本号', () {
      expect(UpdateService.parseVersion('1.0'), [1, 0]);
    });
  });

  group('UpdateService.stripVersionPrefix', () {
    test('去除小写 v 前缀', () {
      expect(UpdateService.stripVersionPrefix('v1.0.0'), '1.0.0');
    });

    test('去除大写 V 前缀', () {
      expect(UpdateService.stripVersionPrefix('V1.0.0'), '1.0.0');
    });

    test('无前缀保持不变', () {
      expect(UpdateService.stripVersionPrefix('1.0.0'), '1.0.0');
    });

    test('空字符串保持不变', () {
      expect(UpdateService.stripVersionPrefix(''), '');
    });

    test('不处理非 v 开头', () {
      expect(UpdateService.stripVersionPrefix('beta1.0.0'), 'beta1.0.0');
    });
  });

  group('UpdateService.compareVersion', () {
    test('a 大于 b 返回正数', () {
      expect(UpdateService.compareVersion('1.1.0', '1.0.0') > 0, isTrue);
      expect(UpdateService.compareVersion('2.0.0', '1.9.9') > 0, isTrue);
      expect(UpdateService.compareVersion('1.0.1', '1.0.0') > 0, isTrue);
    });

    test('a 小于 b 返回负数', () {
      expect(UpdateService.compareVersion('1.0.0', '1.1.0') < 0, isTrue);
      expect(UpdateService.compareVersion('1.9.9', '2.0.0') < 0, isTrue);
    });

    test('版本相同返回 0', () {
      expect(UpdateService.compareVersion('1.0.0', '1.0.0'), 0);
      expect(UpdateService.compareVersion('v1.0.0', '1.0.0'), 0);
      expect(UpdateService.compareVersion('1.0.0+1', '1.0.0+2'), 0);
      expect(UpdateService.compareVersion('1.0.0-beta', '1.0.0'), 0);
    });

    test('长度不一致时短的补 0', () {
      // 1.0 == 1.0.0
      expect(UpdateService.compareVersion('1.0', '1.0.0'), 0);
      // 1.1 > 1.0.0
      expect(UpdateService.compareVersion('1.1', '1.0.0') > 0, isTrue);
      // 1.0.0.0 == 1.0.0
      expect(UpdateService.compareVersion('1.0.0.0', '1.0.0'), 0);
    });

    test('混合格式比较', () {
      expect(
        UpdateService.compareVersion('v2.0.0+1', '1.9.9-beta') > 0,
        isTrue,
      );
    });

    test('空字符串视为 0.0.0', () {
      expect(UpdateService.compareVersion('', '0.0.0'), 0);
      expect(UpdateService.compareVersion('1.0.0', '') > 0, isTrue);
    });
  });

  group('UpdateService.parseGitHubRelease', () {
    test('解析完整 GitHub Release JSON', () {
      final json = {
        'tag_name': 'v1.2.0',
        'name': 'v1.2.0 - 春节更新',
        'body': '## 新功能\n1. 新增收纳统计\n2. 修复若干 bug',
        'html_url':
            'https://github.com/huangxing520/shiwuji/releases/tag/v1.2.0',
        'assets': [
          {
            'name': 'app-arm64-v8a-release.apk',
            'browser_download_url':
                'https://github.com/huangxing520/shiwuji/releases/download/v1.2.0/app-arm64-v8a-release.apk',
          },
          {
            'name': 'app-armeabi-v7a-release.apk',
            'browser_download_url':
                'https://github.com/huangxing520/shiwuji/releases/download/v1.2.0/app-armeabi-v7a-release.apk',
          },
        ],
      };

      final info = UpdateService.parseGitHubRelease(json);

      expect(info.tag, 'v1.2.0');
      expect(info.latestVersion, '1.2.0');
      expect(info.name, 'v1.2.0 - 春节更新');
      expect(info.releaseNotes, contains('收纳统计'));
      expect(
        info.htmlUrl,
        'https://github.com/huangxing520/shiwuji/releases/tag/v1.2.0',
      );
      expect(info.downloadUrl, contains('arm64-v8a'));
    });

    test('tag_name 无 v 前缀也能正确解析', () {
      final json = {
        'tag_name': '1.0.0',
        'name': '',
        'body': '',
        'html_url': 'https://example.com',
      };
      final info = UpdateService.parseGitHubRelease(json);
      expect(info.tag, '1.0.0');
      expect(info.latestVersion, '1.0.0');
    });

    test('字段缺失时不抛异常，返回空字符串', () {
      final json = <String, dynamic>{};
      final info = UpdateService.parseGitHubRelease(json);
      expect(info.tag, '');
      expect(info.latestVersion, '');
      expect(info.name, '');
      expect(info.releaseNotes, '');
      expect(info.htmlUrl, '');
      expect(info.downloadUrl, '');
    });

    test('assets 为空列表时 downloadUrl 为空', () {
      final json = {'tag_name': 'v1.0.0', 'assets': <Map<String, dynamic>>[]};
      final info = UpdateService.parseGitHubRelease(json);
      expect(info.downloadUrl, '');
    });

    test('assets 中无 .apk 文件时 downloadUrl 为空', () {
      final json = {
        'tag_name': 'v1.0.0',
        'assets': [
          {'name': 'checksums.txt', 'browser_download_url': 'https://...txt'},
        ],
      };
      final info = UpdateService.parseGitHubRelease(json);
      expect(info.downloadUrl, '');
    });

    test('assets 中 .APK 大写后缀也能识别', () {
      final json = {
        'tag_name': 'v1.0.0',
        'assets': [
          {'name': 'APP.APK', 'browser_download_url': 'https://...apk'},
        ],
      };
      final info = UpdateService.parseGitHubRelease(json);
      expect(info.downloadUrl, 'https://...apk');
    });

    test('assets 字段类型异常时不抛异常', () {
      final json = {'tag_name': 'v1.0.0', 'assets': 'not-a-list'};
      final info = UpdateService.parseGitHubRelease(json);
      expect(info.downloadUrl, '');
    });
  });

  group('UpdateService.check - 网络异常场景', () {
    test('check 方法存在且返回 CheckUpdateOutcome', () async {
      // 不实际发请求，仅验证类型契约
      expect(
        UpdateService.githubApiUrl,
        'https://api.github.com/repos/huangxing520/shiwuji/releases/latest',
      );
      expect(
        UpdateService.githubReleasesUrl,
        'https://github.com/huangxing520/shiwuji/releases',
      );
    });
  });

  group('CheckUpdateOutcome', () {
    test('upToDate 结果构造', () {
      final outcome = CheckUpdateOutcome(result: CheckResult.upToDate);
      expect(outcome.result, CheckResult.upToDate);
      expect(outcome.info, isNull);
      expect(outcome.errorMessage, isNull);
    });

    test('newVersion 结果带 info', () {
      final info = UpdateInfo(
        latestVersion: '1.1.0',
        tag: 'v1.1.0',
        name: 'v1.1.0',
        releaseNotes: '修复 bug',
        htmlUrl: 'https://example.com',
        downloadUrl: '',
      );
      final outcome = CheckUpdateOutcome(
        result: CheckResult.newVersion,
        info: info,
      );
      expect(outcome.result, CheckResult.newVersion);
      expect(outcome.info?.latestVersion, '1.1.0');
    });

    test('error 结果带 errorMessage', () {
      final outcome = CheckUpdateOutcome(
        result: CheckResult.error,
        errorMessage: '网络失败',
      );
      expect(outcome.result, CheckResult.error);
      expect(outcome.errorMessage, '网络失败');
    });
  });

  group('UpdateInfo', () {
    test('forceUpdate 默认 false', () {
      final info = UpdateInfo(
        latestVersion: '1.0.0',
        tag: 'v1.0.0',
        name: '',
        releaseNotes: '',
        htmlUrl: '',
        downloadUrl: '',
      );
      expect(info.forceUpdate, isFalse);
    });

    test('toString 包含关键信息', () {
      final info = UpdateInfo(
        latestVersion: '1.2.0',
        tag: 'v1.2.0',
        name: '',
        releaseNotes: '',
        htmlUrl: 'https://example.com/release',
        downloadUrl: '',
      );
      final s = info.toString();
      expect(s, contains('1.2.0'));
      expect(s, contains('https://example.com/release'));
    });
  });
}
