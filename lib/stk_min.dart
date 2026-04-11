import 'dart:ffi' as ffi;
import 'dart:io';
import 'dart:typed_data';
import 'package:ffi/ffi.dart';

import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

export 'saxophone.dart';
export 'shakers.dart';
export 'drummer.dart';
export 'modal_bar.dart';

class StkMin {
  static const List<String> _rawwaves = [
    'bassdrum.raw',
    'cowbell1.raw',
    'crashcym.raw',
    'dope.raw',
    'hihatcym.raw',
    'marmstk1.raw',
    'ridecymb.raw',
    'snardrum.raw',
    'tambourn.raw',
    'tomhidrm.raw',
    'tomlowdr.raw',
    'tommiddr.raw',
    'tabla_na.raw',
    'tabla_din.raw',
    'tabla_tee.raw',
  ];

  /// Initializes the STK engine by extracting raw samples to the device's local storage.
  /// This should be called once at app startup before using any instruments that require samples.
  static Future<void> initialize() async {
    // For Desktop platforms, we can find rawwaves directly on disk.
    // This avoids using path_provider and rootBundle, which can hang in background isolates on Linux/Windows/macOS.
    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      print("💡 [StkMin] Initializing for Desktop platform: ${Platform.operatingSystem}");
      
      final List<String> potentialPaths = [];
      
      // 1. Bundle path (relative to executable)
      final String exeDir = p.dirname(Platform.resolvedExecutable);
      print("💡 [StkMin] Executable directory: $exeDir");
      
      if (Platform.isMacOS) {
        potentialPaths.add(p.join(exeDir, '..', 'Frameworks', 'App.framework', 'Resources', 'flutter_assets', 'packages', 'stk_min', 'assets', 'rawwaves'));
      } else {
        potentialPaths.add(p.join(exeDir, 'data', 'flutter_assets', 'packages', 'stk_min', 'assets', 'rawwaves'));
      }
      
      // 2. Local development path (relative to current working directory)
      potentialPaths.add(p.join(Directory.current.path, 'assets', 'rawwaves'));
      potentialPaths.add(p.join(Directory.current.path, 'packages', 'stk_min', 'assets', 'rawwaves'));
      potentialPaths.add(p.join(Directory.current.path, '..', 'stk_min', 'assets', 'rawwaves'));
      
      // 3. Absolute known path for this environment
      potentialPaths.add('/home/shashankkhare/AndroidStudioProjects/stk_min/assets/rawwaves');
      
      // 3. Fallback to manual home directory construction (to avoid path_provider hang)
      if (Platform.isLinux) {
        final home = Platform.environment['HOME'];
        if (home != null) {
          potentialPaths.add(p.join(home, '.local', 'share', 'stk_min', 'rawwaves'));
        }
      }

      for (final path in potentialPaths) {
        print("💡 [StkMin] Checking path: $path");
        final Directory dir = Directory(path);
        if (await dir.exists()) {
          print("✅ [StkMin] Found rawwaves at: $path");
          setRawwavePath(path);
          return;
        }
      }

      print("⚠️ [StkMin] No rawwaves found in standard disk locations.");
      
      // On Desktop, if we reach here and we are in an isolate, calling getApplicationSupportDirectory() will HANG.
      // We've already tried manual fallback in ~/.local/share, so we should probably stop here or try one last manual path.
      if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
         print("⚠️ [StkMin] Desktop check complete. No assets found. Aborting to prevent isolate hang.");
         return; 
      }
    }

    // Default logic for Android/iOS or if Desktop fails gracefully
    print("💡 [StkMin] Falling back to extraction logic (Android/iOS style)...");
    final Directory supportDir = await getApplicationSupportDirectory();
    final String rawwaveDir = p.join(supportDir.path, 'rawwaves');
    final Directory dir = Directory(rawwaveDir);

    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    for (final wave in _rawwaves) {
      final String assetPath = 'packages/stk_min/assets/rawwaves/$wave';
      final String targetPath = p.join(rawwaveDir, wave);

      final File targetFile = File(targetPath);
      // For now, always copy to ensure we have the latest.
      try {
        final ByteData data = await rootBundle.load(assetPath);
        final List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
        await targetFile.writeAsBytes(bytes, flush: true);
      } catch (e) {
        print("❌ [StkMin] Failed to load asset $assetPath: $e");
      }
    }

    setRawwavePath(rawwaveDir);
  }
}

void setRawwavePath(String path) {
  final ffi.DynamicLibrary lib;
  if (Platform.isAndroid) {
    lib = ffi.DynamicLibrary.open('libstk_min.so');
  } else {
    lib = ffi.DynamicLibrary.process();
  }
  final void Function(ffi.Pointer<Utf8>) setPath = lib.lookupFunction<
      ffi.Void Function(ffi.Pointer<Utf8>),
      void Function(ffi.Pointer<Utf8>)>('stk_setRawwavePath');

  // Ensure the path ends with a separator as STK might expect it
  String finalPath = path;
  if (!finalPath.endsWith(Platform.pathSeparator)) {
    finalPath += Platform.pathSeparator;
  }

  final pathPtr = finalPath.toNativeUtf8();
  setPath(pathPtr);
  malloc.free(pathPtr);
}

class Flute {
  late final ffi.DynamicLibrary _lib;

  late final void Function(double) _ffiInit;
  late final void Function(double, double) _ffiNoteOn;
  late final void Function(int, double) _ffiControlChange;
  late final ffi.Pointer<ffi.Float> Function(int) _ffiRender;

  Flute() {
    if (Platform.isAndroid) {
      _lib = ffi.DynamicLibrary.open('libstk_min.so');
    } else {
      // iOS, macOS, Linux, and Windows (if loaded by runner)
      // Note: For Windows, we might need explicit load if process() fails,
      // but let's stick to what worked for Linux for now.
      // Actually, let's keep it robust.
      _lib = ffi.DynamicLibrary.process();
    }

    _ffiInit = _lib.lookupFunction<_InitNative, _InitDart>('stk_init');
    _ffiNoteOn = _lib.lookupFunction<_NoteOnNative, _NoteOnDart>('stk_noteOn');
    _ffiControlChange =
        _lib.lookupFunction<_ControlChangeNative, _ControlChangeDart>(
            'stk_controlChange');
    _ffiRender = _lib.lookupFunction<_RenderNative, _RenderDart>('stk_render');
  }

  void init(double freq) => _ffiInit(freq);
  void noteOn(double freq, double amp) => _ffiNoteOn(freq, amp);

  /// Control change parameters:
  /// - 1: Vibrato Gain (0-128)
  /// - 2: Jet Delay (0-128)
  /// - 4: Noise Gain (0-128)
  /// - 11: Vibrato Frequency (0-128)
  /// - 128: Breath Pressure (0-128)
  void controlChange(int number, double value) =>
      _ffiControlChange(number, value);

  List<double> render(int frameCount) {
    final ptr = _ffiRender(frameCount);
    return ptr.asTypedList(frameCount).toList();
  }
}

// FFI typedef pairs
typedef _InitNative = ffi.Void Function(ffi.Double);
typedef _InitDart = void Function(double);

typedef _NoteOnNative = ffi.Void Function(ffi.Double, ffi.Double);
typedef _NoteOnDart = void Function(double, double);

typedef _ControlChangeNative = ffi.Void Function(ffi.Int32, ffi.Double);
typedef _ControlChangeDart = void Function(int, double);

typedef _RenderNative = ffi.Pointer<ffi.Float> Function(ffi.Int32);
typedef _RenderDart = ffi.Pointer<ffi.Float> Function(int);
