# قواعد ProGuard للتطبيق
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# FFmpeg
-keep class com.arthenica.ffmpegkit.** { *; }
-keep class com.arthenica.smartexception.** { *; }

# Dio
-keep class retrofit2.** { *; }
-keep class okhttp3.** { *; }

# PDF
-keep class com.itextpdf.** { *; }

# SharedPreferences
-keep class com.google.android.gms.** { *; }

# Gson
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn sun.misc.**
-keep class com.google.gson.** { *; }

# General
-keepattributes SourceFile,LineNumberTable
-keepattributes Exceptions,InnerClasses
-dontwarn org.conscrypt.**
-dontwarn org.bouncycastle.**
-dontwarn org.openjsse.**
