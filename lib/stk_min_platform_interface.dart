import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'stk_min_method_channel.dart';

abstract class StkMinPlatform extends PlatformInterface {
  /// Constructs a StkMinPlatform.
  StkMinPlatform() : super(token: _token);

  static final Object _token = Object();

  static StkMinPlatform _instance = MethodChannelStkMin();

  /// The default instance of [StkMinPlatform] to use.
  ///
  /// Defaults to [MethodChannelStkMin].
  static StkMinPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [StkMinPlatform] when
  /// they register themselves.
  static set instance(StkMinPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
