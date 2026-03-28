import 'dart:ffi' as ffi;
import 'dart:io';

class Drummer {
  late final ffi.DynamicLibrary _lib;

  late final void Function(double, double) _ffiNoteOn;
  late final void Function(double) _ffiNoteOff;
  late final void Function(double) _ffiSetPitch;
  late final ffi.Pointer<ffi.Float> Function(int) _ffiRender;

  Drummer() {
    if (Platform.isAndroid) {
      _lib = ffi.DynamicLibrary.open('libstk_min.so');
    } else {
      _lib = ffi.DynamicLibrary.process();
    }

    _ffiNoteOn = _lib.lookupFunction<_NoteOnNative, _NoteOnDart>('drummer_noteOn');
    _ffiNoteOff = _lib.lookupFunction<_NoteOffNative, _NoteOffDart>('drummer_noteOff');
    _ffiSetPitch = _lib.lookupFunction<_SetPitchNative, _SetPitchDart>('drummer_setPitch');
    _ffiRender = _lib.lookupFunction<_RenderNative, _RenderDart>('drummer_render');
  }

  /// Trigger a drum sound.
  /// [instrument] frequency value as if MIDI note number.
  /// General MIDI drum instrument numbers.
  void noteOn(double instrument, double amp) => _ffiNoteOn(instrument, amp);
  
  void noteOff(double amp) => _ffiNoteOff(amp);

  void setPitch(double pitch) => _ffiSetPitch(pitch);

  List<double> render(int frameCount) {
    final ptr = _ffiRender(frameCount);
    return ptr.asTypedList(frameCount).toList();
  }
}

// FFI typedef pairs
typedef _NoteOnNative = ffi.Void Function(ffi.Double, ffi.Double);
typedef _NoteOnDart = void Function(double, double);

typedef _NoteOffNative = ffi.Void Function(ffi.Double);
typedef _NoteOffDart = void Function(double);

typedef _SetPitchNative = ffi.Void Function(ffi.Double);
typedef _SetPitchDart = void Function(double);

typedef _RenderNative = ffi.Pointer<ffi.Float> Function(ffi.Int32);
typedef _RenderDart = ffi.Pointer<ffi.Float> Function(int);
