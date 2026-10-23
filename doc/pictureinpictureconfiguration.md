## Picture in Picture configuration
Picture in Picture is not supported on all devices.

Requirements:
* iOS: iOS version greater than 14.0
* Android: Android version greater than 8.0, enough RAM, v2 Flutter android embedding

Each OS provides method to check if given device supports PiP. If device doesn't support PiP, then
error will be printed in console.

Check if PiP is supported in given device:
```dart
_betterPlayerController.isPictureInPictureSupported();
```

To show PiP mode call this method:

```dart
_betterPlayerController.enablePictureInPicture(_betterPlayerKey);
```
`_betterPlayerKey` is a key which is used in BetterPlayer widget:

```dart
GlobalKey _betterPlayerKey = GlobalKey();
...
    AspectRatio(
        aspectRatio: 16 / 9,
        child: BetterPlayer(
            controller: _betterPlayerController,
            key: _betterPlayerKey,
        ),
    ),
```

To hide PiP mode call this method:
```dart
betterPlayerController.disablePictureInPicture();
```

PiP menu item is enabled as default in both Material and Cuperino controls. You can disable it with
`BetterPlayerControlsConfiguration`'s variable: `enablePip`. You can change PiP control menu icon with
`pipMenuIcon` variable in `BetterPlayerControlsConfiguration`.

Warning:
Both Android and iOS PiP versions are in very early stage. There can be bugs and small issues. Please
make sure that you've checked state of the PiP in Better Player before moving it to the production.

Known limitations:
Android: When PiP is enabled, Better Player will open full screen mode to play video correctly. When
user disables PiP, Better Player will back to the previous settings and for a half of second your device
will have incorrect orientation.
### Automatic picture-in-picture on iOS
On iOS, a playing video moves into picture-in-picture on its own when the app goes to the
background. To only open picture-in-picture on an explicit `enablePictureInPicture` call, turn
automatic entry off, once, before creating the first player:
```dart
BetterPlayerController.setAutomaticPictureInPicture(false)
```
The window then takes a moment longer to open on request: the player keeps no picture-in-picture
controller in between, since iOS 26 opens the window for any controller on a playing video. On
Android the call does nothing.
