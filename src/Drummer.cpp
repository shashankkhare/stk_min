/***************************************************/
/*! \class Drummer
    \brief STK drum sample player class.

    This class implements a drum sampling
    synthesizer using FileWvIn objects and one-pole
    filters.  The drum rawwave files are sampled
    at 22050 Hz, but will be appropriately
    interpolated for other sample rates.  You can
    specify the maximum polyphony (maximum number
    of simultaneous voices) via a #define in the
    Drummer.h.

    by Perry R. Cook and Gary P. Scavone, 1995--2023.
*/
/***************************************************/

#include "Drummer.h"
#include <cmath>

namespace stk {

// Pure Frequency-to-Sample mapping removed in favor of explicit instrument indices.
				  
char waveNames[DRUM_NUMWAVES][16] =
  { 
    "dope.raw",
    "bassdrum.raw",
    "snardrum.raw",
    "tomlowdr.raw",
    "tommiddr.raw",
    "tomhidrm.raw",
    "hihatcym.raw",
    "ridecymb.raw",
    "crashcym.raw", 
    "cowbell1.raw", 
    "tambourn.raw",
    "tabla_na.raw",
    "tabla_din.raw",
    "tabla_tee.raw"
  };

Drummer :: Drummer( void ) : Instrmnt()
{
  // This counts the number of sounding voices.
  nSounding_ = 0;
  soundOrder_ = std::vector<int> (DRUM_POLYPHONY, -1);
  soundNumber_ = std::vector<int> (DRUM_POLYPHONY, -1);
  pitch_ = 1.0;
}

Drummer :: ~Drummer( void )
{
}

void Drummer :: noteOn( StkFloat frequency, StkFloat amplitude )
{
  // Satisfy interface by treating frequency as the instrument parameter
  // and using it as a direct Hz value for the 3-param version.
  this->noteOn( frequency, amplitude, frequency );
}

void Drummer :: noteOn( StkFloat instrument, StkFloat amplitude, StkFloat frequency )
{
  if ( amplitude < 0.0 || amplitude > 1.0 ) {
    oStream_ << "Drummer::noteOn: amplitude parameter is out of bounds!";
    handleError( StkError::WARNING ); return;
  }

  // Instrument is now a direct index into waveNames
  int sampleIndex = (int) instrument;
  if ( sampleIndex < 0 || sampleIndex >= DRUM_NUMWAVES ) sampleIndex = 1; // Default to Bass Drum

  // Find a voice
  int iWave;
  for ( iWave=0; iWave<DRUM_POLYPHONY; iWave++ ) {
    if ( soundNumber_[iWave] == sampleIndex ) {
      if ( waves_[iWave].isFinished() ) {
        soundOrder_[iWave] = nSounding_;
        nSounding_++;
      }
      waves_[iWave].reset();
      filters_[iWave].setPole( 0.999 - (amplitude * 0.6) );
      filters_[iWave].setGain( amplitude );
      break;
    }
  }

  if ( iWave == DRUM_POLYPHONY ) {
    if ( nSounding_ < DRUM_POLYPHONY ) {
      for ( iWave=0; iWave<DRUM_POLYPHONY; iWave++ )
        if ( soundOrder_[iWave] < 0 ) break;
      nSounding_ += 1;
    }
    else {
      for ( iWave=0; iWave<DRUM_POLYPHONY; iWave++ )
        if ( soundOrder_[iWave] == 0 ) break;
      for ( int j=0; j<DRUM_POLYPHONY; j++ ) {
        if ( soundOrder_[j] > soundOrder_[iWave] )
          soundOrder_[j] -= 1;
      }
    }
    soundOrder_[iWave] = nSounding_ - 1;
    soundNumber_[iWave] = sampleIndex;

    waves_[iWave].openFile( (Stk::rawwavePath() + waveNames[ sampleIndex ]).c_str(), true );
    filters_[iWave].setPole( 0.999 - (amplitude * 0.6) );
    filters_[iWave].setGain( amplitude );
  }

  // Set the playback rate based on requested frequency.
  // We assume the original samples are tuned roughly to their MIDI pitch 
  // (Kick=36/65.4Hz, Snare=38/73.4Hz, Hat=42/92.5Hz).
  StkFloat baseFreq = 65.41; // Default Base (Kick)
  if (sampleIndex == 2) baseFreq = 73.42; // Snare
  if (sampleIndex >= 6 && sampleIndex <= 10) baseFreq = 92.50; // Hi-hat and percussion range
  
  // Tabla Tuning: Sa for Dayan, Fraction for Bayan
  if (sampleIndex == 11) baseFreq = 261.63; // Tabla Na (Dayan) - C4
  if (sampleIndex == 12) baseFreq = 130.81; // Tabla Din (Bayan) - C3
  if (sampleIndex == 13) baseFreq = 261.63; // Tabla Tee (Dayan) - C4

  StkFloat rate = (frequency / baseFreq) * pitch_ * (22050.0 / Stk::sampleRate());
  waves_[iWave].setRate( rate );
}

void Drummer :: noteOff( StkFloat amplitude )
{
  // Set all sounding wave filter gains low.
  int i = 0;
  while ( i < nSounding_ ) filters_[i++].setGain( amplitude * 0.01 );
}

} // stk namespace
