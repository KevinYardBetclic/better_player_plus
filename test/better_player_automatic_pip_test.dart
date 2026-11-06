import 'dart:async';

import 'package:better_player_plus/better_player_plus.dart';
import 'package:better_player_plus/src/video_player/video_player.dart';
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
      return call.method == 'create' ? <String, dynamic>{'textureId': 1} : null;
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

  group('one player', () {
    Map<dynamic, dynamic> createArguments() =>
        calls.singleWhere((MethodCall call) => call.method == 'create').arguments as Map<dynamic, dynamic>;

    test('a player configured without automatic entry is created without it', () async {
      final controller = BetterPlayerController(
        const BetterPlayerConfiguration(startsPictureInPictureAutomatically: false),
      );
      unawaited(controller.setupDataSource(BetterPlayerDataSource.network('https://example.com/video.mp4')));
      await pumpEventQueue();

      expect(createArguments()['startsPictureInPictureAutomatically'], false);
    });

    test('a player configured with nothing follows the plugin-wide setting', () async {
      final controller = BetterPlayerController(const BetterPlayerConfiguration());
      unawaited(controller.setupDataSource(BetterPlayerDataSource.network('https://example.com/video.mp4')));
      await pumpEventQueue();

      expect(createArguments().containsKey('startsPictureInPictureAutomatically'), isFalse);
    });

    test('turning automatic entry on for one player tells the platform which one', () async {
      final controller = BetterPlayerController(const BetterPlayerConfiguration());
      unawaited(controller.setupDataSource(BetterPlayerDataSource.network('https://example.com/video.mp4')));
      await pumpEventQueue();

      await controller.setStartsPictureInPictureAutomatically(true);

      expect(
        calls.singleWhere((MethodCall call) => call.method == 'setStartsPictureInPictureAutomatically').arguments,
        <String, dynamic>{'textureId': 1, 'enabled': true},
      );
    });

    test('a request made while the player is being created still reaches it', () async {
      final player = VideoPlayerController();

      final request = player.setStartsPictureInPictureAutomatically(true);
      await request;

      final methods = calls.map((MethodCall call) => call.method).toList();
      expect(methods.indexOf('setStartsPictureInPictureAutomatically'), greaterThan(methods.indexOf('create')));
    });
  });
}
