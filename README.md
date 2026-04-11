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

- **Drummer**: Kick, Snare, Toms, Hi-hat, Ride, Crash, Cowbell, Tambourine, and **Indian Tabla** (Dayan and Bayan) with frequency-based tuning for traditional Sa/Shruti alignment.
- **Flute**: Physically modeled flute with control over vibrato, breath, and jet delay.
- **Saxophone**: Expressive saxophone model with reed and blow pressure controls.
- **Shakers**: A collection of 25+ shaker instruments (Maraca, Cabasa, Water Drops, etc.).
- **Modal Instruments**: Marimba, Vibraslap, Agogo, WoodBlocks.

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  stk_min: ^0.5.0
```

Then run:

```bash
flutter pub get
```

## Usage

### Usage Example

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

### Saxophone Example

```dart
import 'package:stk_min/saxophone.dart';

// Create a saxophone instance
final saxophone = Saxophone();

// Initialize with a frequency (D4 = 293.66 Hz)
saxophone.init(293.66);

// Play a note
saxophone.noteOn(293.66, 0.9);

// Generate audio samples
final samples = saxophone.render(44100);

// Add expressive controls
saxophone.controlChange(1, 40.0);   // Vibrato depth
saxophone.controlChange(11, 50.0);  // Vibrato speed
saxophone.controlChange(2, 80.0);   // Reed stiffness
saxophone.controlChange(4, 15.0);   // Breath noise
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

### Shakers Example

```dart
import 'package:stk_min/shakers.dart';

// Create a Shakers instance (default to Maraca)
final shakers = Shakers(Shakers.maraca);

// Shake it! (instrument type, amplitude)
shakers.noteOn(Shakers.maraca.toDouble(), 0.8);

// Trigger a different sound (e.g., Tambourine)
shakers.noteOn(Shakers.tambourine.toDouble(), 0.9);

// Add expressive controls
shakers.controlChange(2, 80.0);   // Shake energy
shakers.controlChange(4, 50.0);   // System decay
shakers.controlChange(11, 20.0);  // Number of objects

// Render audio
final samples = shakers.render(44100);
```

### Drummer Example

```dart
import 'package:stk_min/stk_min.dart';
import 'package:stk_min/drummer.dart';

// Set path to STK rawwave files (required for Drummer)
setRawwavePath('/path/to/stk/rawwaves/');

final drummer = Drummer();

// Play a Bass Drum sound (MIDI 36)
drummer.noteOn(36.0, 0.9);

// Play a Snare Drum sound (MIDI 38)
drummer.noteOn(38.0, 0.82);

// Render audio
final samples = drummer.render(22050);
```

### ModalBar Example (African Percussion)

```dart
import 'package:stk_min/modal_bar.dart';

final modalBar = ModalBar();

// Initialize with Agogo preset (African drum sound)
modalBar.init(ModalBar.agogo);

// Play a high "slap" sound (880 Hz)
modalBar.noteOn(880.0, 0.8);

// Gain control (Stick hardness)
modalBar.controlChange(2, 80.0);

final samples = modalBar.render(44100);
```

### Control Change Parameters

The `controlChange(int number, double value)` method accepts the following parameters (values 0-128):

#### Flute Control Changes

| Parameter | Control # | Description |
| :--- | :--- | :--- |
| Vibrato Gain | 1 | Depth of pitch vibrato (0 = none, 128 = maximum) |
| Jet Delay | 2 | Tone color/brightness (lower = brighter, higher = darker) |
| Noise Gain | 4 | Breath noise amount (adds realism) |
| Vibrato Frequency | 11 | Speed of vibrato oscillation |
| Breath Pressure | 128 | Overall breath pressure envelope |

#### Saxophone Control Changes

| Parameter | Control # | Description |
|-----------|-----------|-------------|
| Vibrato Gain | 1 | Depth of pitch vibrato (0 = none, 128 = maximum) |
| Reed Stiffness | 2 | Reed flexibility (lower = softer, higher = stiffer) |
| Noise Gain | 4 | Breath noise amount (adds realism) |
| Vibrato Frequency | 11 | Speed of vibrato oscillation |
| Breath Pressure | 128 | Overall breath pressure envelope |

#### Shakers Control Changes

| Parameter | Control # | Description |
| :--- | :--- | :--- |
| Shake Energy | 2 | Intensity of the shake |
| System Decay | 4 | How fast the sound fades out |
| Number Of Objects | 11 | Number of shaking objects (e.g., beads in maraca) |
| Resonance Frequency| 1 | Main resonance of the instrument |
| Shake Energy | 128 | Overall volume/energy |

#### ModalBar Control Changes

| Parameter | Control # | Description |
|-----------|-----------|-------------|
| Stick Hardness | 2 | Hardness of the strike (0 = soft, 128 = hard) |
| Strike Position | 4 | Where the bar is struck (0 = edge, 128 = center) |
| Vibrato Gain | 1 | Depth of pitch vibrato |
| Vibrato Frequency | 11 | Speed of vibrato oscillation |
| Preset | 16 | Switch between instruments (Marimba, Vibraphone, Agogo, etc.) |



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
   use wget to download the STK library from the following link: https://github.com/thestk/stk  and add the necessary files to the src directory. For example Flute.h and Flute.cpp for flute support. If the instrument causes compilation errors then download additional files. A simpler way is to use wget -q https://raw.githubusercontent.com/thestk/stk/master/include/Flute.h to download the header files and wget -q https://raw.githubusercontent.com/thestk/stk/master/src/Flute.cpp to download the source files.



- Improving documentation
- Adding more examples
- Performance optimizations
- Bug fixes

## Issues

Please file issues on the [GitHub repository](https://github.com/shashankkhare/stk_min/issues).
