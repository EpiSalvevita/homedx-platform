package com.example.hdx_mobile

import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    private var cubeBridge: CubeBridge? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        Log.i("HDX_CUBE", "MainActivity configureFlutterEngine — registering CubeBridge")
        cubeBridge = CubeBridge(application, flutterEngine)
    }

    override fun onDestroy() {
        Log.i("HDX_CUBE", "MainActivity onDestroy — disposing CubeBridge")
        cubeBridge?.dispose()
        cubeBridge = null
        super.onDestroy()
    }
}
