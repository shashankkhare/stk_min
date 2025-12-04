#ifndef FLUTTER_PLUGIN_STK_MIN_PLUGIN_H_
#define FLUTTER_PLUGIN_STK_MIN_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace stk_min {

class StkMinPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  StkMinPlugin();

  virtual ~StkMinPlugin();

  // Disallow copy and assign.
  StkMinPlugin(const StkMinPlugin&) = delete;
  StkMinPlugin& operator=(const StkMinPlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace stk_min

#endif  // FLUTTER_PLUGIN_STK_MIN_PLUGIN_H_
