package com.forestglass.data

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query

@Dao
interface LessonDao {
    @Query("SELECT * FROM lessons ORDER BY chapter, title")
    suspend fun getAllLessons(): List<Lesson>

    @Query("SELECT * FROM physics_laws")
    suspend fun getAllLaws(): List<PhysicsLaw>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertLessons(lessons: List<Lesson>)

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertLaws(laws: List<PhysicsLaw>)

    @Query("SELECT COUNT(*) FROM lessons")
    suspend fun countLessons(): Int
}
