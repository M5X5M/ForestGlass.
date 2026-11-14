package com.forestglass.data

import androidx.compose.runtime.Immutable
import androidx.room.Entity
import androidx.room.PrimaryKey

@Immutable
@Entity(tableName = "physics_laws")
data class PhysicsLaw(
    @PrimaryKey val id: String,
    val title: String,
    val formula: String,
    val chapter: Int,
    val description: String
)
