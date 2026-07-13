import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/theme_provider.dart';
import '../../providers/language_provider.dart';
import '../../core/constants/app_constants.dart';
import '../../services/video_service.dart';

/// شاشة الإعدادات
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _audioQuality = 'medium';
  String _translationQuality = 'standard';
  final TextEditingController _openAiKeyController = TextEditingController();
  final TextEditingController _deeplKeyController = TextEditingController();
  bool _showOpenAiKey = false;
  bool _showDeeplKey = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _audioQuality = prefs.getString(AppConstants.audioQualityPref) ?? 'medium';
      _translationQuality = prefs.getString(AppConstants.translationQualityPref) ?? 'standard';
      _openAiKeyController.text = prefs.getString(AppConstants.openAiApiKeyPref) ?? '';
      _deeplKeyController.text = prefs.getString(AppConstants.deeplApiKeyPref) ?? '';
    });
  }

  Future<void> _saveSetting(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  Future<void> _clearTempFiles() async {
    await VideoService.instance.clearTempFiles();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          context.read<LanguageProvider>().isArabic
              ? 'تم حذف الملفات المؤقتة'
              : 'Temp files cleared',
          style: const TextStyle(fontFamily: 'Cairo'),
        ),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  void dispose() {
    _openAiKeyController.dispose();
    _deeplKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.watch<LanguageProvider>().isArabic;
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? 'الإعدادات' : 'Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // قسم المظهر
          _buildSectionHeader(isArabic ? 'المظهر والتخصيص' : 'Appearance', Icons.palette_rounded),
          _buildCard([
            // الوضع الليلي
            _SettingTile(
              title: isArabic ? 'الوضع الليلي' : 'Dark Mode',
              subtitle: isArabic ? 'تغيير مظهر التطبيق' : 'Toggle app appearance',
              icon: Icons.dark_mode_rounded,
              iconColor: AppColors.primary,
              trailing: Switch(
                value: themeProvider.isDark,
                onChanged: (_) => themeProvider.toggleTheme(),
              ),
            ),
            const Divider(height: 1),
            // اللغة
            _SettingTile(
              title: isArabic ? 'لغة التطبيق' : 'App Language',
              subtitle: isArabic ? 'عربي / إنجليزي' : 'Arabic / English',
              icon: Icons.language_rounded,
              iconColor: AppColors.secondary,
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isArabic ? 'عربي' : 'English',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
              onTap: () => context.read<LanguageProvider>().toggleLanguage(),
            ),
          ], isDark),

          const SizedBox(height: 16),

          // قسم الجودة
          _buildSectionHeader(isArabic ? 'جودة المعالجة' : 'Processing Quality', Icons.high_quality_rounded),
          _buildCard([
            // جودة الصوت
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.audio_file_rounded, color: AppColors.success, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        isArabic ? 'جودة استخراج الصوت' : 'Audio Extraction Quality',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Cairo',
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Row(
                    children: [
                      _QualityChip(
                        label: isArabic ? 'منخفض' : 'Low',
                        isSelected: _audioQuality == 'low',
                        onTap: () {
                          setState(() => _audioQuality = 'low');
                          _saveSetting(AppConstants.audioQualityPref, 'low');
                        },
                      ),
                      const SizedBox(width: 8),
                      _QualityChip(
                        label: isArabic ? 'متوسط' : 'Medium',
                        isSelected: _audioQuality == 'medium',
                        onTap: () {
                          setState(() => _audioQuality = 'medium');
                          _saveSetting(AppConstants.audioQualityPref, 'medium');
                        },
                      ),
                      const SizedBox(width: 8),
                      _QualityChip(
                        label: isArabic ? 'عالي' : 'High',
                        isSelected: _audioQuality == 'high',
                        onTap: () {
                          setState(() => _audioQuality = 'high');
                          _saveSetting(AppConstants.audioQualityPref, 'high');
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 1),
            // جودة الترجمة
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.translate_rounded, color: AppColors.primary, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        isArabic ? 'جودة الترجمة' : 'Translation Quality',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Cairo',
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Row(
                    children: [
                      _QualityChip(
                        label: isArabic ? 'قياسي' : 'Standard',
                        isSelected: _translationQuality == 'standard',
                        onTap: () {
                          setState(() => _translationQuality = 'standard');
                          _saveSetting(AppConstants.translationQualityPref, 'standard');
                        },
                      ),
                      const SizedBox(width: 8),
                      _QualityChip(
                        label: isArabic ? 'متميز' : 'Premium',
                        isSelected: _translationQuality == 'premium',
                        onTap: () {
                          setState(() => _translationQuality = 'premium');
                          _saveSetting(AppConstants.translationQualityPref, 'premium');
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ], isDark),

          const SizedBox(height: 16),

          // مفاتيح API
          _buildSectionHeader(isArabic ? 'مفاتيح API' : 'API Keys', Icons.key_rounded),
          _buildCard([
            _ApiKeyField(
              controller: _openAiKeyController,
              label: 'OpenAI API Key (Whisper)',
              hint: 'sk-...',
              showKey: _showOpenAiKey,
              prefIcon: Icons.mic_rounded,
              onToggleVisibility: () => setState(() => _showOpenAiKey = !_showOpenAiKey),
              onSave: () => _saveSetting(AppConstants.openAiApiKeyPref, _openAiKeyController.text),
            ),
            const Divider(height: 1),
            _ApiKeyField(
              controller: _deeplKeyController,
              label: 'DeepL API Key',
              hint: 'xxxxx-xxxx-...',
              showKey: _showDeeplKey,
              prefIcon: Icons.translate_rounded,
              onToggleVisibility: () => setState(() => _showDeeplKey = !_showDeeplKey),
              onSave: () => _saveSetting(AppConstants.deeplApiKeyPref, _deeplKeyController.text),
            ),
          ], isDark),

          const SizedBox(height: 16),

          // التخزين والبيانات
          _buildSectionHeader(isArabic ? 'التخزين والبيانات' : 'Storage & Data', Icons.storage_rounded),
          _buildCard([
            _SettingTile(
              title: isArabic ? 'حذف الملفات المؤقتة' : 'Clear Temp Files',
              subtitle: isArabic ? 'تحرير مساحة التخزين' : 'Free up storage space',
              icon: Icons.cleaning_services_rounded,
              iconColor: AppColors.warning,
              onTap: _clearTempFiles,
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
            ),
          ], isDark),

          const SizedBox(height: 16),

          // معلومات التطبيق
          _buildCard([
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.translate_rounded, color: Colors.white, size: 36),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'VideoTranslate AI',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${isArabic ? 'الإصدار' : 'Version'} ${AppConstants.appVersion}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontFamily: 'Cairo',
                    ),
                  ),
                ],
              ),
            ),
          ], isDark),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 0, 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 6),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.grey[600],
              fontFamily: 'Cairo',
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(List<Widget> children, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.08)),
      ),
      child: Column(children: children),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color iconColor;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingTile({
    required this.title,
    this.subtitle,
    required this.icon,
    required this.iconColor,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600, fontSize: 15)),
      subtitle: subtitle != null
          ? Text(subtitle!, style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Colors.grey[600]))
          : null,
      trailing: trailing,
    );
  }
}

class _QualityChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _QualityChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.primary,
            fontFamily: 'Cairo',
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _ApiKeyField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final bool showKey;
  final IconData prefIcon;
  final VoidCallback onToggleVisibility;
  final VoidCallback onSave;

  const _ApiKeyField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.showKey,
    required this.prefIcon,
    required this.onToggleVisibility,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(prefIcon, size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Cairo',
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            obscureText: !showKey,
            style: const TextStyle(fontFamily: 'Inter', fontSize: 13),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(fontFamily: 'Inter'),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(showKey ? Icons.visibility_off_rounded : Icons.visibility_rounded, size: 18),
                    onPressed: onToggleVisibility,
                  ),
                  IconButton(
                    icon: const Icon(Icons.save_rounded, size: 18, color: AppColors.success),
                    onPressed: onSave,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
