# VideoTranslate AI 🎬🌍

تطبيق Flutter احترافي لترجمة الفيديوهات باستخدام الذكاء الاصطناعي.

---

## المميزات

- ✅ تصميم Material 3 حديث وجذاب
- ✅ دعم العربية والإنجليزية (RTL/LTR)
- ✅ الوضع الليلي والفاتح
- ✅ استخراج الصوت من الفيديو (FFmpeg)
- ✅ تحويل الكلام إلى نص (OpenAI Whisper)
- ✅ ترجمة أكثر من 100 لغة
- ✅ تصدير PDF, TXT
- ✅ مشاركة النصوص والملفات
- ✅ إدارة المشاريع كاملة
- ✅ بحث داخل المشاريع
- ✅ دعم فيديوهات حتى 5 ساعات

---

## متطلبات التشغيل

| المتطلب | الإصدار |
|---------|---------|
| Flutter | >= 3.10.0 |
| Dart | >= 3.0.0 |
| Android SDK | minSdk 21 (Android 5.0) |
| Java | 17 |

---

## 🚀 خطوات تشغيل المشروع

### 1. تثبيت Flutter

```bash
# تنزيل Flutter SDK
# من: https://flutter.dev/docs/get-started/install

# التحقق من التثبيت
flutter doctor
```

### 2. تنزيل الخطوط

قم بتنزيل الخطوط من Google Fonts ووضعها في `assets/fonts/`:

**Cairo:** https://fonts.google.com/specimen/Cairo
- Cairo-Regular.ttf
- Cairo-Medium.ttf
- Cairo-SemiBold.ttf
- Cairo-Bold.ttf

**Inter:** https://fonts.google.com/specimen/Inter
- Inter-Regular.ttf
- Inter-Medium.ttf
- Inter-SemiBold.ttf
- Inter-Bold.ttf

### 3. تثبيت المكتبات

```bash
flutter pub get
```

### 4. تشغيل التطبيق

```bash
# على Android
flutter run

# بناء APK
flutter build apk --release

# بناء APK للتوزيع المنقسم (أصغر حجماً)
flutter build apk --split-per-abi --release
```

ستجد الـ APK في:
```
build/app/outputs/flutter-apk/app-release.apk
```

---

## 🔑 إعداد API Keys

### OpenAI Whisper (تحويل الكلام إلى نص)

1. اذهب إلى https://platform.openai.com/api-keys
2. أنشئ مفتاح API جديد
3. افتح التطبيق → الإعدادات → مفاتيح API
4. أدخل مفتاح OpenAI

### DeepL (ترجمة متميزة - اختياري)

1. اذهب إلى https://www.deepl.com/pro-api
2. سجّل للحصول على حساب مجاني
3. انسخ مفتاح API
4. أدخله في الإعدادات

> **ملاحظة:** بدون مفاتيح API، يعمل التطبيق في وضع المحاكاة مع ترجمة Google المجانية.

---

## هيكل الملفات

```
lib/
├── main.dart                    # نقطة الدخول
├── app.dart                     # ويدجت التطبيق الرئيسية
├── core/
│   ├── theme/
│   │   ├── app_colors.dart      # ألوان التطبيق
│   │   └── app_theme.dart       # ثيم Material 3
│   └── constants/
│       └── app_constants.dart   # الثوابت والإعدادات
├── l10n/
│   ├── app_ar.arb               # النصوص العربية
│   ├── app_en.arb               # النصوص الإنجليزية
│   └── app_localizations.dart   # فئة الترجمة
├── models/
│   └── project_model.dart       # نموذج بيانات المشروع
├── providers/
│   ├── theme_provider.dart      # مزود الثيم
│   ├── language_provider.dart   # مزود اللغة
│   └── projects_provider.dart   # مزود المشاريع
├── services/
│   ├── database_service.dart    # قاعدة بيانات SQLite
│   ├── video_service.dart       # معالجة الفيديو (FFmpeg)
│   ├── transcription_service.dart # تحويل الكلام (Whisper)
│   ├── translation_service.dart  # الترجمة (DeepL/Google)
│   └── export_service.dart      # تصدير PDF, TXT
├── router/
│   └── app_router.dart          # GoRouter - التنقل
└── screens/
    ├── main_shell/
    │   └── main_shell.dart      # الشيل مع Bottom Nav
    ├── home/
    │   └── home_screen.dart     # الشاشة الرئيسية
    ├── processing/
    │   └── processing_screen.dart # شاشة المعالجة
    ├── translation/
    │   └── translation_screen.dart # شاشة الترجمة
    ├── projects/
    │   └── projects_screen.dart  # إدارة المشاريع
    ├── settings/
    │   └── settings_screen.dart  # الإعدادات
    └── project_detail/
        └── project_detail_screen.dart # تفاصيل المشروع

android/
├── app/
│   ├── build.gradle             # إعدادات بناء Android
│   ├── proguard-rules.pro       # قواعد تصغير الكود
│   └── src/main/
│       ├── AndroidManifest.xml  # صلاحيات التطبيق
│       ├── kotlin/.../
│       │   └── MainActivity.kt  # النشاط الرئيسي
│       └── res/
│           ├── drawable/        # الخلفيات
│           ├── values/          # الألوان والأنماط
│           └── xml/             # إعدادات FileProvider
├── build.gradle                 # إعدادات المشروع
├── gradle.properties            # خصائص Gradle
└── settings.gradle              # إعدادات Gradle
```

---

## المكتبات المستخدمة

| المكتبة | الغرض |
|---------|---------|
| `provider` | إدارة الحالة |
| `go_router` | التنقل بين الشاشات |
| `sqflite` | قاعدة بيانات SQLite |
| `shared_preferences` | حفظ الإعدادات |
| `file_picker` | اختيار ملفات الفيديو |
| `image_picker` | تسجيل الفيديو بالكاميرا |
| `ffmpeg_kit_flutter` | استخراج الصوت |
| `dio` | طلبات HTTP للـ APIs |
| `pdf` | تصدير PDF |
| `share_plus` | مشاركة الملفات |
| `permission_handler` | إدارة الصلاحيات |
| `video_player` | تشغيل الفيديو |

---

## ملاحظات هامة

1. **ffmpeg_kit_flutter** قد يستغرق وقتاً في التنزيل أثناء `flutter pub get` لأنه يحتوي على مكتبات كبيرة.

2. في حال مواجهة مشكلة في `ffmpeg_kit_flutter`، يمكن استخدام:
   ```yaml
   ffmpeg_kit_flutter_min: ^6.0.3
   ```
   (نسخة أخف وزناً تدعم العمليات الأساسية)

3. لبناء APK رسمي للتوزيع، يجب إضافة **keystore** للتوقيع الرقمي.

---

## استكشاف الأخطاء

### خطأ: `Gradle build failed`
```bash
cd android && ./gradlew clean && cd ..
flutter clean && flutter pub get && flutter build apk
```

### خطأ: `SDK not found`
تأكد من إعداد متغيرات البيئة:
```bash
export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/platform-tools
```

### خطأ: `minSdkVersion`
تأكد من أن `minSdkVersion` في `android/app/build.gradle` هو **21** على الأقل.

---

## تواصل ودعم

للمشاكل التقنية والاستفسارات، يمكن فتح Issue في المستودع.
