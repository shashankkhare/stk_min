#include "Flute.h"
#include <vector>

#if defined(_WIN32)
  #define EXPORT __declspec(dllexport)
#else
  #define EXPORT __attribute__((visibility("default")))
#endif

extern "C" {

static stk::Flute flute(44100);

EXPORT void stk_init(double freq) {
    flute.setFrequency(freq);
}

EXPORT void stk_noteOn(double freq, double amp) {
    flute.noteOn(freq, amp);
}

EXPORT void stk_controlChange(int number, double value) {
    flute.controlChange(number, value);
}

EXPORT float* stk_render(int frames) {
    static std::vector<float> buffer;
    buffer.resize(frames);
    for (int i = 0; i < frames; i++)
        buffer[i] = flute.tick();
    return buffer.data();
}

}
