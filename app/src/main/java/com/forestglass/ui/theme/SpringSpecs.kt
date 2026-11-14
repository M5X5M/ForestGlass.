package com.forestglass.ui.theme

import androidx.compose.animation.core.Spring
import androidx.compose.animation.core.SpringSpec

object ForestSprings {
    val PageTransition = SpringSpec<Float>(stiffness = 380f, dampingRatio = Spring.DampingRatioLowBouncy)
    val ButtonPress = SpringSpec<Float>(stiffness = 1200f, dampingRatio = Spring.DampingRatioMediumBouncy)
    val DragRelease = SpringSpec<Float>(stiffness = 200f, dampingRatio = Spring.DampingRatioHighBouncy)
}
