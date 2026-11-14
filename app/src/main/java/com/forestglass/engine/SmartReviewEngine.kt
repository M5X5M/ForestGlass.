package com.forestglass.engine

import com.forestglass.data.Lesson

data class ReviewSuggestion(val lesson: Lesson, val reason: String, val priority: Int)

object SmartReviewEngine {
    fun suggest(lessons: List<Lesson>, completedIds: Set<String>, averageWatchSpeed: Float = 1f): List<ReviewSuggestion> {
        return lessons.filter { it.id !in completedIds || it.examFrequency >= 7 }
            .map { lesson ->
                var score = 0
                val reasons = mutableListOf<String>()
                if (lesson.examFrequency >= 7) { score += 30; reasons += "يتكرر كثيرًا بالامتحانات" }
                if (averageWatchSpeed < 0.8f) { score += 20; reasons += "وتيرة إنجاز بطيئة" }
                if (lesson.durationMinutes > 45) { score += 15; reasons += "درس طويل" }
                score += lesson.chapter * 5
                ReviewSuggestion(lesson, reasons.joinToString(" • ").ifEmpty { "راجع بانتظام" }, score)
            }.sortedByDescending { it.priority }
    }
}
