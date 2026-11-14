package com.forestglass

import android.app.Application
import androidx.room.Room
import com.forestglass.data.AppDatabase
import com.forestglass.data.seedData
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

class ForestGlassApp : Application() {
    val database: AppDatabase by lazy {
        Room.databaseBuilder(this, AppDatabase::class.java, "forestglass.db")
            .fallbackToDestructiveMigration().build()
    }
    override fun onCreate() {
        super.onCreate()
        CoroutineScope(Dispatchers.IO).launch { seedData(database.lessonDao()) }
    }
}
