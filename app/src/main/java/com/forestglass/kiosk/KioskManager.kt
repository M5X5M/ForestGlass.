package com.forestglass.kiosk

import android.app.Activity
import android.content.Intent
import android.os.Build
import android.provider.Settings
import android.view.WindowManager

class KioskManager(private val activity: Activity) {
    fun enterKioskMode() {
        try { if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) activity.startLockTask() }
        catch (_: SecurityException) { enableSoftKiosk() }
        activity.window.setFlags(WindowManager.LayoutParams.FLAG_SECURE, WindowManager.LayoutParams.FLAG_SECURE)
    }
    fun exitKioskMode() {
        try { activity.stopLockTask() } catch (_: Exception) {}
        activity.window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
    }
    private fun enableSoftKiosk() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP)
            activity.startActivity(Intent(Settings.ACTION_PIN_SCREEN))
    }
}
