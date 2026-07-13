import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../providers/language_provider.dart';

/// نافذة اختيار لغة المصدر والهدف
class LanguageSelectorBottomSheet extends StatefulWidget {
  const LanguageSelectorBottomSheet({super.key});

  @override
  State<LanguageSelectorBottomSheet> createState() =>
      _LanguageSelectorBottomSheetState();
}

class _LanguageSelectorBottomSheetState
    extends State<LanguageSelectorBottomSheet> {
  String _sourceLanguage = 'ar';
  String _targetLanguage = 'en';
  String _searchQuery = '';
  bool _isSelectingSource = true;
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, String>> get _filteredLanguages {
    if (_searchQuery.isEmpty) return AppConstants.supportedLanguages;
    final q = _searchQuery.toLowerCase();
    return AppConstants.supportedLanguages.where((lang) {
      return lang['name']!.toLowerCase().contains(q) ||
          lang['nameEn']!.toLowerCase().contains(q) ||
          lang['code']!.toLowerCase().contains(q);
    }).toList();
  }

  String _getLangName(String code) {
    final lang = AppConstants.supportedLanguages.firstWhere(
      (l) => l['code'] == code,
      orElse: () => {'name': code, 'flag': '🏳'},
    );
    return '${lang['flag']} ${lang['name']}';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.watch<LanguageProvider>().isArabic;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, scrollController) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // المقبض
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // العنوان
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                isArabic ? 'اختر اللغات' : 'Select Languages',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Cairo',
                ),
              ),
            ),
            const SizedBox(height: 16),

            // اختيار المصدر والهدف
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: _LangSelector(
                      label: isArabic ? 'لغة الفيديو' : 'Video Language',
                      value: _getLangName(_sourceLanguage),
                      isSelected: _isSelectingSource,
                      onTap: () => setState(() => _isSelectingSource = true),
                      color: colorScheme.primary,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Icon(Icons.arrow_forward_rounded, color: colorScheme.primary),
                  ),
                  Expanded(
                    child: _LangSelector(
                      label: isArabic ? 'لغة الترجمة' : 'Translate To',
                      value: _getLangName(_targetLanguage),
                      isSelected: !_isSelectingSource,
                      onTap: () => setState(() => _isSelectingSource = false),
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // شريط البحث
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText: isArabic ? 'بحث عن لغة...' : 'Search language...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // قائمة اللغات
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _filteredLanguages.length,
                itemBuilder: (context, index) {
                  final lang = _filteredLanguages[index];
                  final code = lang['code']!;
                  final isSelected = _isSelectingSource
                      ? code == _sourceLanguage
                      : code == _targetLanguage;

                  return InkWell(
                    onTap: () {
                      setState(() {
                        if (_isSelectingSource) {
                          _sourceLanguage = code;
                          _isSelectingSource = false;
                        } else {
                          _targetLanguage = code;
                        }
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? colorScheme.primary.withOpacity(0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: isSelected
                            ? Border.all(
                                color: colorScheme.primary.withOpacity(0.3))
                            : null,
                      ),
                      child: Row(
                        children: [
                          Text(
                            lang['flag']!,
                            style: const TextStyle(fontSize: 22),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  lang['name']!,
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.normal,
                                    fontSize: 14,
                                    color: isSelected ? colorScheme.primary : null,
                                  ),
                                ),
                                Text(
                                  lang['nameEn']!,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[600],
                                    fontFamily: 'Inter',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            lang['code']!.toUpperCase(),
                            style: TextStyle(
                              fontSize: 11,
                              color: isSelected ? colorScheme.primary : Colors.grey[500],
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (isSelected) ...[
                            const SizedBox(width: 8),
                            Icon(Icons.check_rounded,
                                color: colorScheme.primary, size: 18),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // زر التأكيد
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, {
                    'source': _sourceLanguage,
                    'target': _targetLanguage,
                  });
                },
                child: Text(
                  isArabic
                      ? 'بدء المعالجة'
                      : 'Start Processing',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LangSelector extends StatelessWidget {
  final String label;
  final String value;
  final bool isSelected;
  final VoidCallback onTap;
  final Color color;

  const _LangSelector({
    required this.label,
    required this.value,
    required this.isSelected,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.grey.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color.withOpacity(0.4) : Colors.grey.withOpacity(0.2),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isSelected ? color : Colors.grey[600],
                fontFamily: 'Cairo',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isSelected ? color : null,
                fontFamily: 'Cairo',
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
