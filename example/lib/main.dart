import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:stk_min/stk_min.dart';
import 'package:stk_min/saxophone.dart';
import 'package:stk_min/shakers.dart';
import 'package:stk_min/drummer.dart';
import 'dart:math';
import 'package:flutter_soloud/flutter_soloud.dart';

void main() {
  runApp(const StkDemoApp());
}

class StkDemoApp extends StatelessWidget {
  const StkDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const StkDemoHome(),
    );
  }
}

class StkDemoHome extends StatefulWidget {
  const StkDemoHome({super.key});

  @override
  State<StkDemoHome> createState() => _StkDemoHomeState();
}

class _StkDemoHomeState extends State<StkDemoHome> {
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
      // Set rawwave path for Drummer
      setRawwavePath('/home/shashankkhare/AndroidStudioProjects/stk_min/rawwaves/');
      setState(() => _audioInitialized = true);
    } catch (e) {
      debugPrint('Failed to initialize audio: $e');
    }
  }

  @override
  void dispose() {
    _soloud?.deinit();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("STK Min Demo"),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.music_note), text: "Flute"),
              Tab(icon: Icon(Icons.music_video), text: "Sax"),
              Tab(icon: Icon(Icons.celebration), text: "Shakers"),
              Tab(icon: Icon(Icons.album), text: "Drums"),
              Tab(icon: Icon(Icons.blur_circular), text: "Percussion"),
            ],
          ),
        ),
        body: !_audioInitialized
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  InstrumentSection(
                    name: "Flute",
                    instrument: Flute(),
                    controls: const [
                      ControlInfo(name: "Vibrato Depth", number: 1, min: 0, max: 128, initial: 20),
                      ControlInfo(name: "Vibrato Speed", number: 11, min: 0, max: 128, initial: 60),
                      ControlInfo(name: "Breath Noise", number: 4, min: 0, max: 128, initial: 20),
                      ControlInfo(name: "Tone Color", number: 2, min: 0, max: 128, initial: 60),
                    ],
                  ),
                  InstrumentSection(
                    name: "Saxophone",
                    instrument: Saxophone(),
                    controls: const [
                      ControlInfo(name: "Vibrato Depth", number: 1, min: 0, max: 128, initial: 30),
                      ControlInfo(name: "Vibrato Speed", number: 11, min: 0, max: 128, initial: 50),
                      ControlInfo(name: "Reed Stiffness", number: 2, min: 0, max: 128, initial: 40),
                      ControlInfo(name: "Breath Noise", number: 4, min: 0, max: 128, initial: 15),
                    ],
                  ),
                  ShakersSection(soloud: _soloud!),
                  DrummerSection(soloud: _soloud!),
                  ModalBarSection(soloud: _soloud!),
                ],
              ),
      ),
    );
  }
}

class ControlInfo {
  final String name;
  final int number;
  final double min;
  final double max;
  final double initial;

  const ControlInfo({
    required this.name,
    required this.number,
    required this.min,
    required this.max,
    required this.initial,
  });
}

class InstrumentSection extends StatefulWidget {
  final String name;
  final dynamic instrument;
  final List<ControlInfo> controls;

  const InstrumentSection({
    super.key,
    required this.name,
    required this.instrument,
    required this.controls,
  });

  @override
  State<InstrumentSection> createState() => _InstrumentSectionState();
}

class _InstrumentSectionState extends State<InstrumentSection> {
  final Map<int, double> _values = {};
  double _frequency = 440.0;
  double _pressure = 0.8;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    for (var control in widget.controls) {
      _values[control.number] = control.initial;
    }
  }

  Future<void> _play() async {
    if (_isPlaying) return;
    setState(() => _isPlaying = true);

    try {
      widget.instrument.init(_frequency);
      _values.forEach((num, val) {
        widget.instrument.controlChange(num, val);
      });
      widget.instrument.noteOn(_frequency, _pressure);

      final samples = widget.instrument.render(44100);
      final wavData = createWavFile(samples, 44100);
      
      final source = await SoLoud.instance.loadMem('${widget.name}_note', wavData);
      await SoLoud.instance.play(source);
      await Future.delayed(const Duration(seconds: 1));
      await SoLoud.instance.disposeSource(source);
    } catch (e) {
      debugPrint('Error: $e');
    }

    setState(() => _isPlaying = false);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text("Frequency: ${_frequency.toInt()} Hz"),
          Slider(
            value: _frequency,
            min: 100,
            max: 1000,
            onChanged: (v) => setState(() => _frequency = v),
          ),
          Text("Pressure: ${_pressure.toStringAsFixed(2)}"),
          Slider(
            value: _pressure,
            min: 0,
            max: 1,
            onChanged: (v) => setState(() => _pressure = v),
          ),
          const Divider(),
          ...widget.controls.map((c) => Column(
            children: [
              Text(c.name),
              Slider(
                value: _values[c.number]!,
                min: c.min,
                max: c.max,
                onChanged: (v) => setState(() => _values[c.number] = v),
              ),
            ],
          )),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _isPlaying ? null : _play,
            child: Text(_isPlaying ? "Playing..." : "Play Note"),
          ),
        ],
      ),
    );
  }
}

class ShakersSection extends StatefulWidget {
  final SoLoud soloud;
  const ShakersSection({super.key, required this.soloud});

  @override
  State<ShakersSection> createState() => _ShakersSectionState();
}

class _ShakersSectionState extends State<ShakersSection> {
  final shakers = Shakers();
  int _selectedType = Shakers.maraca;
  double _energy = 80.0;
  bool _isPlaying = false;

  void _play() async {
    if (_isPlaying) return;
    setState(() => _isPlaying = true);

    try {
      shakers.init(_selectedType);
      shakers.controlChange(2, _energy);
      // Pass a reasonable frequency for shakers (MIDI 69 = 440Hz)
      shakers.noteOn(440.0, 0.8);

      final samples = shakers.render(22050);
      final wavData = createWavFile(samples, 44100);
      
      final source = await widget.soloud.loadMem('shaker', wavData);
      await widget.soloud.play(source);
      await Future.delayed(const Duration(milliseconds: 500));
      await widget.soloud.disposeSource(source);
    } catch (e) {
      debugPrint('Error: $e');
    }

    setState(() => _isPlaying = false);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          DropdownButton<int>(
            value: _selectedType,
            isExpanded: true,
            items: const [
              DropdownMenuItem(value: Shakers.maraca, child: Text("Maraca")),
              DropdownMenuItem(value: Shakers.tambourine, child: Text("Tambourine")),
              DropdownMenuItem(value: Shakers.sleighBells, child: Text("Sleigh Bells")),
              DropdownMenuItem(value: Shakers.bambooChimes, child: Text("Bamboo Chimes")),
              DropdownMenuItem(value: Shakers.waterDrops, child: Text("Water Drops")),
            ],
            onChanged: (v) => setState(() => _selectedType = v!),
          ),
          const SizedBox(height: 20),
          const Text("Shake Energy"),
          Slider(
            value: _energy,
            min: 0,
            max: 128,
            onChanged: (v) => setState(() => _energy = v),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _isPlaying ? null : _play,
            child: const Text("Shake!"),
          ),
        ],
      ),
    );
  }
}

class DrummerSection extends StatefulWidget {
  final SoLoud soloud;
  const DrummerSection({super.key, required this.soloud});

  @override
  State<DrummerSection> createState() => _DrummerSectionState();
}

class _DrummerSectionState extends State<DrummerSection> {
  final drummer = Drummer();
  double _pitch = 1.0;
  bool _isPlaying = false;

  void _playDrum(double note) async {
    if (_isPlaying) return;
    setState(() => _isPlaying = true);

    try {
      drummer.setPitch(_pitch);
      // Convert MIDI note to frequency for STK Drummer
      final freq = midiToFreq(note);
      drummer.noteOn(freq, 0.9);
      final samples = drummer.render(22050);
      final wavData = createWavFile(samples, 44100);
      
      final source = await widget.soloud.loadMem('drum', wavData);
      await widget.soloud.play(source);
      await Future.delayed(const Duration(milliseconds: 500));
      await widget.soloud.disposeSource(source);
    } catch (e) {
      debugPrint('Error: $e');
    }

    setState(() => _isPlaying = false);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text("Drum Pitch: ${_pitch.toStringAsFixed(2)}"),
          Slider(
            value: _pitch,
            min: 0.25,
            max: 4.0,
            onChanged: (v) => setState(() => _pitch = v),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              ElevatedButton(onPressed: () => _playDrum(36), child: const Text("Bass Drum")),
              ElevatedButton(onPressed: () => _playDrum(38), child: const Text("Snare")),
              ElevatedButton(onPressed: () => _playDrum(42), child: const Text("Closed Hi-Hat")),
              ElevatedButton(onPressed: () => _playDrum(46), child: const Text("Open Hi-Hat")),
              ElevatedButton(onPressed: () => _playDrum(50), child: const Text("High Tom")),
              ElevatedButton(onPressed: () => _playDrum(56), child: const Text("Cowbell")),
              const SizedBox(width: double.infinity),
              ElevatedButton(
                onPressed: () => _playDrum(24), 
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade100),
                child: const Text("Secret 'Dope' Shouting"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Convert MIDI note to frequency
double midiToFreq(double midi) {
  return 440.0 * pow(2.0, (midi - 69.0) / 12.0);
}

/// Helper to create WAV file
Uint8List createWavFile(List<double> samples, int sampleRate) {
  final numSamples = samples.length;
  final dataSize = numSamples * 2;
  final buffer = ByteData(44 + dataSize);
  
  // RIFF header
  buffer.setUint32(0, 0x52494646, Endian.big); // "RIFF"
  buffer.setUint32(4, 36 + dataSize, Endian.little);
  buffer.setUint32(8, 0x57415645, Endian.big); // "WAVE"
  
  // fmt chunk
  buffer.setUint32(12, 0x666D7420, Endian.big); // "fmt "
  buffer.setUint32(16, 16, Endian.little);
  buffer.setUint16(20, 1, Endian.little);
  buffer.setUint16(22, 1, Endian.little);
  buffer.setUint32(24, sampleRate, Endian.little);
  buffer.setUint32(28, sampleRate * 2, Endian.little);
  buffer.setUint16(32, 2, Endian.little);
  buffer.setUint16(34, 16, Endian.little);
  
  // data chunk
  buffer.setUint32(36, 0x64617461, Endian.big);
  buffer.setUint32(40, dataSize, Endian.little);
  
  var offset = 44;
  for (var sample in samples) {
    final intSample = (sample * 32767).clamp(-32768, 32767).toInt();
    buffer.setInt16(offset, intSample, Endian.little);
    offset += 2;
  }
  
  return buffer.buffer.asUint8List();
}

class ModalBarSection extends StatefulWidget {
  final SoLoud soloud;
  const ModalBarSection({super.key, required this.soloud});

  @override
  State<ModalBarSection> createState() => _ModalBarSectionState();
}

class _ModalBarSectionState extends State<ModalBarSection> {
  final modalBar = ModalBar();
  int _preset = ModalBar.agogo;
  double _frequency = 440.0;
  bool _isPlaying = false;

  void _play() async {
    if (_isPlaying) return;
    setState(() => _isPlaying = true);

    try {
      modalBar.init(_preset);
      modalBar.noteOn(_frequency, 0.8);

      final samples = modalBar.render(22050);
      final wavData = createWavFile(samples, 44100);
      
      final source = await widget.soloud.loadMem('modalbar_note', wavData);
      await widget.soloud.play(source);
      await Future.delayed(const Duration(seconds: 1));
      await widget.soloud.disposeSource(source);
    } catch (e) {
      debugPrint('Error: $e');
    }

    setState(() => _isPlaying = false);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          DropdownButton<int>(
            value: _preset,
            items: const [
              DropdownMenuItem(value: ModalBar.marimba, child: Text("Marimba")),
              DropdownMenuItem(value: ModalBar.vibraphone, child: Text("Vibraphone")),
              DropdownMenuItem(value: ModalBar.agogo, child: Text("Agogo (African)")),
              DropdownMenuItem(value: ModalBar.wood1, child: Text("Wood Block 1")),
              DropdownMenuItem(value: ModalBar.wood2, child: Text("Wood Block 2")),
              DropdownMenuItem(value: ModalBar.beats, child: Text("Beats")),
              DropdownMenuItem(value: ModalBar.clump, child: Text("Clump")),
            ],
            onChanged: (v) => setState(() => _preset = v!),
          ),
          const SizedBox(height: 10),
          Text("Frequency: ${_frequency.toInt()} Hz"),
          Slider(
            value: _frequency,
            min: 100,
            max: 2000,
            onChanged: (v) => setState(() => _frequency = v),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _play,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(200, 60),
              backgroundColor: Colors.orange,
            ),
            child: const Text("Strike!", style: TextStyle(fontSize: 20, color: Colors.white)),
          ),
          const SizedBox(height: 20),
          const Text(
            "Agogo is a classic African percussion instrument. Use higher frequencies for 'slap' sounds and lower for 'bass' tones.",
            textAlign: TextAlign.center,
            style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
