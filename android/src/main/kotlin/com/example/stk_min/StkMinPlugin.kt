package com.example.stk_min

import io.flutter.embedding.engine.plugins.FlutterPlugin

/** 
 * StkMinPlugin - Minimal FFI plugin
 * 
 * This plugin uses FFI (Foreign Function Interface) to directly call
 * native C++ code. No MethodChannels are needed.
 * 
 * The native library (libstk_min.so) is built via CMake and loaded
 * directly by Dart using dart:ffi.
 */
class StkMinPlugin : FlutterPlugin {
    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        // Nothing to do - FFI plugins don't use platform channels
        // The native library is loaded directly by Dart
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        // Nothing to clean up
    }
}
