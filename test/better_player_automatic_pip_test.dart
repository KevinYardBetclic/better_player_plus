import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel = MethodChannel('better_player_channel');
  final List<MethodCall> calls = <MethodCall>[];

  Iterable<MethodCall> automaticPipCalls() =>
      calls.where((MethodCall call) => call.method == 'setAutomaticPictureInPicture');

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

  test('turning automatic picture-in-picture off tells the platform', () async {
    await BetterPlayerController.setAutomaticPictureInPicture(false);

    expect(automaticPipCalls().single.arguments, <String, dynamic>{'enabled': false});
  });

  test('turning automatic picture-in-picture back on tells the platform', () async {
    await BetterPlayerController.setAutomaticPictureInPicture(true);

    expect(automaticPipCalls().single.arguments, <String, dynamic>{'enabled': true});
  });

  test('a call the platform rejects reaches the caller instead of being swallowed', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
      MethodCall call,
    ) async {
      if (call.method == 'setAutomaticPictureInPicture') {
        throw PlatformException(code: 'INVALID_ARGUMENT');
      }
      return null;
    });

    await expectLater(
      BetterPlayerController.setAutomaticPictureInPicture(false),
      throwsA(isA<PlatformException>().having((PlatformException error) => error.code, 'code', 'INVALID_ARGUMENT')),
    );
  });
}
