/***************************************************/
/*! \class Saxophone
    \brief STK saxophone physical model class.

    This class implements a simplified saxophone
    physical model, as discussed by Scavone (1997).

    Control Change Numbers:
       - Reed Stiffness = 2
       - Noise Gain = 4
       - Vibrato Frequency = 11
       - Vibrato Gain = 1
       - Breath Pressure = 128

    by Perry R. Cook and Gary P. Scavone, 1996--2023.
*/
/***************************************************/

#include "Saxophone.h"
#include "SKINImsg.h"

namespace stk {

Saxophone :: Saxophone( StkFloat lowestFrequency )
{
  if ( lowestFrequency <= 0.0 ) {
    oStream_ << "Saxophone::Saxophone: argument is less than or equal to zero!";
    handleError( StkError::FUNCTION_ARGUMENT );
  }

  unsigned long nDelays = (unsigned long) ( Stk::sampleRate() / lowestFrequency );
  boreDelay_.setMaximumDelay( nDelays + 1 );

  vibrato_.setFrequency( 5.925 );
  filter_.setPole( 0.7 - ( 0.1 * 22050.0 / Stk::sampleRate() ) );
  dcBlock_.setBlockZero();

  adsr_.setAllTimes( 0.005, 0.01, 0.8, 0.010 );
  reedStiffness_ = 0.5;
  noiseGain_     = 0.1;    // Breath pressure random component
  vibratoGain_   = 0.05;   // Breath periodic vibrato component

  maxPressure_ = 0.0;
  this->clear();
  this->setFrequency( 220.0 );
}

Saxophone :: ~Saxophone( void )
{
}

void Saxophone :: clear( void )
{
  boreDelay_.clear();
  filter_.clear();
  dcBlock_.clear();
}

void Saxophone :: setFrequency( StkFloat frequency )
{
#if defined(_STK_DEBUG_)
  if ( frequency <= 0.0 ) {
    oStream_ << "Saxophone::setFrequency: argument is less than or equal to zero!";
    handleError( StkError::WARNING ); return;
  }
#endif

  lastFrequency_ = frequency;

  // Account for filter delay and one sample "lastOut" delay
  StkFloat delay = Stk::sampleRate() / lastFrequency_ - filter_.phaseDelay( lastFrequency_ ) - 1.0;

  boreDelay_.setDelay( delay );
}

void Saxophone :: startBlowing( StkFloat amplitude, StkFloat rate )
{
  if ( amplitude <= 0.0 || rate <= 0.0 ) {
    oStream_ << "Saxophone::startBlowing: one or more arguments is less than or equal to zero!";
    handleError( StkError::WARNING ); return;
  }

  adsr_.setAttackRate( rate );
  maxPressure_ = amplitude / (StkFloat) 0.8;
  adsr_.keyOn();
}

void Saxophone :: stopBlowing( StkFloat rate )
{
  if ( rate < 0.0 ) {
    oStream_ << "Saxophone::stopBlowing: argument is less than zero!";
    handleError( StkError::WARNING ); return;
  }

  adsr_.setReleaseRate( rate );
  adsr_.keyOff();
}

void Saxophone :: noteOn( StkFloat frequency, StkFloat amplitude )
{
  this->setFrequency( frequency );
  this->startBlowing( 1.1 + (amplitude * 0.20), amplitude * 0.02 );
  outputGain_ = amplitude + 0.001;
}

void Saxophone :: noteOff( StkFloat amplitude )
{
  this->stopBlowing( amplitude * 0.02 );
}


void Saxophone :: controlChange( int number, StkFloat value )
{
#if defined(_STK_DEBUG_)
  if ( Stk::inRange( value, 0.0, 128.0 ) == false ) {
    oStream_ << "Saxophone::controlChange: value (" << value << ") is out of range!";
    handleError( StkError::WARNING ); return;
  }
#endif

  StkFloat normalizedValue = value * ONE_OVER_128;
  if (number == __SK_JetDelay_) // 2
    this->setReedStiffness( (StkFloat) (0.1 + (0.8 * normalizedValue)) );
  else if (number == __SK_NoiseLevel_) // 4
    noiseGain_ = ( normalizedValue * 0.4);
  else if (number == __SK_ModFrequency_) // 11
    vibrato_.setFrequency( normalizedValue * 12.0);
  else if (number == __SK_ModWheel_) // 1
    vibratoGain_ = ( normalizedValue * 0.4 );
  else if (number == __SK_AfterTouch_Cont_) // 128
    adsr_.setTarget( normalizedValue );
#if defined(_STK_DEBUG_)
  else {
    oStream_ << "Saxophone::controlChange: undefined control number (" << number << ")!";
    handleError( StkError::WARNING );
  }
#endif
}

} // stk namespace
