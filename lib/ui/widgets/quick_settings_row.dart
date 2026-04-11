import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chirp/core/providers.dart';

/// Compact row of 3 filter chips for quick toggle of breaks, blink, and posture.
class QuickSettingsRow extends ConsumerWidget {
  const QuickSettingsRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FilterChip(
          avatar: const Icon(Icons.timer_outlined, size: 16),
          label: const Text('Breaks'),
          selected: settings.breaksEnabled,
          onSelected: (value) {
            ref.read(settingsProvider.notifier).update(
              (s) => s.copyWith(breaksEnabled: value),
            );
            if (value) {
              ref.read(timerServiceProvider).startWorkSession();
            } else {
              ref.read(timerServiceProvider).pause();
            }
          },
        ),
        const SizedBox(width: 8),
        FilterChip(
          avatar: const Icon(Icons.visibility_outlined, size: 16),
          label: const Text('Blink'),
          selected: settings.blinkRemindersEnabled,
          onSelected: (value) {
            ref.read(settingsProvider.notifier).update(
              (s) => s.copyWith(blinkRemindersEnabled: value),
            );
            ref.read(reminderServiceProvider).updateBlinkEnabled(value);
          },
        ),
        const SizedBox(width: 8),
        FilterChip(
          avatar: const Icon(Icons.accessibility_new, size: 16),
          label: const Text('Posture'),
          selected: settings.postureRemindersEnabled,
          onSelected: (value) {
            ref.read(settingsProvider.notifier).update(
              (s) => s.copyWith(postureRemindersEnabled: value),
            );
            ref.read(reminderServiceProvider).updatePostureEnabled(value);
          },
        ),
      ],
    );
  }
}
