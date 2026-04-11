import 'dart:async';
import 'dart:io' show exit;
import 'dart:ui' show Brightness;
import 'package:flutter/scheduler.dart';
import 'package:system_tray/system_tray.dart';
import 'package:window_manager/window_manager.dart';
import 'package:chirp/services/timer_service.dart';
import 'package:chirp/services/pomodoro_service.dart';

class TrayService {
  final SystemTray _systemTray = SystemTray();
  bool _isPaused = false;
  StreamSubscription<TimerStatus>? _timerSubscription;

  // Service references for status queries
  TimerService? _timerService;
  PomodoroService? _pomodoroService;

  bool get isPaused => _isPaused;

  Future<void> init() async {
    await _systemTray.initSystemTray(
      title: '',
      iconPath: _getTrayIconPath(),
      toolTip: 'Chirp - Starting...',
    );

    // Build initial menu
    await _buildMenu();

    // Both left-click and right-click open the dropdown menu
    _systemTray.registerSystemTrayEventHandler((eventName) {
      if (eventName == kSystemTrayEventClick ||
          eventName == kSystemTrayEventRightClick) {
        _rebuildAndShowMenu();
      }
    });

    _listenForAppearanceChanges();
  }

  void listenToTimer(TimerService timerService) {
    _timerService = timerService;
    _timerSubscription?.cancel();
    _timerSubscription = timerService.statusStream.listen((status) {
      _updateTooltipFromStatus(status);
    });
  }

  void listenToPomodoro(PomodoroService pomodoroService) {
    _pomodoroService = pomodoroService;
  }

  Future<void> _rebuildAndShowMenu() async {
    await _buildMenu();
    _systemTray.popUpContextMenu();
  }

  void _listenForAppearanceChanges() {
    SchedulerBinding.instance.platformDispatcher.onPlatformBrightnessChanged =
        () {
      _systemTray.setSystemTrayInfo(iconPath: _getTrayIconPath());
    };
  }

  String _getTrayIconPath() {
    final brightness =
        SchedulerBinding.instance.platformDispatcher.platformBrightness;
    return brightness == Brightness.dark
        ? 'assets/icons/tray_icon_dark.png'
        : 'assets/icons/tray_icon.png';
  }

  void _updateTooltipFromStatus(TimerStatus status) {
    String tooltip;
    switch (status.state) {
      case TimerState.working:
        tooltip = 'Chirp - Next break in ${status.remainingFormatted}';
      case TimerState.preBreak:
        tooltip = 'Chirp - Break starting in ${status.remainingFormatted}';
      case TimerState.onBreak:
        final type =
            status.nextBreakType == BreakType.long ? 'Long break' : 'Break';
        tooltip = 'Chirp - $type ${status.remainingFormatted}';
      case TimerState.paused:
        tooltip = 'Chirp - Paused';
      case TimerState.idle:
        tooltip = 'Chirp - Idle';
    }
    _systemTray.setToolTip(tooltip);
  }

  Future<void> _buildMenu() async {
    final menu = Menu();
    final items = <MenuItemBase>[];

    // ── Section 1: Break Timer Status ────────────────────────────
    final timerStatus = _timerService?.currentStatus;
    if (timerStatus != null) {
      final statusText = switch (timerStatus.state) {
        TimerState.working =>
          'Next break in ${timerStatus.remainingFormatted}',
        TimerState.preBreak =>
          'Break starting in ${timerStatus.remainingFormatted}',
        TimerState.onBreak => timerStatus.nextBreakType == BreakType.long
            ? 'Long break \u2013 ${timerStatus.remainingFormatted}'
            : 'Eye break \u2013 ${timerStatus.remainingFormatted}',
        TimerState.paused => 'Timer paused',
        TimerState.idle => 'Timer idle',
      };
      items.add(MenuItemLabel(label: statusText, enabled: false));
    }

    items.add(MenuSeparator());

    // ── Section 2: Break Timer Actions ───────────────────────────
    if (timerStatus != null && timerStatus.state == TimerState.onBreak) {
      items.add(MenuItemLabel(
        label: 'Skip Break',
        onClicked: (menuItem) => _onSkipBreak?.call(),
      ));
    } else {
      items.add(MenuItemLabel(
        label: 'Start Break Now',
        onClicked: (menuItem) => _onStartBreakNow?.call(),
      ));
    }

    if (_isPaused ||
        (timerStatus != null &&
            (timerStatus.state == TimerState.paused ||
                timerStatus.state == TimerState.idle))) {
      items.add(MenuItemLabel(
        label: 'Resume',
        onClicked: (menuItem) async {
          _isPaused = false;
          _onPauseToggle?.call(false);
        },
      ));
    } else {
      items.add(MenuItemLabel(
        label: 'Pause',
        onClicked: (menuItem) async {
          _isPaused = true;
          _onPauseToggle?.call(true);
        },
      ));
    }

    if (timerStatus != null &&
        timerStatus.state == TimerState.preBreak &&
        timerStatus.canPostpone) {
      items.add(MenuItemLabel(
        label:
            'Postpone (+5 min) \u00b7 ${timerStatus.postponesRemaining} left',
        onClicked: (menuItem) => _onPostpone?.call(5),
      ));
    }

    // ── Section 3: Pomodoro ──────────────────────────────────────
    final pomoStatus = _pomodoroService?.currentStatus;
    if (pomoStatus != null) {
      items.add(MenuSeparator());

      if (pomoStatus.state == PomodoroState.idle) {
        items.add(MenuItemLabel(
          label: 'Start Pomodoro',
          onClicked: (menuItem) => _onPomodoroStart?.call(),
        ));
      } else {
        // Show pomodoro status info line
        final pomoText =
            'Pomodoro: ${pomoStatus.stateLabel} ${pomoStatus.remainingFormatted}';
        items.add(MenuItemLabel(label: pomoText, enabled: false));

        // Contextual pomodoro actions
        if (pomoStatus.state == PomodoroState.shortBreak ||
            pomoStatus.state == PomodoroState.longBreak) {
          items.add(MenuItemLabel(
            label: 'Skip Pomodoro Break',
            onClicked: (menuItem) => _onPomodoroSkipBreak?.call(),
          ));
        }

        if (pomoStatus.state == PomodoroState.paused) {
          items.add(MenuItemLabel(
            label: 'Resume Pomodoro',
            onClicked: (menuItem) => _onPomodoroTogglePause?.call(),
          ));
        } else {
          items.add(MenuItemLabel(
            label: 'Pause Pomodoro',
            onClicked: (menuItem) => _onPomodoroTogglePause?.call(),
          ));
        }
      }
    }

    // ── Section 4: Navigation ────────────────────────────────────
    items.add(MenuSeparator());
    items.add(MenuItemLabel(
      label: 'Open Chirp',
      onClicked: (menuItem) => _onOpenApp?.call(),
    ));
    items.add(MenuItemLabel(
      label: 'Settings...',
      onClicked: (menuItem) => _onOpenSettings?.call(),
    ));
    items.add(MenuItemLabel(
      label: 'View Stats...',
      onClicked: (menuItem) => _onOpenStats?.call(),
    ));

    // ── Section 5: Quit ──────────────────────────────────────────
    items.add(MenuSeparator());
    items.add(MenuItemLabel(
      label: 'Quit Chirp',
      onClicked: (menuItem) async {
        await _systemTray.destroy();
        await windowManager.setPreventClose(false);
        await windowManager.destroy();
        exit(0);
      },
    ));

    await menu.buildFrom(items);
    await _systemTray.setContextMenu(menu);
  }

  // ── Callbacks ────────────────────────────────────────────────────

  void Function(bool isPaused)? _onPauseToggle;
  void Function()? _onStartBreakNow;
  void Function()? _onSkipBreak;
  void Function(int minutes)? _onPostpone;
  void Function()? _onOpenApp;
  void Function()? _onOpenSettings;
  void Function()? _onOpenStats;
  void Function()? _onPomodoroStart;
  void Function()? _onPomodoroTogglePause;
  void Function()? _onPomodoroSkipBreak;

  void setOnPauseToggle(void Function(bool isPaused) callback) {
    _onPauseToggle = callback;
  }

  void setOnStartBreakNow(void Function() callback) {
    _onStartBreakNow = callback;
  }

  void setOnSkipBreak(void Function() callback) {
    _onSkipBreak = callback;
  }

  void setOnPostpone(void Function(int minutes) callback) {
    _onPostpone = callback;
  }

  void setOnOpenApp(void Function() callback) {
    _onOpenApp = callback;
  }

  void setOnOpenSettings(void Function() callback) {
    _onOpenSettings = callback;
  }

  void setOnOpenStats(void Function() callback) {
    _onOpenStats = callback;
  }

  void setOnPomodoroStart(void Function() callback) {
    _onPomodoroStart = callback;
  }

  void setOnPomodoroTogglePause(void Function() callback) {
    _onPomodoroTogglePause = callback;
  }

  void setOnPomodoroSkipBreak(void Function() callback) {
    _onPomodoroSkipBreak = callback;
  }

  Future<void> destroy() async {
    _timerSubscription?.cancel();
    await _systemTray.destroy();
  }
}
