import 'dart:ffi' as ffi;
import 'dart:io';

class Saxophone {
  late final ffi.DynamicLibrary _lib;

  late final void Function(double) _ffiInit;
  late final void Function(double, double) _ffiNoteOn;
  late final void Function(int, double) _ffiControlChange;
  late final ffi.Pointer<ffi.Float> Function(int) _ffiRender;

  Saxophone() {
    if (Platform.isAndroid) {
      _lib = ffi.DynamicLibrary.open('libstk_min.so');
    } else {
      // iOS, macOS, Linux, and Windows (if loaded by runner)
      _lib = ffi.DynamicLibrary.process();
    }

    _ffiInit = _lib.lookupFunction<_InitNative, _InitDart>('sax_init');
    _ffiNoteOn = _lib.lookupFunction<_NoteOnNative, _NoteOnDart>('sax_noteOn');
    _ffiControlChange =
        _lib.lookupFunction<_ControlChangeNative, _ControlChangeDart>(
            'sax_controlChange');
    _ffiRender = _lib.lookupFunction<_RenderNative, _RenderDart>('sax_render');
  }

  void init(double freq) => _ffiInit(freq);
  void noteOn(double freq, double amp) => _ffiNoteOn(freq, amp);

  /// Control change parameters:
  /// - 1: Vibrato Gain (0-128)
  /// - 2: Reed Stiffness (0-128)
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
