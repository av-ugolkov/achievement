package com.ugolkov.achievement

import android.accessibilityservice.AccessibilityService
import android.content.Context
import android.content.Intent
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityWindowInfo
import org.json.JSONArray
import java.time.LocalDate

class BlockAccessibilityService : AccessibilityService() {
    private val achievementPackage = "com.ugolkov.achievement"
    private var lastBlockedPackage: String? = null
    private var lastBlockTime: Long = 0
    private val cooldownMs = 3000L

    override fun onAccessibilityEvent(event: AccessibilityEvent) {
        val packageName = when (event.eventType) {
            AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED -> event.packageName?.toString()
            // TYPE_WINDOWS_CHANGED fires even when a paused app resumes,
            // which TYPE_WINDOW_STATE_CHANGED misses.
            AccessibilityEvent.TYPE_WINDOWS_CHANGED -> getForegroundAppPackage()
            else -> return
        } ?: return

        if (packageName == achievementPackage) return

        // Cooldown: avoid re-blocking the same app within 3 seconds to prevent
        // rapid-fire triggering when multiple events fire on a single app switch.
        val now = System.currentTimeMillis()
        if (packageName == lastBlockedPackage && now - lastBlockTime < cooldownMs) return

        if (!isInBlockList(packageName)) return
        if (achievementUsageMetThreshold()) return

        lastBlockedPackage = packageName
        lastBlockTime = now
        launchBlocker(packageName)
    }

    private fun getForegroundAppPackage(): String? {
        return try {
            windows.firstOrNull {
                it.isFocused && it.type == AccessibilityWindowInfo.TYPE_APPLICATION
            }?.root?.packageName?.toString()
        } catch (_: Exception) {
            null
        }
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
        val storedDay = prefs.getString("flutter.achievement_usage_day", "") ?: ""
        val today = LocalDate.now().toString()
        val usage = if (storedDay == today) prefs.getInt("flutter.achievement_usage_minutes", 0) else 0
        val threshold = prefs.getInt("flutter.threshold_minutes", 60)
        return usage >= threshold
    }

    private fun launchBlocker(blockedPackage: String) {
        performGlobalAction(GLOBAL_ACTION_HOME)
        val intent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            putExtra("blocked_package", blockedPackage)
        }
        try {
            startActivity(intent)
        } catch (_: Exception) {}
    }

    override fun onInterrupt() {}
}
