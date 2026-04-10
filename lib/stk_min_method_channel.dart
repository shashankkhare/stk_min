import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'stk_min_platform_interface.dart';

/// An implementation of [StkMinPlatform] that uses method channels.
class MethodChannelStkMin extends StkMinPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('stk_min');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
