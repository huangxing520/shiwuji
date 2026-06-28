import 'dart:io';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'emoji_text.dart';
import '../models/enums/pending_card_type.dart';
import '../models/enums/item_tag_type.dart';

class PendingCard extends StatelessWidget {
  final String title;
  final String desc;
  final String count;
  final PendingCardType type;
  final VoidCallback? onTap;

  const PendingCard({
    super.key,
    required this.title,
    required this.desc,
    required this.count,
    required this.type,
    this.onTap,
  });

  Color _getIconBgColor() {
    switch (type) {
      case PendingCardType.expiring:
        return AppColors.danger.withValues(alpha: 0.15);
      case PendingCardType.returning:
        return AppColors.info.withValues(alpha: 0.15);
      case PendingCardType.restocking:
        return AppColors.warning.withValues(alpha: 0.15);
    }
  }

  Color _getIconColor() {
    switch (type) {
      case PendingCardType.expiring:
        return AppColors.danger;
      case PendingCardType.returning:
        return AppColors.info;
      case PendingCardType.restocking:
        return AppColors.warning;
    }
  }

  Color _getCountColor() {
    switch (type) {
      case PendingCardType.expiring:
        return AppColors.danger;
      case PendingCardType.returning:
        return AppColors.info;
      case PendingCardType.restocking:
        return AppColors.warning;
    }
  }

  IconData _getIcon() {
    switch (type) {
      case PendingCardType.expiring:
        return Icons.timer;
      case PendingCardType.returning:
        return Icons.arrow_back;
      case PendingCardType.restocking:
        return Icons.shopping_cart;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.textPrimary.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _getIconBgColor(),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(_getIcon(), color: _getIconColor(), size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    desc,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textHint,
                      overflow: TextOverflow.ellipsis,
                    ),
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            Text(
              count,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: _getCountColor(),
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: AppColors.textHint, size: 16),
          ],
        ),
      ),
    );
  }
}

class RecentItemCard extends StatelessWidget {
  final String emoji;
  final String? photoPath;
  final String name;
  final String meta;
  final ItemTagType tagType;
  final VoidCallback? onTap;

  const RecentItemCard({
    super.key,
    required this.emoji,
    required this.name,
    required this.meta,
    required this.tagType,
    this.photoPath,
    this.onTap,
  });

  String _getTagText() {
    switch (tagType) {
      case ItemTagType.newItem:
        return '新增';
      case ItemTagType.urgent:
        return '即将到期';
      case ItemTagType.normal:
        return '在保';
      case ItemTagType.expired:
        return '已过保';
    }
  }

  Color _getTagBgColor() {
    switch (tagType) {
      case ItemTagType.newItem:
        return AppColors.tagNewBg;
      case ItemTagType.urgent:
        return AppColors.danger.withValues(alpha: 0.15);
      case ItemTagType.normal:
        return AppColors.info.withValues(alpha: 0.15);
      case ItemTagType.expired:
        return AppColors.warning.withValues(alpha: 0.15);
    }
  }

  Color _getTagColor() {
    switch (tagType) {
      case ItemTagType.newItem:
        return AppColors.tagNew;
      case ItemTagType.urgent:
        return AppColors.danger;
      case ItemTagType.normal:
        return AppColors.info;
      case ItemTagType.expired:
        return AppColors.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColors.textPrimary.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.accentLightBg,
                borderRadius: BorderRadius.circular(14),
              ),
              clipBehavior: Clip.antiAlias,
              child: (photoPath != null && photoPath!.isNotEmpty)
                  ? Image.file(
                      File(photoPath!),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Center(
                        child: Text(
                          emoji,
                          style: const TextStyle(fontSize: 22),
                        ),
                      ),
                    )
                  : Center(child: EmojiText(emoji: emoji, fontSize: 22)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    meta,
                    style: TextStyle(fontSize: 12, color: AppColors.textHint),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: _getTagBgColor(),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _getTagText(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _getTagColor(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
