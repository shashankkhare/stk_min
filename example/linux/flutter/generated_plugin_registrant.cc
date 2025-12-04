//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <stk_min/stk_min_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) stk_min_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "StkMinPlugin");
  stk_min_plugin_register_with_registrar(stk_min_registrar);
}
