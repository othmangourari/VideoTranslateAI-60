# تعليمات بناء APK - VideoTranslate AI

## الطريقة السريعة (15 دقيقة)

### المتطلبات المسبقة

1. **Java JDK 17** - https://www.oracle.com/java/technologies/downloads/
2. **Android Studio** - https://developer.android.com/studio
3. **Flutter SDK** - https://flutter.dev/docs/get-started/install/windows

---

## الخطوات التفصيلية

### الخطوة 1: تثبيت Flutter

#### على Windows:
```powershell
# 1. حمّل Flutter من: https://flutter.dev/docs/get-started/install/windows
# 2. فك الضغط في: C:\flutter
# 3. أضف إلى PATH: C:\flutter\bin

# تحقق من التثبيت
flutter doctor
```

#### على macOS:
```bash
# باستخدام Homebrew
brew install flutter

# أو تنزيل يدوي
curl -O https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_3.24.0-stable.zip
unzip flutter_macos_*.zip
export PATH="$PWD/flutter/bin:$PATH"
```

#### على Linux:
```bash
sudo snap install flutter --classic
flutter sdk-path
```

### الخطوة 2: تثبيت Android SDK

```bash
# من خلال Android Studio (موصى به)
# أو عبر command line tools فقط:
# https://developer.android.com/studio#command-tools

# قبول الرخص
flutter doctor --android-licenses
```

### الخطوة 3: تنزيل الخطوط

من **Google Fonts**، نزّل وضع في مجلد `assets/fonts/`:

```
Cairo-Regular.ttf
Cairo-Medium.ttf
Cairo-SemiBold.ttf
Cairo-Bold.ttf
Inter-Regular.ttf
Inter-Medium.ttf
Inter-SemiBold.ttf
Inter-Bold.ttf
```

روابط التنزيل:
- Cairo: https://fonts.google.com/specimen/Cairo
- Inter: https://fonts.google.com/specimen/Inter

### الخطوة 4: تثبيت المكتبات

```bash
cd video-translate-ai
flutter pub get
```

> قد تستغرق هذه الخطوة 5-10 دقائق لأن FFmpeg كبير الحجم

### الخطوة 5: بناء APK

```bash
# APK واحد (أكبر حجماً - يعمل على كل الأجهزة)
flutter build apk --release

# APKs منفصلة (أصغر حجماً)
flutter build apk --split-per-abi --release
```

### نتيجة البناء

ستجد الـ APK في:
```
video-translate-ai/build/app/outputs/flutter-apk/
├── app-release.apk              (APK واحد - ~80-120 MB)
├── app-armeabi-v7a-release.apk  (للأجهزة القديمة)
├── app-arm64-v8a-release.apk    (معظم الأجهزة الحديثة)
└── app-x86_64-release.apk       (المحاكيات)
```

**للهواتف الحديثة:** استخدم `app-arm64-v8a-release.apk`

---

## التثبيت على الهاتف

### الطريقة 1: USB
```bash
# تفعيل "USB Debugging" في خيارات المطور
adb install build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
```

### الطريقة 2: نسخ مباشر
1. انسخ ملف APK إلى هاتفك
2. اسمح بتثبيت التطبيقات من مصادر غير معروفة
3. افتح الملف وثبّته

---

## حل المشاكل الشائعة

### مشكلة: Flutter not found
```bash
# أضف Flutter إلى PATH
export PATH="$HOME/flutter/bin:$PATH"
echo 'export PATH="$HOME/flutter/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

### مشكلة: Gradle فشل
```bash
flutter clean
cd android && ./gradlew clean && cd ..
flutter pub get
flutter build apk --release
```

### مشكلة: Java version
```bash
# تحقق من إصدار Java
java -version

# إذا كان < 17، ثبّت JDK 17
# https://www.oracle.com/java/technologies/downloads/
```

### مشكلة: FFmpeg build error
```bash
# غيّر في pubspec.yaml:
# من: ffmpeg_kit_flutter: ^6.0.3
# إلى:
ffmpeg_kit_flutter_min: ^6.0.3
```

### مشكلة: خطأ في الخطوط
```bash
# تأكد من وجود جميع ملفات الخطوط في assets/fonts/
ls assets/fonts/
```

---

## ملاحظة مهمة حول APK

بسبب مكتبة `ffmpeg_kit_flutter`، حجم APK قد يكون **80-120 MB**.

لتصغير الحجم:
```bash
# استخدام النسخة المخففة من FFmpeg
flutter build apk --split-per-abi --release --target-platform android-arm64
```
