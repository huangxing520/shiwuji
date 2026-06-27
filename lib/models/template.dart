import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/template.freezed.dart';
part 'generated/template.g.dart';

@freezed
abstract class TemplateField with _$TemplateField {
  const factory TemplateField({
    required String label,
    required String placeholder,
    required String id,
    @Default(false) bool isDate,
  }) = _TemplateField;

  factory TemplateField.fromJson(Map<String, dynamic> json) =>
      _$TemplateFieldFromJson(json);
}

@freezed
abstract class TemplateData with _$TemplateData {
  const factory TemplateData({
    required String name,
    required List<TemplateField> fields,
  }) = _TemplateData;

  factory TemplateData.fromJson(Map<String, dynamic> json) =>
      _$TemplateDataFromJson(json);
}

/// 模板字段映射
const Map<String, TemplateData?> templateFieldsMap = {
  'none': null,
  'digital': TemplateData(
    name: '数码专属属性',
    fields: [
      TemplateField(label: '型号', placeholder: '例如：A2696', id: 'tplModel'),
      TemplateField(label: '序列号/IMEI', placeholder: '设备唯一标识', id: 'tplSerial'),
      TemplateField(label: '存储容量', placeholder: '例如：256GB', id: 'tplStorage'),
      TemplateField(label: '购买渠道', placeholder: '例如：官网/授权店', id: 'tplChannel'),
    ],
  ),
  'skincare': TemplateData(
    name: '护肤专属属性',
    fields: [
      TemplateField(
        label: '色号/规格',
        placeholder: '例如：#23 Ivory',
        id: 'tplShade',
      ),
      TemplateField(label: '生产批号', placeholder: '瓶身标注的批号', id: 'tplBatch'),
      TemplateField(
        label: '开盖日期',
        placeholder: '首次开封使用日期',
        id: 'tplOpenDate',
        isDate: true,
      ),
      TemplateField(label: '开封保质期', placeholder: '例如：12M', id: 'tplPAO'),
    ],
  ),
  'clothing': TemplateData(
    name: '服饰专属属性',
    fields: [
      TemplateField(label: '尺码', placeholder: '例如：M / 170/92A', id: 'tplSize'),
      TemplateField(label: '材质', placeholder: '例如：100%棉', id: 'tplMaterial'),
      TemplateField(label: '颜色', placeholder: '例如：藏青色', id: 'tplColor'),
      TemplateField(label: '季节', placeholder: '例如：春夏', id: 'tplSeason'),
    ],
  ),
  'food': TemplateData(
    name: '食品专属属性',
    fields: [
      TemplateField(label: '净含量', placeholder: '例如：500g', id: 'tplWeight'),
      TemplateField(
        label: '生产日期',
        placeholder: '',
        id: 'tplProdDate',
        isDate: true,
      ),
      TemplateField(label: '保质期', placeholder: '例如：12个月', id: 'tplShelfLife'),
      TemplateField(label: '存储条件', placeholder: '例如：阴凉干燥处', id: 'tplStorage2'),
    ],
  ),
  'books': TemplateData(
    name: '书籍专属属性',
    fields: [
      TemplateField(label: '作者', placeholder: '例如：原研哉', id: 'tplAuthor'),
      TemplateField(
        label: '出版社',
        placeholder: '例如：山东人民出版社',
        id: 'tplPublisher',
      ),
      TemplateField(label: 'ISBN', placeholder: '国际标准书号', id: 'tplISBN'),
      TemplateField(label: '版本', placeholder: '例如：第一版', id: 'tplEdition'),
    ],
  ),
  'appliance': TemplateData(
    name: '家电专属属性',
    fields: [
      TemplateField(
        label: '品牌型号',
        placeholder: '例如：美的 MK-HP1760',
        id: 'tplApplianceModel',
      ),
      TemplateField(
        label: '能效等级',
        placeholder: '例如：一级能效',
        id: 'tplEnergyLevel',
      ),
      TemplateField(
        label: '购买渠道',
        placeholder: '例如：京东/门店',
        id: 'tplApplianceChannel',
      ),
      TemplateField(
        label: '安装日期',
        placeholder: '上门安装日期',
        id: 'tplInstallDate',
        isDate: true,
      ),
    ],
  ),
  'kitchen': TemplateData(
    name: '厨房专属属性',
    fields: [
      TemplateField(
        label: '容量/规格',
        placeholder: '例如：26cm / 5L',
        id: 'tplCapacity',
      ),
      TemplateField(
        label: '材质',
        placeholder: '例如：316不锈钢',
        id: 'tplKitchenMaterial',
      ),
      TemplateField(
        label: '生产日期',
        placeholder: '',
        id: 'tplKitchenProdDate',
        isDate: true,
      ),
      TemplateField(
        label: '存储条件',
        placeholder: '例如：干燥通风处',
        id: 'tplKitchenStorage',
      ),
    ],
  ),
  'storage': TemplateData(
    name: '收纳专属属性',
    fields: [
      TemplateField(
        label: '容量',
        placeholder: '例如：50L / 可放20件',
        id: 'tplStorageCapacity',
      ),
      TemplateField(
        label: '材质',
        placeholder: '例如：PP塑料/无纺布',
        id: 'tplStorageMaterial',
      ),
      TemplateField(
        label: '用途',
        placeholder: '例如：换季衣物收纳',
        id: 'tplStorageUsage',
      ),
      TemplateField(
        label: '收纳位置',
        placeholder: '例如：衣柜顶层',
        id: 'tplStorageLocation',
      ),
    ],
  ),
  'medicine': TemplateData(
    name: '医药保健专属属性',
    fields: [
      TemplateField(
        label: '剂型规格',
        placeholder: '例如：片剂 0.25g×24片',
        id: 'tplMedForm',
      ),
      TemplateField(label: '生产批号', placeholder: '包装上的批号', id: 'tplMedBatch'),
      TemplateField(
        label: '有效期',
        placeholder: '失效日期',
        id: 'tplMedExpiry',
        isDate: true,
      ),
      TemplateField(
        label: '存储条件',
        placeholder: '例如：避光冷藏 2-8℃',
        id: 'tplMedStorage',
      ),
      TemplateField(
        label: '适应症',
        placeholder: '例如：缓解头痛发热',
        id: 'tplMedIndication',
      ),
    ],
  ),
  'baby': TemplateData(
    name: '母婴专属属性',
    fields: [
      TemplateField(label: '适用月龄', placeholder: '例如：6-12个月', id: 'tplBabyAge'),
      TemplateField(
        label: '材质安全等级',
        placeholder: '例如：食品级硅胶 / A类',
        id: 'tplBabyMaterial',
      ),
      TemplateField(
        label: '生产日期',
        placeholder: '',
        id: 'tplBabyProdDate',
        isDate: true,
      ),
      TemplateField(label: '保质期', placeholder: '例如：3年', id: 'tplBabyShelfLife'),
    ],
  ),
  'sports': TemplateData(
    name: '运动户外专属属性',
    fields: [
      TemplateField(
        label: '尺码',
        placeholder: '例如：42码 / L',
        id: 'tplSportsSize',
      ),
      TemplateField(
        label: '材质',
        placeholder: '例如：速干聚酯纤维',
        id: 'tplSportsMaterial',
      ),
      TemplateField(
        label: '适用场景',
        placeholder: '例如：跑步 / 露营',
        id: 'tplSportsScene',
      ),
      TemplateField(
        label: '保养方式',
        placeholder: '例如：冷水手洗阴干',
        id: 'tplSportsCare',
      ),
    ],
  ),
  'stationery': TemplateData(
    name: '文具专属属性',
    fields: [
      TemplateField(
        label: '规格型号',
        placeholder: '例如：0.5mm 黑色',
        id: 'tplStatModel',
      ),
      TemplateField(
        label: '材质',
        placeholder: '例如：ABS树脂',
        id: 'tplStatMaterial',
      ),
      TemplateField(
        label: '墨水/笔芯规格',
        placeholder: '例如：中性墨 / G2替芯',
        id: 'tplStatRefill',
      ),
    ],
  ),
  'tools': TemplateData(
    name: '工具专属属性',
    fields: [
      TemplateField(
        label: '规格',
        placeholder: '例如：PH2 十字 / 6mm',
        id: 'tplToolSpec',
      ),
      TemplateField(
        label: '材质',
        placeholder: '例如：S2合金钢',
        id: 'tplToolMaterial',
      ),
      TemplateField(label: '用途', placeholder: '例如：家具组装', id: 'tplToolUsage'),
      TemplateField(label: '保修期', placeholder: '例如：1年', id: 'tplToolWarranty'),
    ],
  ),
  'pet': TemplateData(
    name: '宠物用品专属属性',
    fields: [
      TemplateField(
        label: '适用宠物',
        placeholder: '例如：猫 / 中型犬',
        id: 'tplPetTarget',
      ),
      TemplateField(
        label: '规格',
        placeholder: '例如：5kg / 40cm',
        id: 'tplPetSpec',
      ),
      TemplateField(
        label: '保质期（食品类）',
        placeholder: '例如：12个月',
        id: 'tplPetShelfLife',
      ),
      TemplateField(
        label: '材质',
        placeholder: '例如：304不锈钢',
        id: 'tplPetMaterial',
      ),
    ],
  ),
  'membership': TemplateData(
    name: '会员订阅专属属性',
    fields: [
      TemplateField(
        label: '平台/服务',
        placeholder: '例如：腾讯视频 / iCloud',
        id: 'tplMemPlatform',
      ),
      TemplateField(
        label: '会员等级',
        placeholder: '例如：年费VIP / 黄金会员',
        id: 'tplMemLevel',
      ),
      TemplateField(
        label: '有效期',
        placeholder: '到期日期',
        id: 'tplMemExpiry',
        isDate: true,
      ),
      TemplateField(
        label: '自动续费',
        placeholder: '例如：已开通 / 已关闭',
        id: 'tplMemAutoRenew',
      ),
      TemplateField(
        label: '关联账号',
        placeholder: '绑定的账号邮箱/手机号',
        id: 'tplMemAccount',
      ),
    ],
  ),
  'sim_card': TemplateData(
    name: '网卡流量专属属性',
    fields: [
      TemplateField(
        label: '运营商',
        placeholder: '例如：中国移动 / 中国电信',
        id: 'tplSimCarrier',
      ),
      TemplateField(
        label: '套餐内容',
        placeholder: '例如：100G流量+500分钟',
        id: 'tplSimPlan',
      ),
      TemplateField(
        label: '卡号',
        placeholder: 'ICCID / 手机号',
        id: 'tplSimNumber',
      ),
      TemplateField(
        label: '激活日期',
        placeholder: '',
        id: 'tplSimActivate',
        isDate: true,
      ),
      TemplateField(
        label: '有效期',
        placeholder: '到期日期',
        id: 'tplSimExpiry',
        isDate: true,
      ),
    ],
  ),
  'license': TemplateData(
    name: '数字许可证专属属性',
    fields: [
      TemplateField(
        label: '软件名称',
        placeholder: '例如：Office 365 / Photoshop',
        id: 'tplLicSoftware',
      ),
      TemplateField(
        label: '授权类型',
        placeholder: '例如：永久授权 / 订阅制',
        id: 'tplLicType',
      ),
      TemplateField(label: '激活码', placeholder: '产品密钥 / 序列号', id: 'tplLicKey'),
      TemplateField(
        label: '设备数限制',
        placeholder: '例如：1台 / 5台',
        id: 'tplLicDeviceLimit',
      ),
      TemplateField(
        label: '有效期',
        placeholder: '到期日期',
        id: 'tplLicExpiry',
        isDate: true,
      ),
    ],
  ),
  'gift_card': TemplateData(
    name: '礼品卡充值卡专属属性',
    fields: [
      TemplateField(
        label: '平台/卡面值',
        placeholder: '例如：京东E卡 500元',
        id: 'tplGiftPlatform',
      ),
      TemplateField(label: '卡号', placeholder: '卡面印刷的卡号', id: 'tplGiftNumber'),
      TemplateField(label: '密码', placeholder: '刮刮区密码', id: 'tplGiftPassword'),
      TemplateField(
        label: '有效期',
        placeholder: '到期日期',
        id: 'tplGiftExpiry',
        isDate: true,
      ),
      TemplateField(
        label: '使用状态',
        placeholder: '例如：未使用 / 部分使用 / 已用完',
        id: 'tplGiftStatus',
      ),
    ],
  ),
};

/// 模板卡片数据
class TemplateCard {
  final String key;
  final String emoji;
  final String name;

  const TemplateCard({
    required this.key,
    required this.emoji,
    required this.name,
  });

  static const List<TemplateCard> cards = [
    TemplateCard(key: 'none', emoji: '📝', name: '通用'),
    TemplateCard(key: 'digital', emoji: '📱', name: '数码'),
    TemplateCard(key: 'appliance', emoji: '🔌', name: '家电'),
    TemplateCard(key: 'skincare', emoji: '💄', name: '护肤'),
    TemplateCard(key: 'kitchen', emoji: '🍳', name: '厨房'),
    TemplateCard(key: 'clothing', emoji: '👔', name: '服饰'),
    TemplateCard(key: 'books', emoji: '📚', name: '书籍'),
    TemplateCard(key: 'storage', emoji: '📦', name: '收纳'),
    TemplateCard(key: 'food', emoji: '🍜', name: '食品'),
    TemplateCard(key: 'medicine', emoji: '💊', name: '医药保健'),
    TemplateCard(key: 'baby', emoji: '🍼', name: '母婴'),
    TemplateCard(key: 'sports', emoji: '⚽', name: '运动户外'),
    TemplateCard(key: 'stationery', emoji: '✏️', name: '文具'),
    TemplateCard(key: 'tools', emoji: '🔧', name: '工具'),
    TemplateCard(key: 'pet', emoji: '🐾', name: '宠物用品'),
    TemplateCard(key: 'membership', emoji: '💳', name: '会员订阅'),
    TemplateCard(key: 'sim_card', emoji: '📶', name: '网卡流量'),
    TemplateCard(key: 'license', emoji: '🔐', name: '数字许可证'),
    TemplateCard(key: 'gift_card', emoji: '🎁', name: '礼品卡'),
  ];
}

/// 来源选项
const List<String> sourceOptions = ['线下购买', '亲友赠送', '二手收购', '闲置已有', '其他'];
