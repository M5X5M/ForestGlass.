#!/bin/bash
set -e

echo "🌲 إنشاء مشروع ForestGlass..."

# ===== 1. المجلدات =====
mkdir -p app/src/main/java/com/forestglass/{data,engine,kiosk,player,ui/{theme,components,screens}}
mkdir -p app/src/main/res/{values,raw}
mkdir -p gradle/wrapper
mkdir -p .github/workflows

# ===== 2. Gradle =====
cat > settings.gradle.kts << 'EOF_GRADLE'
pluginManagement {
    repositories { google(); mavenCentral(); gradlePluginPortal() }
}
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google(); mavenCentral(); maven("https://jitpack.io")
    }
}
rootProject.name = "ForestGlass"
include(":app")
EOF_GRADLE

cat > build.gradle.kts << 'EOF_GRADLE'
plugins {
    id("com.android.application") version "8.7.3" apply false
    id("org.jetbrains.kotlin.android") version "2.0.21" apply false
    id("com.google.devtools.ksp") version "2.0.21-1.0.28" apply false
}
EOF_GRADLE

cat > gradle.properties << 'EOF_GRADLE'
org.gradle.jvmargs=-Xmx4096m -Dfile.encoding=UTF-8
android.useAndroidX=true
android.nonTransitiveRClass=true
kotlin.code.style=official
EOF_GRADLE

cat > app/build.gradle.kts << 'EOF_GRADLE'
plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("com.google.devtools.ksp")
}
android {
    namespace = "com.forestglass"
    compileSdk = 35
    defaultConfig {
        applicationId = "com.forestglass"
        minSdk = 26
        targetSdk = 35
        versionCode = 1
        versionName = "1.0.0"
    }
    buildFeatures { compose = true }
    composeOptions { kotlinCompilerExtensionVersion = "1.5.15" }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    kotlinOptions { jvmTarget = "17" }
}
dependencies {
    implementation(platform("androidx.compose:compose-bom:2024.12.01"))
    implementation("androidx.compose.ui:ui")
    implementation("androidx.compose.material3:material3")
    implementation("androidx.compose.ui:ui-graphics")
    implementation("androidx.compose.ui:ui-tooling-preview")
    implementation("androidx.compose.animation:animation")
    debugImplementation("androidx.compose.ui:ui-tooling")
    implementation("androidx.activity:activity-compose:1.9.3")
    implementation("androidx.lifecycle:lifecycle-viewmodel-compose:2.8.7")
    implementation("androidx.lifecycle:lifecycle-runtime-compose:2.8.7")
    implementation("androidx.core:core-ktx:1.13.1")
    implementation("androidx.room:room-runtime:2.6.1")
    implementation("androidx.room:room-ktx:2.6.1")
    ksp("androidx.room:room-compiler:2.6.1")
    implementation("androidx.security:security-crypto:1.1.0-alpha06")
    implementation("com.pierfrancescosoffritti.androidyoutubeplayer:core:12.1.0")
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.9.0")
    implementation("org.jetbrains.kotlinx:kotlinx-collections-immutable:0.3.8")
}
EOF_GRADLE

cat > app/proguard-rules.pro << 'EOF_GRADLE'
-keep class com.forestglass.data.** { *; }
-keep class com.pierfrancescosoffritti.** { *; }
EOF_GRADLE

# ===== 3. Manifest & Resources =====
cat > app/src/main/AndroidManifest.xml << 'EOF_MANIFEST'
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.VIBRATE" />
    <application
        android:name=".ForestGlassApp"
        android:allowBackup="false"
        android:hardwareAccelerated="true"
        android:label="@string/app_name"
        android:theme="@style/Theme.ForestGlass"
        android:supportsRtl="true">
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:supportsPictureInPicture="true"
            android:configChanges="screenSize|smallestScreenSize|screenLayout|orientation|keyboardHidden">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>
    </application>
</manifest>
EOF_MANIFEST

cat > app/src/main/res/values/strings.xml << 'EOF_XML'
<resources>
    <string name="app_name">ForestGlass</string>
</resources>
EOF_XML

cat > app/src/main/res/values/themes.xml << 'EOF_XML'
<resources>
    <style name="Theme.ForestGlass" parent="android:Theme.Material.NoActionBar">
        <item name="android:windowBackground">@android:color/black</item>
        <item name="android:statusBarColor">@android:color/black</item>
        <item name="android:navigationBarColor">@android:color/black</item>
    </style>
</resources>
EOF_XML

cat > app/src/main/res/raw/liquid_glass.agsl << 'EOF_AGSL'
uniform shader content;
uniform float2 size;
uniform float blurRadius;
uniform float refraction;
uniform float lightAngle;

half4 main(float2 coord) {
    float2 uv = coord / size;
    float2 offset = float2(
        sin(uv.y * 3.14159 + lightAngle) * refraction * 0.01,
        cos(uv.x * 3.14159 + lightAngle) * refraction * 0.01
    );
    half4 blurred = half4(0.0);
    float total = 0.0;
    for (float x = -2.0; x <= 2.0; x += 1.0) {
        for (float y = -2.0; y <= 2.0; y += 1.0) {
            float weight = 1.0 / (1.0 + length(float2(x, y)));
            blurred += content.eval(coord + float2(x, y) * blurRadius * 2.0) * weight;
            total += weight;
        }
    }
    blurred /= total;
    half4 glassTint = half4(1.0, 1.0, 1.0, 0.08);
    float highlight = smoothstep(0.4, 0.6, sin(lightAngle) * 0.5 + 0.5) * 0.15;
    return mix(blurred, glassTint, 0.15) + half4(highlight, highlight, highlight, 0.0);
}
EOF_AGSL

# ===== 4. Kotlin Sources =====
cat > app/src/main/java/com/forestglass/ForestGlassApp.kt << 'EOF_KT'
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
EOF_KT

cat > app/src/main/java/com/forestglass/MainActivity.kt << 'EOF_KT'
package com.forestglass

import android.os.Bundle
import android.view.WindowManager
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import com.forestglass.ui.ForestGlassRoot
import com.forestglass.ui.theme.ForestGlassTheme

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        window.setFlags(
            WindowManager.LayoutParams.FLAG_HARDWARE_ACCELERATED,
            WindowManager.LayoutParams.FLAG_HARDWARE_ACCELERATED
        )
        setContent {
            ForestGlassTheme {
                Box(modifier = Modifier.fillMaxSize().background(Color.Black)) {
                    ForestGlassRoot()
                }
            }
        }
    }
}
EOF_KT

cat > app/src/main/java/com/forestglass/data/Lesson.kt << 'EOF_KT'
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
EOF_KT

cat > app/src/main/java/com/forestglass/data/PhysicsLaw.kt << 'EOF_KT'
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
EOF_KT

cat > app/src/main/java/com/forestglass/data/LessonDao.kt << 'EOF_KT'
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
EOF_KT

cat > app/src/main/java/com/forestglass/data/AppDatabase.kt << 'EOF_KT'
package com.forestglass.data

import androidx.room.Database
import androidx.room.RoomDatabase

@Database(entities = [Lesson::class, PhysicsLaw::class], version = 1, exportSchema = false)
abstract class AppDatabase : RoomDatabase() {
    abstract fun lessonDao(): LessonDao
}
EOF_KT

cat > app/src/main/java/com/forestglass/data/SeedData.kt << 'EOF_KT'
package com.forestglass.data

import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

suspend fun seedData(dao: LessonDao) = withContext(Dispatchers.IO) {
    if (dao.countLessons() > 0) return@withContext
    val lessons = listOf(
        Lesson("c1_l1", "الحركة في بعد واحد", 1, "dQw4w9WgXcQ", 45, 9),
        Lesson("c1_l2", "الحركة في بعدين", 1, "dQw4w9WgXcQ", 40, 7),
        Lesson("c2_l1", "قوانين نيوتن للحركة", 2, "dQw4w9WgXcQ", 50, 10),
        Lesson("c2_l2", "تطبيقات قوانين نيوتن", 2, "dQw4w9WgXcQ", 35, 8),
        Lesson("c3_l1", "الشغل والطاقة", 3, "dQw4w9WgXcQ", 40, 9),
        Lesson("c3_l2", "حفظ الطاقة الميكانيكية", 3, "dQw4w9WgXcQ", 45, 10),
        Lesson("c4_l1", "كمية التحرك والتصادمات", 4, "dQw4w9WgXcQ", 50, 8),
        Lesson("c5_l1", "الحركة الدورانية", 5, "dQw4w9WgXcQ", 55, 7),
        Lesson("c6_l1", "المرونة وتوازن الأجسام", 6, "dQw4w9WgXcQ", 40, 6),
        Lesson("c7_l1", "الموائع الساكنة", 7, "dQw4w9WgXcQ", 45, 8),
        Lesson("c8_l1", "الموائع المتحركة", 8, "dQw4w9WgXcQ", 50, 9)
    )
    val laws = listOf(
        PhysicsLaw("l1", "قانون نيوتن الأول", "F = 0", 2, "الجسم الساكن يبقى ساكنًا"),
        PhysicsLaw("l2", "قانون نيوتن الثاني", "F = m·a", 2, "القوة تساوي الكتلة × التسارع"),
        PhysicsLaw("l3", "قانون نيوتن الثالث", "F1 = -F2", 2, "لكل فعل رد فعل مساوٍ ومعاكس"),
        PhysicsLaw("l4", "معادلة الحركة الأولى", "v = u + a·t", 1, "السرعة النهائية بدلالة الزمن"),
        PhysicsLaw("l5", "قانون الشغل", "W = F·d·cos(θ)", 3, "الشغل = القوة × الإزاحة"),
        PhysicsLaw("l6", "الطاقة الحركية", "KE = ½·m·v²", 3, "طاقة الجسم المتحرك"),
        PhysicsLaw("l7", "كمية التحرك", "p = m·v", 4, "حاصل ضرب الكتلة بالسرعة"),
        PhysicsLaw("l8", "قانون أرخميدس", "F_b = ρ·V·g", 7, "قوة الطفو في الموائع")
    )
    dao.insertLessons(lessons)
    dao.insertLaws(laws)
}
EOF_KT

cat > app/src/main/java/com/forestglass/engine/FuzzySearchEngine.kt << 'EOF_KT'
package com.forestglass.engine

import com.forestglass.data.PhysicsLaw

object FuzzySearchEngine {
    fun search(query: String, laws: List<PhysicsLaw>, threshold: Double = 0.55): List<PhysicsLaw> {
        if (query.isBlank()) return emptyList()
        val nq = normalize(query)
        return laws.map { law ->
            val best = maxOf(
                similarity(nq, normalize(law.title)),
                similarity(nq, normalize(law.formula)),
                similarity(nq, normalize(law.description))
            )
            law to best
        }.filter { it.second >= threshold }
            .sortedByDescending { it.second }
            .map { it.first }
    }
    private fun normalize(s: String): String =
        s.trim().lowercase()
            .replace("أ", "ا").replace("إ", "ا").replace("آ", "ا")
            .replace("ة", "ه").replace("ى", "ي")
            .replace(Regex("[\\u064B-\\u065F]"), "")
    private fun similarity(a: String, b: String): Double {
        if (a == b) return 1.0
        if (a.isEmpty() || b.isEmpty()) return 0.0
        return 1.0 - levenshtein(a, b).toDouble() / maxOf(a.length, b.length)
    }
    private fun levenshtein(a: String, b: String): Int {
        val dp = Array(a.length + 1) { IntArray(b.length + 1) }
        for (i in 0..a.length) dp[i][0] = i
        for (j in 0..b.length) dp[0][j] = j
        for (i in 1..a.length) for (j in 1..b.length) {
            val cost = if (a[i - 1] == b[j - 1]) 0 else 1
            dp[i][j] = minOf(dp[i - 1][j] + 1, dp[i][j - 1] + 1, dp[i - 1][j - 1] + cost)
        }
        return dp[a.length][b.length]
    }
}
EOF_KT

cat > app/src/main/java/com/forestglass/engine/SmartReviewEngine.kt << 'EOF_KT'
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
EOF_KT

cat > app/src/main/java/com/forestglass/kiosk/EmergencyPinManager.kt << 'EOF_KT'
package com.forestglass.kiosk

import android.content.Context
import androidx.security.crypto.EncryptedSharedPreferences
import androidx.security.crypto.MasterKey
import java.security.MessageDigest

class EmergencyPinManager(context: Context) {
    private val masterKey = MasterKey.Builder(context).setKeyScheme(MasterKey.KeyScheme.AES256_GCM).build()
    private val prefs = EncryptedSharedPreferences.create(
        context, "emergency_pin_prefs", masterKey,
        EncryptedSharedPreferences.PrefKeyEncryptionScheme.AES256_SIV,
        EncryptedSharedPreferences.PrefValueEncryptionScheme.AES256_GCM
    )
    init { if (prefs.getString("pin_hash", null) == null) setPin("1234") }
    fun setPin(pin: String) { prefs.edit().putString("pin_hash", hash(pin)).apply() }
    fun verifyPin(pin: String): Boolean = prefs.getString("pin_hash", null) == hash(pin)
    private fun hash(pin: String): String =
        MessageDigest.getInstance("SHA-256").digest(pin.toByteArray()).joinToString("") { "%02x".format(it) }
}
EOF_KT

cat > app/src/main/java/com/forestglass/kiosk/KioskManager.kt << 'EOF_KT'
package com.forestglass.kiosk

import android.app.Activity
import android.content.Intent
import android.os.Build
import android.provider.Settings
import android.view.WindowManager

class KioskManager(private val activity: Activity) {
    fun enterKioskMode() {
        try { if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) activity.startLockTask() }
        catch (_: SecurityException) { enableSoftKiosk() }
        activity.window.setFlags(WindowManager.LayoutParams.FLAG_SECURE, WindowManager.LayoutParams.FLAG_SECURE)
    }
    fun exitKioskMode() {
        try { activity.stopLockTask() } catch (_: Exception) {}
        activity.window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
    }
    private fun enableSoftKiosk() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP)
            activity.startActivity(Intent(Settings.ACTION_PIN_SCREEN))
    }
}
EOF_KT

cat > app/src/main/java/com/forestglass/ui/theme/Color.kt << 'EOF_KT'
package com.forestglass.ui.theme

import androidx.compose.ui.graphics.Color

val OledBlack = Color(0xFF000000)
val GlassSurface = Color(0xFF0A0A0A)
val GlassBorder = Color(0xFF1E1E1E)
val AccentCyan = Color(0xFF00E5FF)
val AccentGreen = Color(0xFF00E676)
val TextPrimary = Color(0xFFF5F5F5)
val TextSecondary = Color(0xFFAAAAAA)
EOF_KT

cat > app/src/main/java/com/forestglass/ui/theme/Theme.kt << 'EOF_KT'
package com.forestglass.ui.theme

import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.runtime.Composable

private val DarkColors = darkColorScheme(
    background = OledBlack, surface = GlassSurface, primary = AccentCyan,
    secondary = AccentGreen, onBackground = TextPrimary, onSurface = TextPrimary, outline = GlassBorder
)

@Composable
fun ForestGlassTheme(content: @Composable () -> Unit) {
    MaterialTheme(colorScheme = DarkColors, content = content)
}
EOF_KT

cat > app/src/main/java/com/forestglass/ui/theme/SpringSpecs.kt << 'EOF_KT'
package com.forestglass.ui.theme

import androidx.compose.animation.core.Spring
import androidx.compose.animation.core.SpringSpec

object ForestSprings {
    val PageTransition = SpringSpec<Float>(stiffness = 380f, dampingRatio = Spring.DampingRatioLowBouncy)
    val ButtonPress = SpringSpec<Float>(stiffness = 1200f, dampingRatio = Spring.DampingRatioMediumBouncy)
    val DragRelease = SpringSpec<Float>(stiffness = 200f, dampingRatio = Spring.DampingRatioHighBouncy)
}
EOF_KT

cat > app/src/main/java/com/forestglass/ui/components/HapticUtils.kt << 'EOF_KT'
package com.forestglass.ui.components

import android.os.Build
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.hapticfeedback.HapticFeedback
import androidx.compose.ui.hapticfeedback.HapticFeedbackType
import androidx.compose.ui.platform.LocalHapticFeedback

@Composable
fun rememberHaptics(): ForestHaptics {
    val haptic = LocalHapticFeedback.current
    return remember(haptic) { ForestHaptics(haptic) }
}

class ForestHaptics(private val haptic: HapticFeedback) {
    fun click() = haptic.performHapticFeedback(HapticFeedbackType.TextHandleMove)
    fun confirm() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) haptic.performHapticFeedback(HapticFeedbackType.Confirm)
        else haptic.performHapticFeedback(HapticFeedbackType.LongPress)
    }
    fun reject() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) haptic.performHapticFeedback(HapticFeedbackType.Reject)
        else haptic.performHapticFeedback(HapticFeedbackType.LongPress)
    }
}
EOF_KT

cat > app/src/main/java/com/forestglass/ui/components/LiquidGlass.kt << 'EOF_KT'
package com.forestglass.ui.components

import android.graphics.RenderEffect
import android.graphics.Shader
import android.os.Build
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxScope
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.asComposeRenderEffect
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.unit.dp

@Composable
fun LiquidGlass(
    modifier: Modifier = Modifier,
    cornerRadius: Int = 24,
    content: @Composable BoxScope.() -> Unit
) {
    val shape = RoundedCornerShape(cornerRadius.dp)
    val glassModifier = modifier
        .graphicsLayer {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                renderEffect = RenderEffect.createBlurEffect(24f, 24f, Shader.TileMode.CLAMP).asComposeRenderEffect()
            }
            clip = true
            this.shape = shape
        }
        .background(Brush.verticalGradient(listOf(Color.White.copy(alpha = 0.10f), Color.White.copy(alpha = 0.04f))))
        .border(1.dp, Brush.linearGradient(listOf(Color.White.copy(alpha = 0.25f), Color.White.copy(alpha = 0.05f))), shape)
    Box(modifier = glassModifier, content = content)
}
EOF_KT

cat > app/src/main/java/com/forestglass/ui/components/SpringButton.kt << 'EOF_KT'
package com.forestglass.ui.components

import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.interaction.collectIsPressedAsState
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.scale
import androidx.compose.ui.unit.dp
import com.forestglass.ui.theme.ForestSprings

@Composable
fun SpringButton(onClick: () -> Unit, modifier: Modifier = Modifier, content: @Composable () -> Unit) {
    val interaction = remember { MutableInteractionSource() }
    val pressed by interaction.collectIsPressedAsState()
    val haptics = rememberHaptics()
    val scale by animateFloatAsState(
        targetValue = if (pressed) 0.93f else 1f,
        animationSpec = ForestSprings.ButtonPress, label = "btnScale"
    )
    Box(
        modifier = modifier.scale(scale).clip(RoundedCornerShape(20.dp))
            .clickable(interactionSource = interaction, indication = null) {
                haptics.click(); onClick()
            },
        contentAlignment = Alignment.Center,
        content = { content() }
    )
}
EOF_KT

cat > app/src/main/java/com/forestglass/ui/components/LessonCard.kt << 'EOF_KT'
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
EOF_KT

cat > app/src/main/java/com/forestglass/ui/screens/HomeScreen.kt << 'EOF_KT'
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
EOF_KT

cat > app/src/main/java/com/forestglass/ui/screens/PlayerScreen.kt << 'EOF_KT'
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
EOF_KT

cat > app/src/main/java/com/forestglass/ui/screens/EmergencyPinScreen.kt << 'EOF_KT'
package com.forestglass.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.unit.dp
import com.forestglass.kiosk.EmergencyPinManager

@Composable
fun EmergencyPinScreen(onSuccess: () -> Unit, onCancel: () -> Unit) {
    var pin by remember { mutableStateOf("") }
    var error by remember { mutableStateOf(false) }
    val manager = remember { EmergencyPinManager(LocalContext.current) }
    Column(
        modifier = Modifier.fillMaxSize().background(Color.Black),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Text("رمز الطوارئ", color = Color.White)
        Spacer(Modifier.height(24.dp))
        OutlinedTextField(
            value = pin, onValueChange = { if (it.length <= 6) pin = it },
            visualTransformation = PasswordVisualTransformation(),
            keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.NumberPassword),
            isError = error, label = { Text("PIN") }
        )
        if (error) Text("رمز خاطئ", color = Color.Red)
        Spacer(Modifier.height(16.dp))
        Row {
            Button(onClick = onCancel) { Text("إلغاء") }
            Spacer(Modifier.width(12.dp))
            Button(onClick = { if (manager.verifyPin(pin)) onSuccess() else error = true }) { Text("تأكيد") }
        }
    }
}
EOF_KT

cat > app/src/main/java/com/forestglass/ui/ForestGlassRoot.kt << 'EOF_KT'
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
EOF_KT

# ===== 5. GitHub Workflow =====
cat > .github/workflows/build.yml << 'EOF_WF'
name: Build ForestGlass APK
on:
  push:
    branches: [ main ]
  workflow_dispatch:
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-java@v4
        with:
          distribution: temurin
          java-version: '17'
      - uses: gradle/gradle-build-action@v3
      - run: chmod +x gradlew
      - run: ./gradlew assembleDebug --stacktrace
      - uses: actions/upload-artifact@v4
        with:
          name: ForestGlass-APK
          path: app/build/outputs/apk/debug/app-debug.apk
EOF_WF

# ===== 6. Gradle Wrapper =====
echo "📦 تنزيل Gradle Wrapper..."
cat > gradle/wrapper/gradle-wrapper.properties << 'EOF_WRAPPER'
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
distributionUrl=https\://services.gradle.org/distributions/gradle-8.9-bin.zip
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
EOF_WRAPPER
curl -sL https://raw.githubusercontent.com/gradle/gradle/v8.9.0/gradlew -o gradlew
curl -sL https://raw.githubusercontent.com/gradle/gradle/v8.9.0/gradlew.bat -o gradlew.bat
curl -sL https://raw.githubusercontent.com/gradle/gradle/v8.9.0/gradle/wrapper/gradle-wrapper.jar -o gradle/wrapper/gradle-wrapper.jar
chmod +x gradlew

# ===== 7. .gitignore =====
cat > .gitignore << 'EOF_GI'
*.iml
.gradle
/local.properties
/.idea
.DS_Store
/build
/captures
.externalNativeBuild
.cxx
local.properties
EOF_GI

echo ""
echo "✅ تم إنشاء كل الملفات!"
echo "📌 الخطوة التالية: git add . && git commit -m 'init' && git push"
