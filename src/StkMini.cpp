#include "Flute.h"
#include "Saxophone.h"
#include "Shakers.h"
#include "Drummer.h"
#include "ModalBar.h"
#include <vector>

#if defined(_WIN32)
  #define EXPORT __declspec(dllexport)
#else
  #define EXPORT __attribute__((visibility("default")))
#endif

extern "C" {

static stk::Flute* flute = nullptr;
static stk::Saxophone* saxophone = nullptr;
static stk::Shakers* shakers = nullptr;
static stk::Drummer* drummer = nullptr;
static stk::ModalBar* modalBar = nullptr;

EXPORT void stk_setRawwavePath(const char* path) {
    stk::Stk::setRawwavePath(path);
}

// Flute functions
EXPORT void stk_init(double freq) {
    if (!flute) flute = new stk::Flute(44100);
    flute->setFrequency(freq);
}

EXPORT void stk_noteOn(double freq, double amp) {
    if (flute) flute->noteOn(freq, amp);
}

EXPORT void stk_controlChange(int number, double value) {
    if (flute) flute->controlChange(number, value);
}

EXPORT float* stk_render(int frames) {
    static std::vector<float> buffer;
    buffer.resize(frames);
    if (flute) {
        for (int i = 0; i < frames; i++)
            buffer[i] = flute->tick();
    } else {
        std::fill(buffer.begin(), buffer.end(), 0.0f);
    }
    return buffer.data();
}

// Saxophone functions
EXPORT void sax_init(double freq) {
    if (!saxophone) saxophone = new stk::Saxophone(44100);
    saxophone->setFrequency(freq);
}

EXPORT void sax_noteOn(double freq, double amp) {
    if (saxophone) saxophone->noteOn(freq, amp);
}

EXPORT void sax_controlChange(int number, double value) {
    if (saxophone) saxophone->controlChange(number, value);
}

EXPORT float* sax_render(int frames) {
    static std::vector<float> buffer;
    buffer.resize(frames);
    if (saxophone) {
        for (int i = 0; i < frames; i++)
            buffer[i] = saxophone->tick();
    } else {
        std::fill(buffer.begin(), buffer.end(), 0.0f);
    }
    return buffer.data();
}

// Shakers functions
EXPORT void shakers_init(int type) {
    if (!shakers) shakers = new stk::Shakers(type);
    else {
        shakers->noteOff(0.0);
        shakers->noteOn((double)type, 0.0);
    }
}

EXPORT void shakers_noteOn(double instrument, double amp) {
    if (shakers) shakers->noteOn(instrument, amp);
}

EXPORT void shakers_controlChange(int number, double value) {
    if (shakers) shakers->controlChange(number, value);
}

EXPORT float* shakers_render(int frames) {
    static std::vector<float> buffer;
    buffer.resize(frames);
    if (shakers) {
        for (int i = 0; i < frames; i++)
            buffer[i] = shakers->tick();
    } else {
        std::fill(buffer.begin(), buffer.end(), 0.0f);
    }
    return buffer.data();
}

// Drummer functions
EXPORT void drummer_noteOn(double instrument, double amp, double frequency) {
    if (!drummer) drummer = new stk::Drummer();
    drummer->noteOn(instrument, amp, frequency);
}

EXPORT void drummer_noteOff(double amp) {
    if (drummer) drummer->noteOff(amp);
}

EXPORT void drummer_setPitch(double pitch) {
    if (drummer) drummer->setPitch(pitch);
}

EXPORT float* drummer_render(int frames) {
    static std::vector<float> buffer;
    buffer.resize(frames);
    if (drummer) {
        for (int i = 0; i < frames; i++)
            buffer[i] = drummer->tick();
    } else {
        std::fill(buffer.begin(), buffer.end(), 0.0f);
    }
    return buffer.data();
}

// ModalBar functions
EXPORT void modalbar_init(int preset) {
    if (!modalBar) modalBar = new stk::ModalBar();
    modalBar->setPreset(preset);
}

EXPORT void modalbar_noteOn(double freq, double amp) {
    if (!modalBar) modalBar = new stk::ModalBar();
    modalBar->noteOn(freq, amp);
}

EXPORT void modalbar_controlChange(int number, double value) {
    if (modalBar) modalBar->controlChange(number, value);
}

EXPORT float* modalbar_render(int frames) {
    static std::vector<float> buffer;
    buffer.resize(frames);
    if (modalBar) {
        for (int i = 0; i < frames; i++)
            buffer[i] = modalBar->tick();
    } else {
        std::fill(buffer.begin(), buffer.end(), 0.0f);
    }
    return buffer.data();
}

}
