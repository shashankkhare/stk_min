import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:stk_min/stk_min.dart';
import 'package:flutter_soloud/flutter_soloud.dart';

void main() {
  runApp(const FluteDemo());
}

class FluteDemo extends StatefulWidget {
  const FluteDemo({super.key});

  @override
  State<FluteDemo> createState() => _FluteDemoState();
}

class _FluteDemoState extends State<FluteDemo> {
  double _frequency = 440.0;
  double _pressure = 0.8;
  double _vibratoGain = 20.0;      // Control #1 (0-128)
  double _vibratoFreq = 60.0;      // Control #11 (0-128)
  double _noiseGain = 20.0;        // Control #4 (0-128)
  double _jetDelay = 60.0;         // Control #2 (0-128)
  bool _isPlaying = false;
  
  final plugin = Flute();
  SoLoud? _soloud;
  bool _audioInitialized = false;

  @override
  void initState() {
    super.initState();
    _initAudio();
  }

  Future<void> _initAudio() async {
    try {
      _soloud = SoLoud.instance;
      await _soloud!.init();
      setState(() => _audioInitialized = true);
    } catch (e) {
      debugPrint('Failed to initialize audio: $e');
    }
  }

  /// Create a WAV file from PCM float samples
  Uint8List _createWavFile(List<double> samples, int sampleRate) {
    final numSamples = samples.length;
    final numChannels = 1;
    final bitsPerSample = 16;
    final byteRate = sampleRate * numChannels * bitsPerSample ~/ 8;
    final blockAlign = numChannels * bitsPerSample ~/ 8;
    final dataSize = numSamples * numChannels * bitsPerSample ~/ 8;
    
    final buffer = ByteData(44 + dataSize);
    var offset = 0;
    
    // RIFF header
    buffer.setUint8(offset++, 0x52); // 'R'
    buffer.setUint8(offset++, 0x49); // 'I'
    buffer.setUint8(offset++, 0x46); // 'F'
    buffer.setUint8(offset++, 0x46); // 'F'
    buffer.setUint32(offset, 36 + dataSize, Endian.little); offset += 4;
    buffer.setUint8(offset++, 0x57); // 'W'
    buffer.setUint8(offset++, 0x41); // 'A'
    buffer.setUint8(offset++, 0x56); // 'V'
    buffer.setUint8(offset++, 0x45); // 'E'
    
    // fmt chunk
    buffer.setUint8(offset++, 0x66); // 'f'
    buffer.setUint8(offset++, 0x6D); // 'm'
    buffer.setUint8(offset++, 0x74); // 't'
    buffer.setUint8(offset++, 0x20); // ' '
    buffer.setUint32(offset, 16, Endian.little); offset += 4; // fmt chunk size
    buffer.setUint16(offset, 1, Endian.little); offset += 2; // audio format (PCM)
    buffer.setUint16(offset, numChannels, Endian.little); offset += 2;
    buffer.setUint32(offset, sampleRate, Endian.little); offset += 4;
    buffer.setUint32(offset, byteRate, Endian.little); offset += 4;
    buffer.setUint16(offset, blockAlign, Endian.little); offset += 2;
    buffer.setUint16(offset, bitsPerSample, Endian.little); offset += 2;
    
    // data chunk
    buffer.setUint8(offset++, 0x64); // 'd'
    buffer.setUint8(offset++, 0x61); // 'a'
    buffer.setUint8(offset++, 0x74); // 't'
    buffer.setUint8(offset++, 0x61); // 'a'
    buffer.setUint32(offset, dataSize, Endian.little); offset += 4;
    
    // PCM data (convert float to 16-bit int)
    for (var sample in samples) {
      final intSample = (sample * 32767).clamp(-32768, 32767).toInt();
      buffer.setInt16(offset, intSample, Endian.little);
      offset += 2;
    }
    
    return buffer.buffer.asUint8List();
  }

  Future<void> _playSingleNote() async {
    if (_isPlaying || !_audioInitialized) return;

    setState(() => _isPlaying = true);

    try {
      // Initialize and trigger the note
      plugin.init(_frequency);
      
      // Apply control changes for realistic sound
      plugin.controlChange(1, _vibratoGain);   // Vibrato gain
      plugin.controlChange(11, _vibratoFreq);  // Vibrato frequency
      plugin.controlChange(4, _noiseGain);     // Noise gain (breath noise)
      plugin.controlChange(2, _jetDelay);      // Jet delay
      
      plugin.noteOn(_frequency, _pressure);

      // Generate audio samples (1 second at 44100 Hz)
      const sampleRate = 44100;
      const duration = 1;
      final samples = plugin.render(sampleRate * duration);
      
      // Create WAV file from samples
      final wavData = _createWavFile(samples, sampleRate);
      
      // Load and play
      final source = await _soloud!.loadMem('flute_note', wavData);
      await _soloud!.play(source);
      
      // Wait for playback to finish
      await Future.delayed(Duration(seconds: duration));
      
      // Dispose the source
      await _soloud!.disposeSource(source);
    } catch (e) {
      debugPrint('Error playing note: $e');
    }

    setState(() => _isPlaying = false);
  }

  Future<void> _playMelody() async {
    if (_isPlaying || !_audioInitialized) return;
    setState(() => _isPlaying = true);

    List<double> notes = [440, 494, 523, 587, 659, 698, 784, 880];
    const sampleRate = 44100;
    const noteDuration = 0.4;
    final samplesPerNote = (sampleRate * noteDuration).toInt();

    try {
      for (var freq in notes) {
        plugin.init(freq);
        
        // Apply control changes
        plugin.controlChange(1, _vibratoGain);
        plugin.controlChange(11, _vibratoFreq);
        plugin.controlChange(4, _noiseGain);
        plugin.controlChange(2, _jetDelay);
        
        plugin.noteOn(freq, _pressure);
        
        final samples = plugin.render(samplesPerNote);
        final wavData = _createWavFile(samples, sampleRate);
        
        final source = await _soloud!.loadMem('flute_melody', wavData);
        await _soloud!.play(source);
        
        await Future.delayed(Duration(milliseconds: (noteDuration * 1000).toInt()));
        
        await _soloud!.disposeSource(source);
      }
    } catch (e) {
      debugPrint('Error playing melody: $e');
    }

    setState(() => _isPlaying = false);
  }

  @override
  void dispose() {
    _soloud?.deinit();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: const Text("Flute Plugin Test")),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              if (!_audioInitialized)
                const Padding(
                  padding: EdgeInsets.only(bottom: 20),
                  child: Text(
                    "Initializing audio...",
                    style: TextStyle(color: Colors.orange),
                  ),
                ),
              
              // Frequency Control
              const Text("Frequency (Hz)", style: TextStyle(fontWeight: FontWeight.bold)),
              Slider(
                value: _frequency,
                min: 100,
                max: 1000,
                divisions: 180,
                label: _frequency.toStringAsFixed(0),
                onChanged: (v) => setState(() => _frequency = v),
              ),

              const SizedBox(height: 10),
              
              // Breath Pressure
              const Text("Breath Pressure", style: TextStyle(fontWeight: FontWeight.bold)),
              Slider(
                value: _pressure,
                min: 0.1,
                max: 1.0,
                label: _pressure.toStringAsFixed(2),
                onChanged: (v) => setState(() => _pressure = v),
              ),

              const Divider(height: 30),
              const Text("Expressive Controls", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),

              // Vibrato Gain
              const Text("Vibrato Depth", style: TextStyle(fontWeight: FontWeight.bold)),
              Slider(
                value: _vibratoGain,
                min: 0,
                max: 128,
                divisions: 128,
                label: _vibratoGain.toStringAsFixed(0),
                onChanged: (v) => setState(() => _vibratoGain = v),
              ),

              const SizedBox(height: 10),

              // Vibrato Frequency
              const Text("Vibrato Speed", style: TextStyle(fontWeight: FontWeight.bold)),
              Slider(
                value: _vibratoFreq,
                min: 0,
                max: 128,
                divisions: 128,
                label: _vibratoFreq.toStringAsFixed(0),
                onChanged: (v) => setState(() => _vibratoFreq = v),
              ),

              const SizedBox(height: 10),

              // Noise Gain
              const Text("Breath Noise", style: TextStyle(fontWeight: FontWeight.bold)),
              Slider(
                value: _noiseGain,
                min: 0,
                max: 128,
                divisions: 128,
                label: _noiseGain.toStringAsFixed(0),
                onChanged: (v) => setState(() => _noiseGain = v),
              ),

              const SizedBox(height: 10),

              // Jet Delay
              const Text("Tone Color (Jet Delay)", style: TextStyle(fontWeight: FontWeight.bold)),
              Slider(
                value: _jetDelay,
                min: 0,
                max: 128,
                divisions: 128,
                label: _jetDelay.toStringAsFixed(0),
                onChanged: (v) => setState(() => _jetDelay = v),
              ),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: _audioInitialized && !_isPlaying ? _playSingleNote : null,
                child: const Text("▶ Play Single Note"),
              ),

              const SizedBox(height: 15),

              ElevatedButton(
                onPressed: _audioInitialized && !_isPlaying ? _playMelody : null,
                child: const Text("🎶 Play Melody"),
              ),

              if (_isPlaying) const Padding(
                padding: EdgeInsets.only(top: 20),
                child: Text(
                  "Playing...",
                  style: TextStyle(fontSize: 18, color: Colors.green),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
