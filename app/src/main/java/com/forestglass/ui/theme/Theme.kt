package com.forestglass.ui.theme

import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.runtime.Composable

private val DarkColors = darkColorScheme(
    background = OledBlack, surface = GlassSurface, primary = AccentCyan,
    secondary = AccentGreen, onBackground = TextPrimary, onSurface = TextPrimary, outline = GlassBorder
)

@Composable
fun ForestGlassTheme(content: @Composable () -> Unit) {
    MaterialTheme(colorScheme = DarkColors, content = content)
}
