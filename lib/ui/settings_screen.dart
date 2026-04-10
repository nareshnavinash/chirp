import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:blink/core/app_constants.dart';
import 'package:blink/core/providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'General'),
              Tab(text: 'Breaks'),
              Tab(text: 'Reminders'),
              Tab(text: 'Schedule'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _GeneralTab(),
            _BreaksTab(),
            _RemindersTab(),
            _ScheduleTab(),
          ],
        ),
      ),
    );
  }
}

// ── General Tab ─────────────────────────────────────────────────

class _GeneralTab extends ConsumerWidget {
  const _GeneralTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SectionHeader('Startup'),
        SwitchListTile(
          title: const Text('Launch at startup'),
          subtitle: const Text('Start Blink when you log in'),
          value: settings.autoStart,
          onChanged: (v) => ref.read(settingsProvider.notifier).update(
            (s) => s.copyWith(autoStart: v),
          ),
        ),
        SwitchListTile(
          title: const Text('Start minimized'),
          subtitle: const Text('Hide window on launch, show tray icon only'),
          value: settings.startMinimized,
          onChanged: (v) => ref.read(settingsProvider.notifier).update(
            (s) => s.copyWith(startMinimized: v),
          ),
        ),
        const Divider(),
        _SectionHeader('Idle Detection'),
        ListTile(
          title: const Text('Idle threshold'),
          subtitle: Text('Pause after ${settings.idleThresholdMinutes} minutes of inactivity'),
          trailing: SizedBox(
            width: 140,
            child: Slider(
              value: settings.idleThresholdMinutes.toDouble(),
              min: 1,
              max: 15,
              divisions: 14,
              label: '${settings.idleThresholdMinutes} min',
              onChanged: (v) => ref.read(settingsProvider.notifier).update(
                (s) => s.copyWith(idleThresholdMinutes: v.round()),
              ),
            ),
          ),
        ),
        const Divider(),
        _SectionHeader('About'),
        ListTile(
          title: const Text(AppConstants.appName),
          subtitle: Text('Version ${AppConstants.appVersion}'),
          leading: const Icon(Icons.remove_red_eye),
        ),
      ],
    );
  }
}

// ── Breaks Tab ──────────────────────────────────────────────────

class _BreaksTab extends ConsumerWidget {
  const _BreaksTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SwitchListTile(
          title: const Text('Break reminders'),
          subtitle: const Text('Enable periodic break reminders'),
          value: settings.breaksEnabled,
          onChanged: (v) => ref.read(settingsProvider.notifier).update(
            (s) => s.copyWith(breaksEnabled: v),
          ),
        ),
        const Divider(),
        _SectionHeader('Short Breaks'),
        _SliderTile(
          title: 'Work interval',
          value: settings.workMinutes.toDouble(),
          min: 5,
          max: 120,
          divisions: 23,
          format: (v) => '${v.round()} min',
          onChanged: settings.breaksEnabled
              ? (v) => ref.read(settingsProvider.notifier).update(
                    (s) => s.copyWith(workMinutes: v.round()),
                  )
              : null,
        ),
        _SliderTile(
          title: 'Break duration',
          value: settings.breakSeconds.toDouble(),
          min: 10,
          max: 120,
          divisions: 22,
          format: (v) => '${v.round()}s',
          onChanged: settings.breaksEnabled
              ? (v) => ref.read(settingsProvider.notifier).update(
                    (s) => s.copyWith(breakSeconds: v.round()),
                  )
              : null,
        ),
        const Divider(),
        _SectionHeader('Long Breaks'),
        _SliderTile(
          title: 'Long break every',
          value: settings.longBreakInterval.toDouble(),
          min: 2,
          max: 8,
          divisions: 6,
          format: (v) => '${v.round()} breaks',
          onChanged: settings.breaksEnabled
              ? (v) => ref.read(settingsProvider.notifier).update(
                    (s) => s.copyWith(longBreakInterval: v.round()),
                  )
              : null,
        ),
        _SliderTile(
          title: 'Long break duration',
          value: settings.longBreakMinutes.toDouble(),
          min: 1,
          max: 15,
          divisions: 14,
          format: (v) => '${v.round()} min',
          onChanged: settings.breaksEnabled
              ? (v) => ref.read(settingsProvider.notifier).update(
                    (s) => s.copyWith(longBreakMinutes: v.round()),
                  )
              : null,
        ),
        const Divider(),
        _SectionHeader('Discipline'),
        _SliderTile(
          title: 'Max postpones per day',
          value: settings.maxPostponesPerDay.toDouble(),
          min: 0,
          max: 20,
          divisions: 20,
          format: (v) => '${v.round()}',
          onChanged: settings.breaksEnabled
              ? (v) => ref.read(settingsProvider.notifier).update(
                    (s) => s.copyWith(maxPostponesPerDay: v.round()),
                  )
              : null,
        ),
      ],
    );
  }
}

// ── Reminders Tab ───────────────────────────────────────────────

class _RemindersTab extends ConsumerWidget {
  const _RemindersTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SectionHeader('Blink Reminders'),
        SwitchListTile(
          title: const Text('Enable blink reminders'),
          subtitle: const Text('Gentle nudge to blink periodically'),
          value: settings.blinkRemindersEnabled,
          onChanged: (v) {
            ref.read(settingsProvider.notifier).update(
              (s) => s.copyWith(blinkRemindersEnabled: v),
            );
            ref.read(reminderServiceProvider).updateBlinkEnabled(v);
          },
        ),
        _SliderTile(
          title: 'Blink interval',
          value: settings.blinkIntervalMinutes.toDouble(),
          min: 3,
          max: 30,
          divisions: 27,
          format: (v) => '${v.round()} min',
          onChanged: settings.blinkRemindersEnabled
              ? (v) => ref.read(settingsProvider.notifier).update(
                    (s) => s.copyWith(blinkIntervalMinutes: v.round()),
                  )
              : null,
        ),
        const Divider(),
        _SectionHeader('Posture Reminders'),
        SwitchListTile(
          title: const Text('Enable posture reminders'),
          subtitle: const Text('Periodic posture check notifications'),
          value: settings.postureRemindersEnabled,
          onChanged: (v) {
            ref.read(settingsProvider.notifier).update(
              (s) => s.copyWith(postureRemindersEnabled: v),
            );
            ref.read(reminderServiceProvider).updatePostureEnabled(v);
          },
        ),
        _SliderTile(
          title: 'Posture interval',
          value: settings.postureIntervalMinutes.toDouble(),
          min: 10,
          max: 60,
          divisions: 10,
          format: (v) => '${v.round()} min',
          onChanged: settings.postureRemindersEnabled
              ? (v) => ref.read(settingsProvider.notifier).update(
                    (s) => s.copyWith(postureIntervalMinutes: v.round()),
                  )
              : null,
        ),
      ],
    );
  }
}

// ── Schedule Tab ────────────────────────────────────────────────

class _ScheduleTab extends ConsumerWidget {
  const _ScheduleTab();

  static const _dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SwitchListTile(
          title: const Text('Office hours'),
          subtitle: const Text('Only remind during work hours'),
          value: settings.scheduleEnabled,
          onChanged: (v) => ref.read(settingsProvider.notifier).update(
            (s) => s.copyWith(scheduleEnabled: v),
          ),
        ),
        const Divider(),
        _SectionHeader('Active Days'),
        Wrap(
          spacing: 8,
          children: List.generate(7, (index) {
            final day = index + 1;
            final isActive = settings.activeDays.contains(day);
            return FilterChip(
              label: Text(_dayLabels[index]),
              selected: isActive,
              onSelected: settings.scheduleEnabled
                  ? (selected) {
                      final days = List<int>.from(settings.activeDays);
                      if (selected) {
                        days.add(day);
                      } else {
                        days.remove(day);
                      }
                      days.sort();
                      ref.read(settingsProvider.notifier).update(
                        (s) => s.copyWith(activeDays: days),
                      );
                    }
                  : null,
            );
          }),
        ),
        const SizedBox(height: 16),
        const Divider(),
        _SectionHeader('Active Hours'),
        _TimePickerTile(
          title: 'Start time',
          hour: settings.scheduleStartHour,
          minute: settings.scheduleStartMinute,
          enabled: settings.scheduleEnabled,
          onChanged: (hour, minute) =>
              ref.read(settingsProvider.notifier).update(
                (s) => s.copyWith(
                  scheduleStartHour: hour,
                  scheduleStartMinute: minute,
                ),
              ),
        ),
        _TimePickerTile(
          title: 'End time',
          hour: settings.scheduleEndHour,
          minute: settings.scheduleEndMinute,
          enabled: settings.scheduleEnabled,
          onChanged: (hour, minute) =>
              ref.read(settingsProvider.notifier).update(
                (s) => s.copyWith(
                  scheduleEndHour: hour,
                  scheduleEndMinute: minute,
                ),
              ),
        ),
      ],
    );
  }
}

// ── Shared Widgets ──────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SliderTile extends StatelessWidget {
  final String title;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String Function(double) format;
  final ValueChanged<double>? onChanged;

  const _SliderTile({
    required this.title,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.format,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: Slider(
        value: value.clamp(min, max),
        min: min,
        max: max,
        divisions: divisions,
        label: format(value),
        onChanged: onChanged,
      ),
      trailing: SizedBox(
        width: 60,
        child: Text(
          format(value),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.end,
        ),
      ),
    );
  }
}

class _TimePickerTile extends StatelessWidget {
  final String title;
  final int hour;
  final int minute;
  final bool enabled;
  final void Function(int hour, int minute) onChanged;

  const _TimePickerTile({
    required this.title,
    required this.hour,
    required this.minute,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final time = TimeOfDay(hour: hour, minute: minute);
    return ListTile(
      title: Text(title),
      trailing: TextButton(
        onPressed: enabled
            ? () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: time,
                );
                if (picked != null) {
                  onChanged(picked.hour, picked.minute);
                }
              }
            : null,
        child: Text(time.format(context)),
      ),
    );
  }
}
