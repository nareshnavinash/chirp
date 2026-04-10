import 'dart:io';

enum SoundEvent {
  preBreak,
  breakStart,
  breakEnd,
  blinkReminder,
  postureReminder,
}

class SoundService {
  bool _enabled = true;
  final Map<SoundEvent, String?> _soundMap = {};

  void configure({required bool enabled}) {
    _enabled = enabled;
  }

  void setSoundForEvent(SoundEvent event, String? path) {
    _soundMap[event] = path;
  }

  Future<void> play(SoundEvent event) async {
    if (!_enabled) return;

    // Use system sound on macOS as default
    if (Platform.isMacOS) {
      await _playMacOSSound(event);
    }
    // Linux and Windows would use different approaches
  }

  Future<void> _playMacOSSound(SoundEvent event) async {
    final customPath = _soundMap[event];
    if (customPath != null) {
      await Process.run('afplay', [customPath]);
      return;
    }

    // Use built-in macOS sounds
    final systemSound = switch (event) {
      SoundEvent.preBreak => '/System/Library/Sounds/Glass.aiff',
      SoundEvent.breakStart => '/System/Library/Sounds/Purr.aiff',
      SoundEvent.breakEnd => '/System/Library/Sounds/Blow.aiff',
      SoundEvent.blinkReminder => '/System/Library/Sounds/Tink.aiff',
      SoundEvent.postureReminder => '/System/Library/Sounds/Pop.aiff',
    };

    await Process.run('afplay', [systemSound]);
  }
}
