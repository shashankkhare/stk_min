# CHANGELOG

## 0.4.2

* **Drummer Frequency Fix**: Implemented explicit frequency-based triggering to resolve "vocal sample" glitch.
* **FFI Refinement**: Updated `noteOn` signature to allow direct Hz control for improved sample selectivity.

## 0.4.1

* **Drummer Stability**: Fixed FFI bridge mismatch that could cause runtime crashes.
* **Frequency Mapping**: Improved Drummer frequency logic to support real-time playback rate adjustment based on requested frequency.
* **Native Refactoring**: Cleaned up Drummer.cpp and StkMini.cpp for better sample index handling.

## 0.4.0

* **Universal Initialization**: Added `StkMin.initialize()` to automatically handle sample extraction and path configuration across all platforms.
* **Unified Assets**: Moved raw samples into the package assets (`assets/rawwaves/`) so they are bundled automatically when the package is installed.
* **Consistency**: Guaranteed identical behavior across Linux, Android, and iOS by using a unified storage mechanism for samples.
* **Dependencies**: Added `path_provider` and `path` to manage cross-platform filesystem locations.

## 0.3.1


* **SEO Optimization**: Updated package description with targeted keywords (physical modeling, percussion, FFI) to improve search discoverability on pub.dev.

## 0.3.0

* **Percussion Expansion**: Added `ModalBar` instrument with presets for **Agogo** (African percussion), Marimba, Vibraphone, and more.
* **Drummer Enhancements**:
  * Added `setPitch` support for real-time playback rate adjustment.
  * Fixed frequency mapping bug ("shouting" sample issue).
* **Native Stability**:
  * Implemented lazy initialization for all instruments to prevent startup crashes when STK rawwave paths are not yet set.
  * Improved memory management with pointer usage for native instruments.
* **Example App Update**: 
  * Comprehensive tabbed UI with 5 sections (Flute, Sax, Shakers, Drums, Percussion).
  * Added controls for pitch, stick hardness, and preset selection.
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
