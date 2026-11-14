package com.forestglass.ui.components

import android.os.Build
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.hapticfeedback.HapticFeedback
import androidx.compose.ui.hapticfeedback.HapticFeedbackType
import androidx.compose.ui.platform.LocalHapticFeedback

@Composable
fun rememberHaptics(): ForestHaptics {
    val haptic = LocalHapticFeedback.current
    return remember(haptic) { ForestHaptics(haptic) }
}

class ForestHaptics(private val haptic: HapticFeedback) {
    fun click() = haptic.performHapticFeedback(HapticFeedbackType.TextHandleMove)
    fun confirm() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) haptic.performHapticFeedback(HapticFeedbackType.Confirm)
        else haptic.performHapticFeedback(HapticFeedbackType.LongPress)
    }
    fun reject() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) haptic.performHapticFeedback(HapticFeedbackType.Reject)
        else haptic.performHapticFeedback(HapticFeedbackType.LongPress)
    }
}
