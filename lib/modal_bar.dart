import 'dart:ffi' as ffi;
import 'dart:io';

class ModalBar {
  static const int marimba = 0;
  static const int vibraphone = 1;
  static const int agogo = 2;
  static const int wood1 = 3;
  static const int reso = 4;
  static const int wood2 = 5;
  static const int beats = 6;
  static const int twoFixed = 7;
  static const int clump = 8;

  late final ffi.DynamicLibrary _lib;

  late final void Function(int) _ffiInit;
  late final void Function(double, double) _ffiNoteOn;
  late final void Function(int, double) _ffiControlChange;
  late final ffi.Pointer<ffi.Float> Function(int) _ffiRender;

  ModalBar() {
    if (Platform.isAndroid) {
      _lib = ffi.DynamicLibrary.open('libstk_min.so');
    } else {
      _lib = ffi.DynamicLibrary.process();
    }

    _ffiInit = _lib.lookupFunction<_InitNative, _InitDart>('modalbar_init');
    _ffiNoteOn = _lib.lookupFunction<_NoteOnNative, _NoteOnDart>('modalbar_noteOn');
    _ffiControlChange = _lib.lookupFunction<_ControlChangeNative, _ControlChangeDart>('modalbar_controlChange');
    _ffiRender = _lib.lookupFunction<_RenderNative, _RenderDart>('modalbar_render');
  }

  void init(int preset) => _ffiInit(preset);

  void noteOn(double freq, double amp) => _ffiNoteOn(freq, amp);

  void controlChange(int number, double value) => _ffiControlChange(number, value);

  List<double> render(int frameCount) {
    final ptr = _ffiRender(frameCount);
    return ptr.asTypedList(frameCount).toList();
  }
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
