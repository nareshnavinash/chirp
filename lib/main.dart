import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import 'package:blink/core/providers.dart';
import 'package:blink/services/storage_service.dart';
import 'package:blink/services/tray_service.dart';
import 'package:blink/ui/home_screen.dart';

late final TrayService trayService;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  // Initialize storage
  final storageService = StorageService();
  await storageService.init();
  final settings = storageService.loadSettings();

  // Initialize window
  const windowOptions = WindowOptions(
    size: Size(480, 640),
    minimumSize: Size(400, 500),
    center: true,
    title: 'Blink',
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
  );

  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    if (settings.startMinimized) {
      await windowManager.hide();
    } else {
      await windowManager.show();
      await windowManager.focus();
    }
  });

  // Minimize to tray on close instead of quitting
  await windowManager.setPreventClose(true);

  // Initialize system tray
  trayService = TrayService();
  await trayService.init();

  runApp(
    ProviderScope(
      overrides: [
        storageServiceProvider.overrideWithValue(storageService),
      ],
      child: const BlinkApp(),
    ),
  );
}

class BlinkApp extends ConsumerStatefulWidget {
  const BlinkApp({super.key});

  @override
  ConsumerState<BlinkApp> createState() => _BlinkAppState();
}

class _BlinkAppState extends ConsumerState<BlinkApp> with WindowListener {
  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);

    // Wire tray pause button to app state
    trayService.setOnPauseToggle((isPaused) {
      ref.read(appStatusProvider.notifier).set(
          isPaused ? AppStatus.paused : AppStatus.running);
    });
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowClose() async {
    await windowManager.hide();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blink',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    );
  }
}
