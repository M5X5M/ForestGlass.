package com.forestglass.ui

import androidx.compose.animation.Crossfade
import androidx.compose.animation.core.tween
import androidx.compose.runtime.*
import androidx.compose.ui.platform.LocalContext
import com.forestglass.ForestGlassApp
import com.forestglass.data.Lesson
import com.forestglass.ui.screens.EmergencyPinScreen
import com.forestglass.ui.screens.HomeScreen
import com.forestglass.ui.screens.PlayerScreen
import kotlinx.collections.immutable.toImmutableList
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

sealed interface Screen {
    data object Home : Screen
    data class Player(val lesson: Lesson) : Screen
    data object Emergency : Screen
}

@Composable
fun ForestGlassRoot() {
    val context = LocalContext.current
    val app = context.applicationContext as ForestGlassApp
    var lessons by remember { mutableStateOf(emptyList<Lesson>()) }
    var screen by remember { mutableStateOf<Screen>(Screen.Home) }
    LaunchedEffect(Unit) {
        lessons = withContext(Dispatchers.IO) { app.database.lessonDao().getAllLessons() }
    }
    Crossfade(targetState = screen, animationSpec = tween(280), label = "screenTransition") { current ->
        when (current) {
            is Screen.Home -> HomeScreen(lessons = lessons.toImmutableList(), onLessonClick = { screen = Screen.Player(it) })
            is Screen.Player -> PlayerScreen(lesson = current.lesson, onBack = { screen = Screen.Home })
            is Screen.Emergency -> EmergencyPinScreen(onSuccess = { screen = Screen.Home }, onCancel = { screen = Screen.Home })
        }
    }
}
