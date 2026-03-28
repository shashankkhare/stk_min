# CHANGELOG

## 0.3.1

* **SEO Optimization**: Updated package description with targeted keywords (physical modeling, percussion, FFI) to improve search discoverability on pub.dev.

## 0.3.0

* **Percussion Expansion**: Added `ModalBar` instrument with presets for **Agogo** (African percussion), Marimba, Vibraphone, and more.
* **Drummer Enhancements**:
  - Added `setPitch` support for real-time playback rate adjustment.
  - Fixed frequency mapping bug ("shouting" sample issue).
* **Native Stability**:
  - Implemented lazy initialization for all instruments to prevent startup crashes when STK rawwave paths are not yet set.
  - Improved memory management with pointer usage for native instruments.
* **Example App Update**: 
  - Comprehensive tabbed UI with 5 sections (Flute, Sax, Shakers, Drums, Percussion).
  - Added controls for pitch, stick hardness, and preset selection.
* **FFI Improvements**: Expanded native bridge and updated CMake configurations for all platforms.

## 0.2.0 (Skipped/Internal)

* Initial work on Drummer and Shakers support.

## 0.1.0

* Initial release
* Cross-platform support for Android, iOS, Linux, macOS, and Windows
* Flute instrument with physical modeling synthesis
* FFI-based direct access to STK library
* Expressive controls:
  * Vibrato depth and speed
  * Breath noise
  * Tone color (jet delay)
  * Breath pressure
* Complete example app with SoLoud audio playback integration
* Comprehensive documentation and usage examples
