import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shi_wu_ji/constants/app_colors.dart';
import 'package:shi_wu_ji/constants/app_dimensions.dart';
import 'package:shi_wu_ji/constants/app_input_decoration.dart';
import 'package:shi_wu_ji/constants/app_text_styles.dart';
import 'package:shi_wu_ji/models/item.dart';
import 'package:shi_wu_ji/providers/item_providers.dart';
import 'package:shi_wu_ji/widgets/base_page.dart';
import 'package:shi_wu_ji/widgets/custom_app_bar.dart';
import 'package:shi_wu_ji/widgets/toast_utils.dart';


class AddItemPage extends ConsumerStatefulWidget {
  const AddItemPage({super.key});

  @override
  ConsumerState<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends ConsumerState<AddItemPage> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();

  void _saveItem() {
    if (_nameController.text.isEmpty) {
      ToastUtils.show(context, '请输入物品名称');
      return;
    }
    if (_priceController.text.isEmpty) {
      ToastUtils.show(context, '请输入价格');
      return;
    }

    final item = Item.create(
      name: _nameController.text.trim(),
      price: double.tryParse(_priceController.text.trim()) ?? 0,
    );

    ref.read(itemsProvider.notifier).addItem(item);

    ToastUtils.show(context, '物品保存成功！');
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        context.go('/home');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      appBar: const CustomAppBar(title: '添加物品'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('物品名称', style: AppTextStyles.titleSmall),
          const SizedBox(height: AppDimensions.spacingSmall),
          TextField(
            controller: _nameController,
            decoration: AppInputDecoration.standard(hintText: '输入物品名称'),
          ),
          const SizedBox(height: AppDimensions.spacingExtraLarge),
          const Text('价格', style: AppTextStyles.titleSmall),
          const SizedBox(height: AppDimensions.spacingSmall),
          TextField(
            controller: _priceController,
            keyboardType: TextInputType.number,
            decoration: AppInputDecoration.standard(
              hintText: '输入价格',
              prefixText: '¥',
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: _saveItem,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.borderRadiusExtraLarge),
              ),
            ),
            child: const Text('保存物品', style: AppTextStyles.buttonText),
          ),
        ],
      ),
    );
  }
}