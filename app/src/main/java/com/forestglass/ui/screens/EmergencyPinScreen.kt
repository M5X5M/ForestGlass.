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
    
    // التعديل هنا: فصلنا الـ Context عن الـ remember
    val context = LocalContext.current
    val manager = remember { EmergencyPinManager(context) }

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
