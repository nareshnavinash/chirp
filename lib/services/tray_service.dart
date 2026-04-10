import 'package:system_tray/system_tray.dart';
import 'package:window_manager/window_manager.dart';

class TrayService {
  final SystemTray _systemTray = SystemTray();
  bool _isPaused = false;

  bool get isPaused => _isPaused;

  Future<void> init() async {
    await _systemTray.initSystemTray(
      title: 'Blink',
      iconPath: _getTrayIconPath(),
      toolTip: 'Blink - Next break in 20:00',
    );

    await _updateMenu();

    _systemTray.registerSystemTrayEventHandler((eventName) {
      if (eventName == kSystemTrayEventClick ||
          eventName == kSystemTrayEventRightClick) {
        _systemTray.popUpContextMenu();
      }
    });
  }

  String _getTrayIconPath() {
    return 'assets/icons/tray_icon.png';
  }

  Future<void> _updateMenu() async {
    final menu = Menu();
    await menu.buildFrom([
      MenuItemLabel(
        label: 'Open Blink',
        onClicked: (menuItem) async {
          await windowManager.show();
          await windowManager.focus();
        },
      ),
      MenuSeparator(),
      MenuItemLabel(
        label: _isPaused ? 'Resume' : 'Pause',
        onClicked: (menuItem) async {
          _isPaused = !_isPaused;
          await _updateMenu();
          _onPauseToggle?.call(_isPaused);
        },
      ),
      MenuSeparator(),
      MenuItemLabel(
        label: 'Quit Blink',
        onClicked: (menuItem) async {
          await _systemTray.destroy();
          await windowManager.destroy();
        },
      ),
    ]);
    await _systemTray.setContextMenu(menu);
  }

  void Function(bool isPaused)? _onPauseToggle;

  void setOnPauseToggle(void Function(bool isPaused) callback) {
    _onPauseToggle = callback;
  }

  Future<void> updateTooltip(String text) async {
    await _systemTray.setToolTip(text);
  }

  Future<void> destroy() async {
    await _systemTray.destroy();
  }
}
