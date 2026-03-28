#ifndef STK_SAXOPHONE_H
#define STK_SAXOPHONE_H

#include "Instrmnt.h"
#include "DelayL.h"
#include "OnePole.h"
#include "PoleZero.h"
#include "Noise.h"
#include "ADSR.h"
#include "SineWave.h"

namespace stk {

/***************************************************/
/*! \class Saxophone
    \brief STK saxophone physical model class.

    This class implements a simplified saxophone
    physical model, as discussed by Scavone (1997).

    This is a digital waveguide model, making its
    use possibly subject to patents held by Stanford
    University, Yamaha, and others.

    Control Change Numbers:
       - Reed Stiffness = 2
       - Noise Gain = 4
       - Vibrato Frequency = 11
       - Vibrato Gain = 1
       - Breath Pressure = 128

    by Perry R. Cook and Gary P. Scavone, 1996--2023.
*/
/***************************************************/

class Saxophone : public Instrmnt
{
 public:
  //! Class constructor, taking the lowest desired playing frequency.
  /*!
    An StkError will be thrown if the rawwave path is incorrectly set.
  */
  Saxophone( StkFloat lowestFrequency );

  //! Class destructor.
  ~Saxophone( void );

  //! Reset and clear all internal state.
  void clear( void );

  //! Set instrument parameters for a particular frequency.
  void setFrequency( StkFloat frequency );

  //! Set the stiffness of the reed (0.0 - 1.0).
  void setReedStiffness( StkFloat stiffness ) { reedStiffness_ = stiffness; };

  //! Apply breath velocity to instrument with given amplitude and rate of increase.
  void startBlowing( StkFloat amplitude, StkFloat rate );

  //! Decrease breath velocity with given rate of decrease.
  void stopBlowing( StkFloat rate );

  //! Start a note with the given frequency and amplitude.
  void noteOn( StkFloat frequency, StkFloat amplitude );

  //! Stop a note with the given amplitude (speed of decay).
  void noteOff( StkFloat amplitude );

  //! Perform the control change specified by \e number and \e value (0.0 - 128.0).
  void controlChange( int number, StkFloat value );

  //! Compute and return one output sample.
  StkFloat tick( unsigned int channel = 0 );

  //! Fill a channel of the StkFrames object with computed outputs.
  /*!
    The \c channel argument must be less than the number of
    channels in the StkFrames argument (the first channel is specified
    by 0).  However, range checking is only performed if _STK_DEBUG_
    is defined during compilation, in which case an out-of-range value
    will trigger an StkError exception.
  */
  StkFrames& tick( StkFrames& frames, unsigned int channel = 0 );

 protected:

  DelayL   boreDelay_;
  OnePole  filter_;
  PoleZero dcBlock_;
  Noise    noise_;
  ADSR     adsr_;
  SineWave vibrato_;

  StkFloat lastFrequency_;
  StkFloat maxPressure_;
  StkFloat reedStiffness_;
  StkFloat noiseGain_;
  StkFloat vibratoGain_;
  StkFloat outputGain_;

};

inline StkFloat Saxophone :: tick( unsigned int )
{
  StkFloat pressureDiff;
  StkFloat breathPressure;
  StkFloat tempPressure;

  // Calculate the breath pressure (envelope + noise + vibrato)
  breathPressure = maxPressure_ * adsr_.tick();
  breathPressure += breathPressure * ( noiseGain_ * noise_.tick() + vibratoGain_ * vibrato_.tick() );

  // Reed model: the reed opening is nonlinearly related to pressure difference
  tempPressure = -filter_.tick( boreDelay_.lastOut() );
  pressureDiff = breathPressure - (reedStiffness_ * tempPressure);
  
  // Simple reed nonlinearity
  if ( pressureDiff > 1.0 ) pressureDiff = 1.0;
  if ( pressureDiff < -1.0 ) pressureDiff = -1.0;
  
  lastFrame_[0] = (StkFloat) 0.3 * boreDelay_.tick( pressureDiff );
  lastFrame_[0] = dcBlock_.tick( lastFrame_[0] );

  lastFrame_[0] *= outputGain_;
  return lastFrame_[0];
}

inline StkFrames& Saxophone :: tick( StkFrames& frames, unsigned int channel )
{
  unsigned int nChannels = lastFrame_.channels();
#if defined(_STK_DEBUG_)
  if ( channel > frames.channels() - nChannels ) {
    oStream_ << "Saxophone::tick(): channel and StkFrames arguments are incompatible!";
    handleError( StkError::FUNCTION_ARGUMENT );
  }
#endif

  StkFloat *samples = &frames[channel];
  unsigned int j, hop = frames.channels() - nChannels;
  if ( nChannels == 1 ) {
    for ( unsigned int i=0; i<frames.frames(); i++, samples += hop )
      *samples++ = tick();
  }
  else {
    for ( unsigned int i=0; i<frames.frames(); i++, samples += hop ) {
      *samples++ = tick();
      for ( j=1; j<nChannels; j++ )
        *samples++ = lastFrame_[j];
    }
  }

  return frames;
}

} // stk namespace

#endif
