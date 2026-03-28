cmake_minimum_required(VERSION 3.4.1)

add_library(stk_min SHARED
    ../src/Stk.cpp
    ../src/ADSR.cpp
    ../src/Flute.cpp
    ../src/Saxophone.cpp
    ../src/Shakers.cpp
    ../src/Drummer.cpp
    ../src/ModalBar.cpp
    ../src/Modal.cpp
    ../src/Envelope.cpp
    ../src/BiQuad.cpp
    ../src/FileLoop.cpp
    ../src/SineWave.cpp
    ../src/FileWvIn.cpp
    ../src/FileRead.cpp
    ../src/Noise.cpp
    ../src/DelayL.cpp
    ../src/OnePole.cpp
    ../src/PoleZero.cpp
    ../src/StkMini.cpp
)

target_include_directories(stk_min PRIVATE ../src)

find_library(log-lib log)

target_link_libraries(stk_min ${log-lib})
