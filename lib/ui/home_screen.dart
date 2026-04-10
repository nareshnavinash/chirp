import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:blink/core/app_constants.dart';
import 'package:blink/core/providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final appStatus = ref.watch(appStatusProvider);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.remove_red_eye, size: 32, color: Colors.blue),
                const SizedBox(width: 12),
                Text(
                  AppConstants.appName,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Chip(
                  label: Text(
                    appStatus == AppStatus.running ? 'Active' : 'Paused',
                  ),
                  backgroundColor:
                      appStatus == AppStatus.running
                          ? Colors.green.shade100
                          : Colors.orange.shade100,
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Status card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Next break in',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${settings.workMinutes}:00',
                      style: Theme.of(
                        context,
                      ).textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.w300,
                        fontFeatures: [const FontFeature.tabularFigures()],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        FilledButton.icon(
                          onPressed: () {
                            ref.read(appStatusProvider.notifier).toggle();
                          },
                          icon: Icon(
                            appStatus == AppStatus.running
                                ? Icons.pause
                                : Icons.play_arrow,
                          ),
                          label: Text(
                            appStatus == AppStatus.running
                                ? 'Pause'
                                : 'Resume',
                          ),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: () {
                            // Will trigger break in Phase 2
                          },
                          icon: const Icon(Icons.skip_next),
                          label: const Text('Start Break Now'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Quick settings
            Text(
              'Quick Settings',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            _SettingsTile(
              title: 'Break Reminders',
              subtitle:
                  'Every ${settings.workMinutes} min, ${settings.breakSeconds}s break',
              value: settings.breaksEnabled,
              onChanged: (value) {
                ref.read(settingsProvider.notifier).update(
                  (s) => s.copyWith(breaksEnabled: value),
                );
              },
            ),
            _SettingsTile(
              title: 'Blink Reminders',
              subtitle: 'Gentle reminder to blink',
              value: settings.blinkRemindersEnabled,
              onChanged: (value) {
                ref.read(settingsProvider.notifier).update(
                  (s) => s.copyWith(blinkRemindersEnabled: value),
                );
              },
            ),
            _SettingsTile(
              title: 'Posture Reminders',
              subtitle: 'Check your posture periodically',
              value: settings.postureRemindersEnabled,
              onChanged: (value) {
                ref.read(settingsProvider.notifier).update(
                  (s) => s.copyWith(postureRemindersEnabled: value),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
    );
  }
}
