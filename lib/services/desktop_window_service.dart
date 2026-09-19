import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import '../constants/app_branding.dart';

class DesktopWindowService {
  DesktopWindowService._();

  static bool _frameless = false;

  static bool get isFrameless => _frameless;

  static bool get _canConfigure {
    if (kIsWeb) {
      return false;
    }
    if (!Platform.isWindows) {
      return false;
    }
    return !_isRunningTests;
  }

  static bool get _isRunningTests {
    return WidgetsBinding.instance.runtimeType
        .toString()
        .contains('TestWidgets');
  }

  static Future<void> configure() async {
    if (!_canConfigure) {
      return;
    }

    await windowManager.ensureInitialized();

    const windowOptions = WindowOptions(
      size: Size(1280, 720),
      minimumSize: Size(420, 640),
      center: true,
      backgroundColor: Colors.transparent,
      titleBarStyle: TitleBarStyle.hidden,
    );

    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.setTitle(AppBranding.appName);
      await windowManager.show();
      await windowManager.focus();
    });

    _frameless = true;
  }
}
