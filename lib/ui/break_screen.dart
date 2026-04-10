import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:blink/core/providers.dart';
import 'package:blink/services/timer_service.dart';

class BreakScreen extends ConsumerWidget {
  const BreakScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerAsync = ref.watch(timerStatusProvider);

    return Scaffold(
      backgroundColor: Colors.black87,
      body: Center(
        child: timerAsync.when(
          data: (status) => _BreakContent(status: status, ref: ref),
          loading: () => const CircularProgressIndicator(color: Colors.white),
          error: (e, st) => const Text(
            'Something went wrong',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class _BreakContent extends StatelessWidget {
  final TimerStatus status;
  final WidgetRef ref;

  const _BreakContent({required this.status, required this.ref});

  String get _breakMessage {
    if (status.nextBreakType == BreakType.long) {
      return 'Stand up and stretch.\nGrab some water.';
    }
    return 'Look at something 20 feet away\nfor 20 seconds.';
  }

  String get _breakTitle {
    return status.nextBreakType == BreakType.long
        ? 'Long Break'
        : 'Eye Break';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Eye icon
        Icon(
          status.nextBreakType == BreakType.long
              ? Icons.self_improvement
              : Icons.visibility,
          size: 64,
          color: Colors.white70,
        ),
        const SizedBox(height: 24),

        // Title
        Text(
          _breakTitle,
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w300,
          ),
        ),
        const SizedBox(height: 16),

        // Message
        Text(
          _breakMessage,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white60,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 48),

        // Circular countdown
        SizedBox(
          width: 160,
          height: 160,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 160,
                height: 160,
                child: CircularProgressIndicator(
                  value: status.progress,
                  strokeWidth: 4,
                  backgroundColor: Colors.white12,
                  color: Colors.white70,
                ),
              ),
              Text(
                status.remainingFormatted,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w200,
                  fontFeatures: [const FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 48),

        // Skip button
        TextButton(
          onPressed: () {
            ref.read(timerServiceProvider).skipBreak();
          },
          style: TextButton.styleFrom(
            foregroundColor: Colors.white38,
          ),
          child: const Text('Skip break'),
        ),
      ],
    );
  }
}
