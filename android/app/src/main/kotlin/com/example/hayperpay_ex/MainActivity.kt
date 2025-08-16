package com.example.hayperpay_ex

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Register the HyperPay plugin
        flutterEngine.plugins.add(HyperPayPlugin())
    }
}
