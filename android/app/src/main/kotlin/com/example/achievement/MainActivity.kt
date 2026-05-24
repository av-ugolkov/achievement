package com.ugolkov.achievement

import android.content.Intent
import android.os.Bundle
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "com.ugolkov.achievement/blocker"
    private var pendingBlockedPackage: String? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        pendingBlockedPackage = intent?.getStringExtra("blocked_package")
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        val pkg = intent.getStringExtra("blocked_package") ?: return
        flutterEngine?.dartExecutor?.binaryMessenger?.let { messenger ->
            MethodChannel(messenger, channelName).invokeMethod("showBlocker", pkg)
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getPendingBlockedPackage" -> {
                        result.success(pendingBlockedPackage)
                        pendingBlockedPackage = null
                    }
                    "isAccessibilityEnabled" -> {
                        val enabledServices = Settings.Secure.getString(
                            contentResolver,
                            Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES
                        ) ?: ""
                        result.success(
                            enabledServices.contains("$packageName/com.ugolkov.achievement.BlockAccessibilityService")
                        )
                    }
                    "openAccessibilitySettings" -> {
                        startActivity(Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS))
                        result.success(null)
                    }
                    "getLaunchablePackages" -> {
                        val launcherIntent = Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_LAUNCHER)
                        val activities = packageManager.queryIntentActivities(launcherIntent, 0)
                        result.success(activities.map { it.activityInfo.packageName }.distinct())
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
