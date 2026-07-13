package com.videotranslate.ai

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.os.Bundle
import android.view.WindowManager

/**
 * النشاط الرئيسي للتطبيق
 * يوسع FlutterActivity لتشغيل تطبيق Flutter
 */
class MainActivity : FlutterActivity() {

    private val CHANNEL = "com.videotranslate.ai/native"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // منع لقطة الشاشة في وضع الإنتاج
        // window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // قناة التواصل مع Dart
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getDeviceInfo" -> {
                        result.success(mapOf(
                            "sdk" to android.os.Build.VERSION.SDK_INT,
                            "device" to android.os.Build.DEVICE,
                            "model" to android.os.Build.MODEL,
                        ))
                    }
                    "keepScreenOn" -> {
                        val keepOn = call.arguments as? Boolean ?: false
                        if (keepOn) {
                            window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
                        } else {
                            window.clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
                        }
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
