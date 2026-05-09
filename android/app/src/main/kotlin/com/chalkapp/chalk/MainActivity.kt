package com.chalkapp.chalk

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.BufferedReader
import java.io.InputStreamReader
import android.util.Log
import android.net.Uri // <--- The missing import
import kotlin.text.Charsets // <--- To ensure Charsets is found

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.chalkapp.chalk/file_reader"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "readContentUri") {
                val uriString = call.arguments as String
                try {
                    val content = readUri(uriString)
                    result.success(content)
                } catch (e: Exception) {
                    Log.e("Chalk", "MethodChannel Error: ${e.localizedMessage}")
                    result.error("UNAVAILABLE", "Could not read file", e.localizedMessage)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun readUri(uriString: String): String {
        return try {
            val uri = Uri.parse(uriString)
            
            // Try standard stream first
            val content = contentResolver.openInputStream(uri)?.use { inputStream ->
                inputStream.bufferedReader(Charsets.UTF_8).use { it.readText() }
            }

            if (content != null && content.isNotEmpty()) return content

            // FALLBACK: If stream fails or is empty, try opening via FileDescriptor
            contentResolver.openFileDescriptor(uri, "r")?.use { pfd ->
                java.io.FileInputStream(pfd.fileDescriptor).bufferedReader(Charsets.UTF_8).use { 
                    it.readText() 
                }
            } ?: ""
        } catch (e: Exception) {
            Log.e("Chalk", "Detailed Error: ${e.stackTraceToString()}")
            throw e 
        }
    }
}