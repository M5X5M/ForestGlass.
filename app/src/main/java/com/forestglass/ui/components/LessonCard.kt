package com.forestglass.ui.components

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.forestglass.data.Lesson
import com.forestglass.ui.theme.AccentCyan
import com.forestglass.ui.theme.TextSecondary

@Composable
fun LessonCard(lesson: Lesson, onClick: () -> Unit, modifier: Modifier = Modifier) {
    SpringButton(onClick = onClick, modifier = modifier.fillMaxWidth()) {
        LiquidGlass(
            modifier = Modifier.fillMaxWidth().padding(horizontal = 16.dp, vertical = 6.dp),
            cornerRadius = 22
        ) {
            Column(modifier = Modifier.padding(20.dp)) {
                Text("الفصل ${lesson.chapter}", color = AccentCyan, fontSize = 12.sp, fontWeight = FontWeight.Medium)
                Text(lesson.title, color = Color.White, fontSize = 17.sp, fontWeight = FontWeight.SemiBold, modifier = Modifier.padding(top = 6.dp))
                Text("${lesson.durationMinutes} دقيقة • تكرار ${lesson.examFrequency}/10", color = TextSecondary, fontSize = 12.sp, modifier = Modifier.padding(top = 4.dp))
            }
        }
    }
}
