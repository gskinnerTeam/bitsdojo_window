library bitsdojo_window;

import 'dart:io' show Platform;
import 'package:flutter/widgets.dart';
import './native_api.dart';
import './window.dart';
import './win32_window.dart';
import './gtk_window.dart';

void doWhenWindowReady(VoidCallback callback) {
  WidgetsBinding.instance.waitUntilFirstFrameRasterized.then((value) {
    setAppState(AppState.Ready);
    callback();
  });
}

var appWindow = _getAppWindow();
const notInitializedMessage = """
 bitsdojo_window is not initalized.
 """;

class BitsDojoNotInitializedException implements Exception {
  String errMsg() => notInitializedMessage;
}

Window _getAppWindow() {
  int handle = getFlutterWindow();
  if (handle == null || getAppState() == AppState.Unknown) {
    throw BitsDojoNotInitializedException;
  }
  if (Platform.isWindows) return Win32Window(handle);
  if (Platform.isLinux) return GtkWindow(handle);
  // TODO: Add a dummy window to gracefully handle the error case where a window handle could not be
  // retrieved
}
