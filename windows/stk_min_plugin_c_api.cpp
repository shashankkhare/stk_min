#include "include/stk_min/stk_min_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "stk_min_plugin.h"

void StkMinPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  stk_min::StkMinPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
