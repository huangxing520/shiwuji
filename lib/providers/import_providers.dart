import 'dart:ui';

import 'package:drift/drift.dart' hide Column;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../database/database.dart' as db;
import '../daos/import_history_dao.dart';
import '../models/platform_data.dart';
import '../models/mock_order.dart';
import '../models/history_record.dart';
import 'database_provider.dart';

part 'generated/import_providers.g.dart';

// ─── 平台配置（静态数据）──────────────────────────────

const _seedPlatforms = <PlatformData>[
  PlatformData(
    key: 'taobao',
    name: '淘宝',
    emoji: '🛒',
    iconText: '淘',
    connected: true,
    orderEstimate: 186,
    gradientColors: [Color(0xFFFF6B00), Color(0xFFFF9A44)],
    steps: [
      TutorialStep(title: '打开淘宝APP', desc: '进入「我的淘宝」→「我的订单」'),
      TutorialStep(title: '导出订单数据', desc: '点击「订单管理」→「导出」获取CSV文件'),
      TutorialStep(title: '上传CSV文件', desc: '将导出的CSV文件上传到拾物记'),
      TutorialStep(title: '自动匹配入库', desc: '系统将自动匹配并导入物品信息'),
    ],
  ),
  PlatformData(
    key: 'jd',
    name: '京东',
    emoji: '📦',
    iconText: '京',
    connected: true,
    orderEstimate: 94,
    gradientColors: [Color(0xFFE4393C), Color(0xFFFF6B6B)],
    steps: [
      TutorialStep(title: '打开京东APP', desc: '进入「我的」→「我的订单」'),
      TutorialStep(title: '申请订单导出', desc: '点击「查看全部订单」→「导出」'),
      TutorialStep(title: '上传文件', desc: '上传导出的Excel或CSV文件'),
      TutorialStep(title: '自动匹配入库', desc: '系统将自动匹配并导入物品信息'),
    ],
  ),
  PlatformData(
    key: 'pdd',
    name: '拼多多',
    emoji: '🏷️',
    iconText: '拼',
    connected: false,
    orderEstimate: 67,
    gradientColors: [Color(0xFFFF4444), Color(0xFFFF7777)],
    steps: [
      TutorialStep(title: '打开拼多多APP', desc: '进入「个人中心」→「我的订单」'),
      TutorialStep(title: '截图订单列表', desc: '逐页截图保存订单记录'),
      TutorialStep(title: 'OCR识别', desc: '上传截图，系统自动识别订单信息'),
      TutorialStep(title: '确认并入库', desc: '核对识别结果后一键导入'),
    ],
  ),
  PlatformData(
    key: 'douyin',
    name: '抖音商城',
    emoji: '🎵',
    iconText: '抖',
    connected: false,
    orderEstimate: 43,
    gradientColors: [Color(0xFF25F4EE), Color(0xFFFE2C55)],
    steps: [
      TutorialStep(title: '打开抖音APP', desc: '进入「我」→「我的订单」'),
      TutorialStep(title: '导出订单', desc: '点击「查看全部」→「导出订单」'),
      TutorialStep(title: '上传文件', desc: '上传导出的CSV文件'),
      TutorialStep(title: '自动匹配入库', desc: '系统将自动匹配并导入物品信息'),
    ],
  ),
  PlatformData(
    key: 'suning',
    name: '苏宁',
    emoji: '🔶',
    iconText: '苏',
    connected: false,
    orderEstimate: 28,
    gradientColors: [Color(0xFFFF9900), Color(0xFFFFBB33)],
    steps: [
      TutorialStep(title: '打开苏宁易购APP', desc: '进入「我的苏宁」→「我的订单」'),
      TutorialStep(title: '导出订单数据', desc: '选择时间范围后导出'),
      TutorialStep(title: '上传文件', desc: '上传导出的文件'),
      TutorialStep(title: '自动匹配入库', desc: '系统将自动匹配并导入物品信息'),
    ],
  ),
  PlatformData(
    key: 'vip',
    name: '唯品会',
    emoji: '👜',
    iconText: '唯',
    connected: false,
    orderEstimate: 19,
    gradientColors: [Color(0xFFE91E63), Color(0xFFFF5252)],
    steps: [
      TutorialStep(title: '打开唯品会APP', desc: '进入「个人中心」→「全部订单」'),
      TutorialStep(title: '截图订单', desc: '逐页截图保存订单记录'),
      TutorialStep(title: 'OCR识别', desc: '上传截图进行识别'),
      TutorialStep(title: '确认并入库', desc: '核对后一键导入'),
    ],
  ),
  PlatformData(
    key: 'kaola',
    name: '考拉',
    emoji: '🐨',
    iconText: '考',
    connected: false,
    orderEstimate: 15,
    gradientColors: [Color(0xFF4CAF50), Color(0xFF81C784)],
    steps: [
      TutorialStep(title: '打开考拉海购APP', desc: '进入「我的」→「全部订单」'),
      TutorialStep(title: '导出订单', desc: '选择导出时间范围'),
      TutorialStep(title: '上传文件', desc: '上传导出的文件'),
      TutorialStep(title: '自动匹配入库', desc: '系统将自动匹配并导入物品信息'),
    ],
  ),
];

@riverpod
List<PlatformData> platforms(Ref ref) => _seedPlatforms;

// ─── 模拟订单数据（导入模拟用）─────────────────────────

const _seedMockOrders = <MockOrder>[
  MockOrder(emoji: '🧹', name: '戴森V12吸尘器', price: '3990'),
  MockOrder(emoji: '🎧', name: 'AirPods Pro 2', price: '1899'),
  MockOrder(emoji: '💊', name: '兰蔻小黑瓶精华', price: '1080'),
  MockOrder(emoji: '📦', name: '宜家思库布收纳箱', price: '149'),
  MockOrder(emoji: '🎵', name: '索尼WH-1000XM5', price: '2499'),
  MockOrder(emoji: '🍚', name: '美的电饭煲', price: '399'),
  MockOrder(emoji: '✨', name: 'SK-II神仙水', price: '1590'),
  MockOrder(emoji: '👔', name: '优衣库轻薄羽绒服', price: '499'),
  MockOrder(emoji: '📱', name: 'iPhone 15手机壳', price: '89'),
  MockOrder(emoji: '🍳', name: '不粘煎锅26cm', price: '159'),
  MockOrder(emoji: '📖', name: '设计中的设计', price: '48'),
  MockOrder(emoji: '🧱', name: '乐高建筑系列', price: '599'),
  MockOrder(emoji: '🖥️', name: '戴尔U2723QE显示器', price: '3999'),
  MockOrder(emoji: '⌨️', name: 'HHKB Professional', price: '2499'),
  MockOrder(emoji: '🪑', name: '西昊M57人体工学椅', price: '1299'),
  MockOrder(emoji: '✨', name: '雅诗兰黛小棕瓶', price: '850'),
  MockOrder(emoji: '👟', name: 'New Balance 990v5', price: '1699'),
  MockOrder(emoji: '🎒', name: 'Anker通勤背包', price: '399'),
];

@riverpod
List<MockOrder> mockOrders(Ref ref) => _seedMockOrders;

// ─── 时间范围配置 ──────────────────────────────────────

const timeRangeOptions = [
  {'key': 'all', 'label': '全部历史订单'},
  {'key': '1m', 'label': '近1个月'},
  {'key': '3m', 'label': '近3个月'},
  {'key': '6m', 'label': '近6个月'},
  {'key': '1y', 'label': '近1年'},
  {'key': 'custom', 'label': '自定义时间'},
];

// ─── 导入历史（从数据库读取）──────────────────────────

@riverpod
Future<List<HistoryRecord>> importHistory(Ref ref) async {
  final dao = ref.watch(importHistoryDaoProvider);
  final rows = await dao.getAll();
  return rows
      .map((row) => HistoryRecord(
            emoji: row.emoji,
            title: row.title,
            meta: row.meta,
            count: row.count,
            iconBg: Color(row.iconBg),
          ))
      .toList();
}

// ─── 导入操作 ──────────────────────────────────────────

@riverpod
class ImportActions extends _$ImportActions {
  @override
  Future<void> build() async {}

  /// 记录一次导入到历史
  Future<void> recordImport({
    required String platformKey,
    required String emoji,
    required String title,
    required String meta,
    required int count,
    required Color iconBg,
  }) async {
    final dao = ref.read(importHistoryDaoProvider);
    await dao.insert(db.ImportHistoryCompanion.insert(
      platformKey: platformKey,
      emoji: emoji,
      title: title,
      meta: meta,
      count: count,
      iconBg: iconBg.toARGB32(),
    ));
    ref.invalidate(importHistoryProvider);
  }
}

// ─── 导入统计 ──────────────────────────────────────────

@riverpod
Future<Map<String, int>> importStats(Ref ref) async {
  final dao = ref.watch(importHistoryDaoProvider);
  final totalImports = await dao.totalCount();
  final totalItems = await dao.totalImportedItems();
  return {
    'totalImports': totalImports,
    'totalItems': totalItems,
  };
}
