package com.forestglass.ui.screens

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.forestglass.data.Lesson
import com.forestglass.ui.components.LessonCard
import com.forestglass.ui.theme.TextSecondary
import kotlinx.collections.immutable.ImmutableList

@Composable
fun HomeScreen(lessons: ImmutableList<Lesson>, onLessonClick: (Lesson) -> Unit) {
    Column(modifier = Modifier.fillMaxSize().padding(top = 32.dp)) {
        Text("ForestGlass", color = Color.White, fontSize = 32.sp, fontWeight = FontWeight.Bold, modifier = Modifier.padding(horizontal = 24.dp))
        Text("الفيزياء • السادس العلمي", color = TextSecondary, fontSize = 14.sp, modifier = Modifier.padding(horizontal = 24.dp, vertical = 4.dp))
        Spacer(Modifier.height(16.dp))
        LazyColumn(modifier = Modifier.fillMaxSize()) {
            items(lessons, key = { it.id }) { lesson ->
                LessonCard(lesson = lesson, onClick = { onLessonClick(lesson) })
            }
        }
    }
}
