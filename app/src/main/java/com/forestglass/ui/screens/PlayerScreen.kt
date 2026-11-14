package com.forestglass.ui.screens

import androidx.compose.foundation.layout.*
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.viewinterop.AndroidView
import com.forestglass.data.Lesson
import com.forestglass.ui.components.SpringButton
import com.pierfrancescosoffritti.androidyoutubeplayer.core.player.YouTubePlayer
import com.pierfrancescosoffritti.androidyoutubeplayer.core.player.listeners.AbstractYouTubePlayerListener
import com.pierfrancescosoffritti.androidyoutubeplayer.core.player.views.YouTubePlayerView

@Composable
fun PlayerScreen(lesson: Lesson, onBack: () -> Unit) {
    var playerView by remember { mutableStateOf<YouTubePlayerView?>(null) }
    Column(modifier = Modifier.fillMaxSize()) {
        Box(modifier = Modifier.fillMaxWidth().aspectRatio(16f / 9f)) {
            AndroidView(
                factory = { context ->
                    YouTubePlayerView(context).apply {
                        addYouTubePlayerListener(object : AbstractYouTubePlayerListener() {
                            override fun onReady(player: YouTubePlayer) { player.loadVideo(lesson.youtubeVideoId, 0f) }
                        })
                        playerView = this
                    }
                },
                modifier = Modifier.fillMaxSize()
            )
        }
        Spacer(Modifier.height(16.dp))
        Text(lesson.title, color = Color.White, modifier = Modifier.padding(horizontal = 24.dp))
        Spacer(Modifier.weight(1f))
        SpringButton(onClick = onBack, modifier = Modifier.padding(24.dp)) { Text("رجوع", color = Color.White) }
    }
    DisposableEffect(Unit) { onDispose { playerView?.release() } }
}
