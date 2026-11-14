package com.forestglass.data

import androidx.room.Database
import androidx.room.RoomDatabase

@Database(entities = [Lesson::class, PhysicsLaw::class], version = 1, exportSchema = false)
abstract class AppDatabase : RoomDatabase() {
    abstract fun lessonDao(): LessonDao
}
