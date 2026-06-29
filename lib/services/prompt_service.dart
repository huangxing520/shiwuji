import 'package:flutter/services.dart' show rootBundle;
import 'ai/ai_models.dart';

class PromptService {
  PromptService._();
  static final PromptService instance = PromptService._();

  static const String _defaultPromptAsset =
      'assets/prompts/item_recognition_prompt.txt';

  String? _cachedPrompt;

  Future<String> loadRecognitionPrompt() async {
    if (_cachedPrompt != null && _cachedPrompt!.isNotEmpty) {
      return _cachedPrompt!;
    }
    try {
      final content = await rootBundle.loadString(_defaultPromptAsset);
      final trimmed = content.trim();
      if (trimmed.isNotEmpty) {
        _cachedPrompt = trimmed;
        return trimmed;
      }
    } catch (_) {}
    return kAiVisionPrompt;
  }

  void clearCache() {
    _cachedPrompt = null;
  }
}
