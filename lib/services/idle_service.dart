import 'dart:async';
import 'dart:io';

class IdleService {
  Timer? _pollTimer;

  int _idleThresholdSeconds = 180; // 3 minutes default
  bool _isIdle = false;

  bool get isIdle => _isIdle;

  void Function(bool isIdle)? onIdleChanged;

  void configure({required int idleThresholdSeconds}) {
    _idleThresholdSeconds = idleThresholdSeconds;
  }

  Future<void> start() async {
    await stop();
    // Poll every 30 seconds
    _pollTimer = Timer.periodic(const Duration(seconds: 30), (_) async {
      final idleSeconds = await _getSystemIdleSeconds();
      if (idleSeconds == null) return;

      final wasIdle = _isIdle;
      _isIdle = idleSeconds >= _idleThresholdSeconds;

      if (_isIdle != wasIdle) {
        onIdleChanged?.call(_isIdle);
      }
    });
  }

  Future<int?> _getSystemIdleSeconds() async {
    try {
      if (Platform.isMacOS) {
        return _getMacOSIdleSeconds();
      } else if (Platform.isLinux) {
        return _getLinuxIdleSeconds();
      } else if (Platform.isWindows) {
        // Windows idle detection would use GetLastInputInfo via ffi
        // For now, return null (not implemented)
        return null;
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  Future<int?> _getMacOSIdleSeconds() async {
    // ioreg gives HIDIdleTime in nanoseconds
    final result = await Process.run('ioreg', [
      '-c', 'IOHIDSystem',
      '-d', '4',
    ]);
    if (result.exitCode != 0) return null;

    final output = result.stdout as String;
    final match = RegExp(r'"HIDIdleTime"\s*=\s*(\d+)').firstMatch(output);
    if (match == null) return null;

    final nanoseconds = int.tryParse(match.group(1)!);
    if (nanoseconds == null) return null;

    return nanoseconds ~/ 1000000000; // Convert to seconds
  }

  Future<int?> _getLinuxIdleSeconds() async {
    // xprintidle gives idle time in milliseconds
    final result = await Process.run('xprintidle', []);
    if (result.exitCode != 0) return null;

    final ms = int.tryParse((result.stdout as String).trim());
    if (ms == null) return null;

    return ms ~/ 1000;
  }

  Future<void> stop() async {
    _pollTimer?.cancel();
    _pollTimer = null;
    _isIdle = false;
  }

  void dispose() {
    stop();
  }
}
