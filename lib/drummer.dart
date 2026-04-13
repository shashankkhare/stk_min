import 'dart:ffi' as ffi;
import 'dart:io';

class Drummer {
  late final ffi.DynamicLibrary _lib;

  late final void Function(double, double, double) _ffiNoteOn;
  late final void Function(double, double, double, double) _ffiNoteOnResonance;
  late final void Function(double) _ffiNoteOff;
  late final void Function(double) _ffiSetPitch;
  late final ffi.Pointer<ffi.Float> Function(int) _ffiRender;

  /// Instrument indices
  static const int dope = 0;
  static const int bass = 1;
  static const int snare = 2;
  static const int tomLow = 3;
  static const int tomMid = 4;
  static const int tomHigh = 5;
  static const int hihat = 6;
  static const int ride = 7;
  static const int crash = 8;
  static const int cowbell = 9;
  static const int tambourine = 10;
  static const int tablaNa = 11;
  static const int tablaGhe = 12;
  static const int tablaTee = 13;
  static const int tablaTak = 14;

  Drummer() {
    if (Platform.isAndroid) {
      _lib = ffi.DynamicLibrary.open('libstk_min.so');
    } else {
      _lib = ffi.DynamicLibrary.process();
    }

    _ffiNoteOn =
        _lib.lookupFunction<_NoteOnNative, _NoteOnDart>('drummer_noteOn');
    _ffiNoteOnResonance = _lib.lookupFunction<_NoteOnResonanceNative,
        _NoteOnResonanceDart>('drummer_noteOnResonance');
    _ffiNoteOff =
        _lib.lookupFunction<_NoteOffNative, _NoteOffDart>('drummer_noteOff');
    _ffiSetPitch =
        _lib.lookupFunction<_SetPitchNative, _SetPitchDart>('drummer_setPitch');
    _ffiRender =
        _lib.lookupFunction<_RenderNative, _RenderDart>('drummer_render');
  }

  /// Trigger a drum sound.
  /// [instrument] direct sample index (see constants like [tablaNa]).
  /// [amp] volume (0.0 - 1.0).
  /// [frequency] playback frequency in Hz (used for manual tuning).
  /// [resonance] tonal damping (0.0 = muted, 1.0 = bright). Defaults to 1.0.
  void noteOn(double instrument, double amp, double frequency,
      [double resonance = 1.0]) {
    if (resonance == 1.0) {
      _ffiNoteOn(instrument, amp, frequency);
    } else {
      _ffiNoteOnResonance(instrument, amp, frequency, resonance);
    }
  }

  void noteOff(double amp) => _ffiNoteOff(amp);

  void setPitch(double pitch) => _ffiSetPitch(pitch);

  List<double> render(int frameCount) {
    final ptr = _ffiRender(frameCount);
    return ptr.asTypedList(frameCount).toList();
  }
}

// FFI typedef pairs
typedef _NoteOnNative = ffi.Void Function(ffi.Double, ffi.Double, ffi.Double);
typedef _NoteOnDart = void Function(double, double, double);

typedef _NoteOnResonanceNative = ffi.Void Function(
    ffi.Double, ffi.Double, ffi.Double, ffi.Double);
typedef _NoteOnResonanceDart = void Function(double, double, double, double);

typedef _NoteOffNative = ffi.Void Function(ffi.Double);
typedef _NoteOffDart = void Function(double);

typedef _SetPitchNative = ffi.Void Function(ffi.Double);
typedef _SetPitchDart = void Function(double);

typedef _RenderNative = ffi.Pointer<ffi.Float> Function(ffi.Int32);
typedef _RenderDart = ffi.Pointer<ffi.Float> Function(int);
