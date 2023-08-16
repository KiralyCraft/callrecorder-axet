# Call Recorder - Axet

As of 16 Aug 2023, I am archiving this repository, as I no longer use Axet's Call Recorder, but moved to BCR instead. It is better suited for devices above Android 9, you can find it [here](https://github.com/chenxiaolong/BCR).

## Android 11 or newer? Try [this](https://github.com/di72nn/callrecorder-axet) version instead!

This is a module that fixes recording for both sides for [Axet's Call Recorder](https://gitlab.com/axet/android-call-recorder). It currently installs version 1.7.13 as a system app in /system/priv-app and inserts necessary permissions in /etc/permissions to allow CAPTURE_AUDIO_OUTPUT for the app.

It requires API greater or equal to 19 (Android KitKat) in order to make use of the priv-app folder.

The module installs the app normally then moves it to priv-app so it becomes **a system app.**

## How to use it

Just like you used the normal app, but it **works as expected** now.

## Links

Original source: https://gitlab.com/axet/android-call-recorder

## Future updates
 - Download the APK from a repo, such as F-Droid's, to prevent embedding it into the module.
## Changelog
#### v1.0
 - Initial release
