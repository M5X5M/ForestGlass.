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
