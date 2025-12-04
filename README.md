# stk_min

A minimalist, cross-platform Flutter wrapper for the [Synthesis ToolKit (STK)](https://github.com/thestk/stk) library. This plugin provides direct FFI access to STK's physical modeling synthesis algorithms, enabling high-quality musical instrument synthesis on all Flutter platforms.

## Features

- 🎵 **Cross-Platform**: Works on Android, iOS, Linux, macOS, and Windows
- ⚡ **High Performance**: Direct FFI bindings to native C++ STK library
- 🎹 **Physical Modeling**: Realistic instrument synthesis using physical models
- 🎛️ **Expressive Control**: Full access to instrument parameters (vibrato, breath noise, tone color, etc.)
- 🔧 **Minimalist Design**: Simple, focused API for instrument synthesis
- 🎼 **Extensible**: Foundation for supporting multiple STK instruments

## Currently Supported Instruments

- **Flute**: Physical model of a flute with breath control, vibrato, and tonal adjustments

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  stk_min: ^0.1.0
```

Then run:

```bash
flutter pub get
```

## Usage

### Basic Example

```dart
import 'package:stk_min/stk_min.dart';

// Create a flute instance
final flute = Flute();

// Initialize with a frequency (A4 = 440 Hz)
flute.init(440.0);

// Trigger a note with frequency and amplitude
flute.noteOn(440.0, 0.8);

// Generate audio samples (44100 samples = 1 second at 44.1kHz)
final samples = flute.render(44100);

// Use the samples with your audio playback library
// (e.g., flutter_soloud, just_audio, audioplayers, etc.)
```

### Advanced Control

```dart
final flute = Flute();

// Initialize
flute.init(523.25); // C5

// Add expressive controls
flute.controlChange(1, 30.0);   // Vibrato depth
flute.controlChange(11, 60.0);  // Vibrato speed
flute.controlChange(4, 20.0);   // Breath noise
flute.controlChange(2, 65.0);   // Tone color (jet delay)

// Play the note
flute.noteOn(523.25, 0.75);

// Render audio
final samples = flute.render(44100);
```

### Control Change Parameters

The `controlChange(int number, double value)` method accepts the following parameters (values 0-128):

| Parameter | Control # | Description |
|-----------|-----------|-------------|
| Vibrato Gain | 1 | Depth of pitch vibrato (0 = none, 128 = maximum) |
| Jet Delay | 2 | Tone color/brightness (lower = brighter, higher = darker) |
| Noise Gain | 4 | Breath noise amount (adds realism) |
| Vibrato Frequency | 11 | Speed of vibrato oscillation |
| Breath Pressure | 128 | Overall breath pressure envelope |

### Complete Example with Audio Playback

See the [example](example/) directory for a complete Flutter app demonstrating:
- Real-time parameter adjustment with sliders
- Audio playback using SoLoud
- Playing single notes and melodies
- Converting PCM samples to WAV format

## Audio Playback

**Important**: This plugin generates audio samples but does **not** include audio playback functionality. You need to use a separate audio library to play the generated samples.

### Recommended Audio Libraries

- **[flutter_soloud](https://pub.dev/packages/flutter_soloud)**: Cross-platform, low-latency audio (recommended)
- **[just_audio](https://pub.dev/packages/just_audio)**: Popular audio player
- **[audioplayers](https://pub.dev/packages/audioplayers)**: Simple audio playback

### Converting Samples to WAV

To play the raw PCM samples, you'll need to convert them to a proper audio format. Here's a helper function to create WAV files:

```dart
Uint8List createWavFile(List<double> samples, int sampleRate) {
  final numSamples = samples.length;
  final dataSize = numSamples * 2; // 16-bit samples
  final buffer = ByteData(44 + dataSize);
  
  // RIFF header
  buffer.setUint32(0, 0x52494646, Endian.big); // "RIFF"
  buffer.setUint32(4, 36 + dataSize, Endian.little);
  buffer.setUint32(8, 0x57415645, Endian.big); // "WAVE"
  
  // fmt chunk
  buffer.setUint32(12, 0x666D7420, Endian.big); // "fmt "
  buffer.setUint32(16, 16, Endian.little); // chunk size
  buffer.setUint16(20, 1, Endian.little); // PCM format
  buffer.setUint16(22, 1, Endian.little); // mono
  buffer.setUint32(24, sampleRate, Endian.little);
  buffer.setUint32(28, sampleRate * 2, Endian.little); // byte rate
  buffer.setUint16(32, 2, Endian.little); // block align
  buffer.setUint16(34, 16, Endian.little); // bits per sample
  
  // data chunk
  buffer.setUint32(36, 0x64617461, Endian.big); // "data"
  buffer.setUint32(40, dataSize, Endian.little);
  
  // PCM data
  var offset = 44;
  for (var sample in samples) {
    final intSample = (sample * 32767).clamp(-32768, 32767).toInt();
    buffer.setInt16(offset, intSample, Endian.little);
    offset += 2;
  }
  
  return buffer.buffer.asUint8List();
}
```

## Platform Support

| Platform | Status | Notes |
|----------|--------|-------|
| Android  | ✅ | API 21+ |
| iOS      | ✅ | iOS 12+ |
| Linux    | ✅ | ALSA backend |
| macOS    | ✅ | macOS 10.14+ |
| Windows  | ✅ | DirectSound backend |

## How It Works

This plugin uses Flutter's FFI (Foreign Function Interface) to directly call C++ functions from the STK library. The architecture is:

1. **Native Layer**: STK C++ library compiled for each platform
2. **FFI Bridge**: Minimal C wrapper exposing STK functions
3. **Dart Layer**: Type-safe Dart API using `dart:ffi`

This approach provides:
- **Zero platform channels overhead**: Direct native function calls
- **Platform independence**: Same Dart API on all platforms
- **High performance**: Native C++ execution speed

## Future Instruments

The STK library includes many more instruments that could be added:

- Clarinet, Saxophone, Brass instruments
- Bowed strings (Violin, Cello)
- Plucked strings (Guitar, Mandolin)
- Percussion (Drums, Marimba)
- Modal synthesis (Tubular bells, Bamboo chimes)

Contributions are welcome!

## Credits

- **STK Library**: Perry R. Cook and Gary P. Scavone - [The Synthesis ToolKit](https://github.com/thestk/stk)
- **Plugin Development**: Built with Flutter FFI

## License

This plugin is licensed under the MIT License. See [LICENSE](LICENSE) for details.

The STK library is licensed under its own terms. Please see the [STK License](https://github.com/thestk/stk/blob/master/LICENSE) for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request. Areas for contribution:

- Adding more STK instruments
- Improving documentation
- Adding more examples
- Performance optimizations
- Bug fixes

## Issues

Please file issues on the [GitHub repository](https://github.com/yourusername/stk_min/issues).
