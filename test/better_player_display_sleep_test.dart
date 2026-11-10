import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel = MethodChannel('better_player_channel');
  final List<MethodCall> calls = <MethodCall>[];

  Iterable<MethodCall> displaySleepCalls() =>
      calls.where((MethodCall call) => call.method == 'setPreventsDisplaySleep');

  setUp(() {
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
      MethodCall call,
    ) async {
      calls.add(call);
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('letting the screen sleep during playback tells the platform', () async {
    await BetterPlayerController.setPreventsDisplaySleep(false);

    expect(displaySleepCalls().single.arguments, <String, dynamic>{'preventsDisplaySleep': false});
  });

  test('a call the platform rejects reaches the caller instead of being swallowed', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
      MethodCall call,
    ) async {
      if (call.method == 'setPreventsDisplaySleep') {
        throw PlatformException(code: 'INVALID_ARGUMENT');
      }
      return null;
    });

    await expectLater(
      BetterPlayerController.setPreventsDisplaySleep(false),
      throwsA(isA<PlatformException>().having((PlatformException error) => error.code, 'code', 'INVALID_ARGUMENT')),
    );
  });

  test('keeping the screen on during playback again tells the platform', () async {
    await BetterPlayerController.setPreventsDisplaySleep(true);

    expect(displaySleepCalls().single.arguments, <String, dynamic>{'preventsDisplaySleep': true});
  });
}
