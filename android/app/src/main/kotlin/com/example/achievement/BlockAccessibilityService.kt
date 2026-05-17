package com.ugolkov.achievement

import android.accessibilityservice.AccessibilityService
import android.content.Context
import android.content.Intent
import android.view.accessibility.AccessibilityEvent
import org.json.JSONArray

class BlockAccessibilityService : AccessibilityService() {
    private val achievementPackage = "com.ugolkov.achievement"

    override fun onAccessibilityEvent(event: AccessibilityEvent) {
        if (event.eventType != AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) return
        val packageName = event.packageName?.toString() ?: return
        if (packageName == achievementPackage) return
        if (!isInBlockList(packageName)) return
        if (achievementUsageMetThreshold()) return
        launchBlocker(packageName)
    }

    private fun isInBlockList(packageName: String): Boolean {
        val prefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val json = prefs.getString("flutter.block_list", "[]") ?: return false
        return try {
            val arr = JSONArray(json)
            (0 until arr.length()).any { arr.getString(it) == packageName }
        } catch (_: Exception) {
            false
        }
    }

    private fun achievementUsageMetThreshold(): Boolean {
        val prefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val usage = prefs.getInt("flutter.achievement_usage_minutes", 0)
        val threshold = prefs.getInt("flutter.threshold_minutes", 60)
        return usage >= threshold
    }

    private fun launchBlocker(blockedPackage: String) {
        val intent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            putExtra("blocked_package", blockedPackage)
        }
        startActivity(intent)
    }

    override fun onInterrupt() {}
}
