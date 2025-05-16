package com.example.safe_zone

import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.os.Build
import android.provider.Settings
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.*

class MainActivity: FlutterActivity() {
    private val CHANNEL = "safe_zone/foreground_app"
    private val safeZonePackage = "com.example.safe_zone" // Change this if your package name is different

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            when (call.method) {
                "getForegroundApp" -> {
                    val app = getLastUsedAppExcludingSelf()
                    result.success(app)
                }
                "openUsageSettings" -> {
                    val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS)
                    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    startActivity(intent)
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun getLastUsedAppExcludingSelf(): String {
        val usm = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val time = System.currentTimeMillis()
        val appList = usm.queryUsageStats(
            UsageStatsManager.INTERVAL_DAILY,
            time - 1000 * 60,
            time
        )

        if (appList != null && appList.isNotEmpty()) {
            val sortedList = appList
                .filter { it.packageName != safeZonePackage }
                .sortedByDescending { it.lastTimeUsed }

            val lastUsed = sortedList.firstOrNull()
            return lastUsed?.packageName ?: "No app found (excluding self)"
        }

        return "No usage data found"
    }
}
