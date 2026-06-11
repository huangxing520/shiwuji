import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shi_wu_ji/constants/app_colors.dart';
import 'package:shi_wu_ji/constants/app_text_styles.dart';
import 'package:shi_wu_ji/constants/app_dimensions.dart';
import 'package:shi_wu_ji/widgets/base_page.dart';
import 'package:shi_wu_ji/widgets/custom_app_bar.dart';
import 'package:shi_wu_ji/widgets/card_container.dart';
import 'package:shi_wu_ji/widgets/countdown_card.dart';
import 'package:shi_wu_ji/widgets/info_cell.dart';
import 'package:shi_wu_ji/models/item.dart';
import 'package:shi_wu_ji/providers/item_providers.dart';

class ItemDetailPage extends ConsumerWidget {
  final String itemId;

  const ItemDetailPage({super.key, required this.itemId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final item = ref.watch(itemByIdProvider(itemId));

    if (item == null) {
      return BasePage(
        appBar: const CustomAppBar(title: '物品详情'),
        child: const Center(child: Text('未找到物品')),
      );
    }

    final warrantyDays = item.daysUntilWarrantyExpiry;
    final warrantyText = item.isWarrantyExpired
        ? '已过期'
        : '$warrantyDays';
    final warrantyDateText = item.isWarrantyExpired ? '天前' : '剩余天数';

    return BasePage(
      appBar: CustomAppBar(title: item.name),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppDimensions.spacingLarge),
          _buildImageGallery(),
          const SizedBox(height: AppDimensions.spacingExtraLarge),
          _buildItemHeader(item),
          const SizedBox(height: AppDimensions.spacingExtraLarge),
          _buildCountdownSection(item, warrantyText, warrantyDateText),
          const SizedBox(height: AppDimensions.spacingExtraLarge),
          _buildInfoSection(item),
        ],
      ),
    );
  }

  Widget _buildImageGallery() {
    return CardContainer(
      padding: const EdgeInsets.all(AppDimensions.spacingMedium),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
        ),
        child: const Center(
          child: Icon(Icons.inventory, size: 64, color: AppColors.primary),
        ),
      ),
    );
  }

  Widget _buildItemHeader(Item item) {
    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.name, style: AppTextStyles.titleLarge),
          const SizedBox(height: AppDimensions.spacingSmall),
          Text('分类: ${item.category}', style: AppTextStyles.subtitleText),
          const SizedBox(height: AppDimensions.spacingSmall),
          Text('位置: ${item.location}', style: AppTextStyles.subtitleText),
          const SizedBox(height: AppDimensions.spacingMedium),
          Text('¥${item.price.toStringAsFixed(0)}', style: AppTextStyles.priceText),
        ],
      ),
    );
  }

  Widget _buildCountdownSection(Item item, String warrantyText, String warrantyDateText) {
    return Row(
      children: [
        CountdownCard(
          icon: '🛡️',
          label: '质保',
          value: warrantyText,
          date: warrantyDateText,
          isWarning: item.isWarrantyExpiringSoon || item.isWarrantyExpired,
        ),
        const SizedBox(width: AppDimensions.spacingMedium),
        CountdownCard(
          icon: '🔧',
          label: '维护',
          value: '30',
          date: '剩余天数',
          isWarning: true,
        ),
      ],
    );
  }

  Widget _buildInfoSection(Item item) {
    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('详情', style: AppTextStyles.titleSmall),
          const SizedBox(height: AppDimensions.spacingMedium),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: AppDimensions.spacingMedium,
            crossAxisSpacing: AppDimensions.spacingLarge,
            childAspectRatio: 2.5,
            children: [
              InfoCell(label: '分类', value: item.category),
              InfoCell(label: '位置', value: item.location),
              InfoCell(
                label: '购买日期',
                value: '${item.purchaseDate.year}-${item.purchaseDate.month.toString().padLeft(2, '0')}-${item.purchaseDate.day.toString().padLeft(2, '0')}',
              ),
              InfoCell(label: '价格', value: '¥${item.price.toStringAsFixed(0)}', isAccent: true),
            ],
          ),
        ],
      ),
    );
  }
}