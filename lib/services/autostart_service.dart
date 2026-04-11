import 'dart:io';

import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:chirp/core/app_constants.dart';

class AutostartService {
  Future<void> init() async {
    launchAtStartup.setup(
      appName: AppConstants.appName,
      appPath: _getAppPath(),
    );
  }

  String _getAppPath() {
    return Platform.resolvedExecutable;
  }

  Future<bool> isEnabled() async {
    return await launchAtStartup.isEnabled();
  }

  Future<void> setEnabled(bool enabled) async {
    if (enabled) {
      await launchAtStartup.enable();
    } else {
      await launchAtStartup.disable();
    }
  }
}
