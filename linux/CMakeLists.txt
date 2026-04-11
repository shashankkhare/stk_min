cmake_minimum_required(VERSION 3.10)
project(stk_min_plugin LANGUAGES CXX)

find_package(PkgConfig REQUIRED)
pkg_check_modules(GTK REQUIRED gtk+-3.0)

add_library(stk_min_plugin SHARED
  "stk_min_plugin.cc"
  "../src/Stk.cpp"
  "../src/ADSR.cpp"
  "../src/Flute.cpp"
  "../src/Saxophone.cpp"
  "../src/Shakers.cpp"
  "../src/Drummer.cpp"
  "../src/ModalBar.cpp"
  "../src/Modal.cpp"
  "../src/Envelope.cpp"
  "../src/BiQuad.cpp"
  "../src/FileLoop.cpp"
  "../src/SineWave.cpp"
  "../src/FileWvIn.cpp"
  "../src/FileRead.cpp"
  "../src/Noise.cpp"
  "../src/DelayL.cpp"
  "../src/SineWave.cpp"
  "../src/OnePole.cpp"
  "../src/PoleZero.cpp"
  "../src/StkMini.cpp"
)

apply_standard_settings(stk_min_plugin)

target_include_directories(stk_min_plugin PRIVATE
  "../src"
  "include"
  ${GTK_INCLUDE_DIRS}
  "${FLUTTER_MANAGED_DIR}/ephemeral"
)

target_compile_definitions(stk_min_plugin PRIVATE FLUTTER_PLUGIN_IMPL __LINUX_ALSA__ __LITTLE_ENDIAN__)

target_link_libraries(stk_min_plugin PRIVATE flutter ${GTK_LIBRARIES})
target_include_directories(stk_min_plugin INTERFACE
  "${CMAKE_CURRENT_SOURCE_DIR}/include")
