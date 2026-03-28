import 'dart:ffi' as ffi;
import 'dart:io';

class Shakers {
  late final ffi.DynamicLibrary _lib;

  late final void Function(int) _ffiInit;
  late final void Function(double, double) _ffiNoteOn;
  late final void Function(int, double) _ffiControlChange;
  late final ffi.Pointer<ffi.Float> Function(int) _ffiRender;

  Shakers([int type = 0]) {
    if (Platform.isAndroid) {
      _lib = ffi.DynamicLibrary.open('libstk_min.so');
    } else {
      _lib = ffi.DynamicLibrary.process();
    }

    _ffiInit = _lib.lookupFunction<_InitNative, _InitDart>('shakers_init');
    _ffiNoteOn = _lib.lookupFunction<_NoteOnNative, _NoteOnDart>('shakers_noteOn');
    _ffiControlChange = _lib.lookupFunction<_ControlChangeNative, _ControlChangeDart>('shakers_controlChange');
    _ffiRender = _lib.lookupFunction<_RenderNative, _RenderDart>('shakers_render');
    
    if (type != 0) {
      init(type);
    }
  }

  void init(int type) => _ffiInit(type);
  void noteOn(double instrument, double amp) => _ffiNoteOn(instrument, amp);
  
  /// Control change parameters:
  /// - 2: Shake Energy (0-128)
  /// - 4: System Decay (0-128)
  /// - 11: Number Of Objects (0-128)
  /// - 1: Resonance Frequency (0-128)
  /// - 128: Shake Energy (0-128)
  void controlChange(int number, double value) => _ffiControlChange(number, value);

  List<double> render(int frameCount) {
    final ptr = _ffiRender(frameCount);
    return ptr.asTypedList(frameCount).toList();
  }
  
  // Instrument types
  static const int maraca = 0;
  static const int cabasa = 1;
  static const int sekere = 2;
  static const int tambourine = 3;
  static const int sleighBells = 4;
  static const int bambooChimes = 5;
  static const int sandPaper = 6;
  static const int cokeCan = 7;
  static const int sticks = 8;
  static const int crunch = 9;
  static const int bigRocks = 10;
  static const int littleRocks = 11;
  static const int nextMug = 12;
  static const int pennyMug = 13;
  static const int nickleMug = 14;
  static const int dimeMug = 15;
  static const int quarterMug = 16;
  static const int francMug = 17;
  static const int pesoMug = 18;
  static const int guiro = 19;
  static const int wrench = 20;
  static const int waterDrops = 21;
  static const int tunedBambooChimes = 22;
}

// FFI typedef pairs
typedef _InitNative = ffi.Void Function(ffi.Int32);
typedef _InitDart = void Function(int);

typedef _NoteOnNative = ffi.Void Function(ffi.Double, ffi.Double);
typedef _NoteOnDart = void Function(double, double);

typedef _ControlChangeNative = ffi.Void Function(ffi.Int32, ffi.Double);
typedef _ControlChangeDart = void Function(int, double);

typedef _RenderNative = ffi.Pointer<ffi.Float> Function(ffi.Int32);
typedef _RenderDart = ffi.Pointer<ffi.Float> Function(int);
