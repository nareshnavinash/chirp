import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chirp/core/providers.dart';
import 'package:chirp/services/timer_service.dart';

/// Wraps a widget with desktop keyboard shortcuts for the home screen.
///
/// - **Space**: Toggle pause / resume
/// - **B**: Start break now
/// - **S**: Skip break (only when on break)
///
/// On mobile platforms, returns the child unchanged.
class KeyboardShortcutWrapper extends ConsumerWidget {
  final Widget child;

  const KeyboardShortcutWrapper({super.key, required this.child});

  static bool get _isDesktop =>
      Platform.isMacOS || Platform.isWindows || Platform.isLinux;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!_isDesktop) return child;

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.space): () {
          ref.read(appStatusProvider.notifier).toggle();
        },
        const SingleActivator(LogicalKeyboardKey.keyB): () {
          ref.read(timerServiceProvider).startBreakNow();
        },
        const SingleActivator(LogicalKeyboardKey.keyS): () {
          final timerAsync = ref.read(timerStatusProvider);
          timerAsync.whenData((status) {
            if (status.state == TimerState.onBreak) {
              ref.read(timerServiceProvider).skipBreak();
            }
          });
        },
      },
      child: Focus(
        autofocus: true,
        child: child,
      ),
    );
  }
}
