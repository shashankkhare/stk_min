import 'package:flutter_test/flutter_test.dart';
import 'package:stk_min/stk_min.dart';
import 'package:stk_min/stk_min_platform_interface.dart';
import 'package:stk_min/stk_min_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockStkMinPlatform
    with MockPlatformInterfaceMixin
    implements StkMinPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final StkMinPlatform initialPlatform = StkMinPlatform.instance;

  test('$MethodChannelStkMin is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelStkMin>());
  });

  test('getPlatformVersion', () async {
    StkMin stkMinPlugin = StkMin();
    MockStkMinPlatform fakePlatform = MockStkMinPlatform();
    StkMinPlatform.instance = fakePlatform;

    expect(await stkMinPlugin.getPlatformVersion(), '42');
  });
}
