import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../daos/settings_dao.dart';
import 'database_provider.dart';

part 'generated/profile_provider.g.dart';

/// 用户资料（昵称 + 头像 emoji）
@riverpod
class ProfileManager extends _$ProfileManager {
  @override
  Future<Map<String, String>> build() async {
    final dao = ref.watch(settingsDaoProvider);
    final all = await dao.getAllSettings();
    return {
      'nickname': all['nickname'] ?? '小橘',
      'avatar_emoji': all['avatar_emoji'] ?? '🧑',
    };
  }

  SettingsDao get _dao => ref.read(settingsDaoProvider);

  Future<void> updateNickname(String nickname) async {
    await _dao.setValue('nickname', nickname);
    ref.invalidateSelf();
  }

  Future<void> updateAvatarEmoji(String emoji) async {
    await _dao.setValue('avatar_emoji', emoji);
    ref.invalidateSelf();
  }
}

/// 个人中心数据统计
@riverpod
Future<Map<String, dynamic>> profileStats(Ref ref) async {
  final itemDao = ref.watch(itemDaoProvider);
  final roomDao = ref.watch(roomDaoProvider);
  final categoryDao = ref.watch(categoryDaoProvider);

  final itemCount = await itemDao.countAll();
  final totalValue = await itemDao.totalValue();
  final rooms = await roomDao.getAllRooms();
  final categories = await categoryDao.getAllCategories();

  return {
    'itemCount': itemCount,
    'totalValue': totalValue,
    'roomCount': rooms.length,
    'categoryCount': categories.length,
  };
}
