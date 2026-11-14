package com.forestglass.data

import androidx.compose.runtime.Immutable
import androidx.room.Entity
import androidx.room.PrimaryKey

@Immutable
@Entity(tableName = "lessons")
data class Lesson(
    @PrimaryKey val id: String,
    val title: String,
    val chapter: Int,
    val youtubeVideoId: String,
    val durationMinutes: Int,
    val examFrequency: Int
)
