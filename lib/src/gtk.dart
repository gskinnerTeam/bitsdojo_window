import 'dart:ffi';
import 'dart:ui';
import 'package:ffi/ffi.dart';

final _libgtk = DynamicLibrary.open('libgtk-3.so');

final GtkWindowGetScreen = _libgtk.lookupFunction<
  IntPtr Function(IntPtr window),
  int Function(int window)>('gtk_window_get_screen');

final GdkScreenGetDisplay = _libgtk.lookupFunction<
  IntPtr Function(IntPtr screen),
  int Function(int screen)>('gdk_screen_get_display');

final GdkDisplayGetPrimaryMonitor = _libgtk.lookupFunction<
  IntPtr Function(IntPtr display),
  int Function(int display)>('gdk_display_get_primary_monitor');

final GdkMonitorGetScaleFactor = _libgtk.lookupFunction<
  Int32 Function(IntPtr monitor),
  int Function(int monitor)>('gdk_monitor_get_scale_factor');

final GtkWindowGetPosition = _libgtk.lookupFunction<
  Void Function(IntPtr window, Pointer<Int32> x, Pointer<Int32> y),
  void Function(int window, Pointer<Int32> x, Pointer<Int32> y)>('gtk_window_get_position');

final GtkWindowGetSize = _libgtk.lookupFunction<
  Void Function(IntPtr window, Pointer<Int32> x, Pointer<Int32> y),
  void Function(int window, Pointer<Int32> x, Pointer<Int32> y)>('gtk_window_get_size');

final GtkWindowMove = _libgtk.lookupFunction<
  Void Function(IntPtr window, Int32 x, Int32 y),
  void Function(int window, int x, int y)>('gtk_window_move');

final GtkWindowResize = _libgtk.lookupFunction<
  Void Function(IntPtr window, Int32 width, Int32 height),
  void Function(int window, int width, int height)>('gtk_window_resize');

final GtkWindowClose = _libgtk.lookupFunction<
  Void Function(IntPtr window),
  void Function(int window)>('gtk_window_close');

final GtkWindowIsMaximized = _libgtk.lookupFunction<
  Int32 Function(IntPtr window),
  int Function(int window)>('gtk_window_is_maximized');

final GtkWindowMaximize = _libgtk.lookupFunction<
  Void Function(IntPtr window),
  void Function(int window)>('gtk_window_maximize');

final GtkWindowUnmaximize = _libgtk.lookupFunction<
  Void Function(IntPtr window),
  void Function(int window)>('gtk_window_unmaximize');

final GtkWindowIconify = _libgtk.lookupFunction<
  Void Function(IntPtr window),
  void Function(int window)>('gtk_window_iconify');

final GtkWindowDeiconify = _libgtk.lookupFunction<
  Void Function(IntPtr window),
  void Function(int window)>('gtk_window_deiconify');

final GtkWindowSetTitle = _libgtk.lookupFunction<
  Void Function(IntPtr window, Pointer<Utf8> title),
  void Function(int window, Pointer<Utf8> title)>('gtk_window_set_title');

