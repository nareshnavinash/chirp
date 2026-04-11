import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chirp/core/providers.dart';

/// Wraps the break screen with keyboard shortcuts.
///
/// - **Escape**: Skip break
/// - **S**: Skip break (consistency with home screen)
class BreakKeyboardShortcuts extends ConsumerWidget {
  final Widget child;

  const BreakKeyboardShortcuts({super.key, required this.child});

  static bool get _isDesktop =>
      Platform.isMacOS || Platform.isWindows || Platform.isLinux;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!_isDesktop) return child;

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): () {
          ref.read(timerServiceProvider).skipBreak();
        },
        const SingleActivator(LogicalKeyboardKey.keyS): () {
          ref.read(timerServiceProvider).skipBreak();
        },
      },
      child: Focus(
        autofocus: true,
        child: child,
      ),
    );
  }
}
