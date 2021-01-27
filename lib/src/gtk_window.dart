import 'dart:ffi';
import 'dart:ui';
import 'package:flutter/painting.dart';
import 'package:ffi/ffi.dart';

import './gtk.dart';
import './native_api.dart';
import './window.dart';

Rect _getMonitorRectForWindow(int handle) {}

class GtkWindow extends Window {
  int _handle;
  Size _minSize;
  Size _maxSize;
  Alignment _alignment = Alignment.center;

  /// *int handle* must be a valid gtk window handle
  GtkWindow(int handle) : _handle = handle;

  @override
  Rect get rect {

    Pointer<Int32> gtkRect = allocate(count: 4);

    GtkWindowGetPosition(_handle, gtkRect.elementAt(0), gtkRect.elementAt(1));
    GtkWindowGetSize(_handle, gtkRect.elementAt(2), gtkRect.elementAt(3));

    Rect result = Rect.fromLTWH(
        gtkRect[0].toDouble(),
        gtkRect[1].toDouble(),
        gtkRect[2].toDouble(),
        gtkRect[3].toDouble());

    free(gtkRect);

    return result;
  }

  @override
  set rect(Rect newRect) {
    GtkWindowMove(_handle, newRect.left.toInt(), newRect.top.toInt());
    GtkWindowResize(_handle, newRect.width.toInt(), newRect.height.toInt());
  }

  @override
  Size get size {
    return this.rect.size;
  }

  @override
  Size get sizeOnScreen {
    Size result;
    return result;
  }

  @override
  double get borderSize {
    return 0.0;
  }

  @override
  int get dpi {
    return (96.0 * this.scaleFactor).toInt();
  }

  @override
  double get scaleFactor {
    final screen = GtkWindowGetScreen(_handle);
    final display = GdkScreenGetDisplay(screen);
    final monitor = GdkDisplayGetPrimaryMonitor(display);
    return GdkMonitorGetScaleFactor(monitor).toDouble();
  }

  @override
  double get titleBarHeight {
    // NOTE: This might be difficult to retrieve from gtk
    return 32.0;
  }

  @override
  Size get titleBarButtonSize {
    // NOTE: This might be difficult to retrieve from gtk
    Size result = Size(32, 32);
    return result;
  }

  @override
  Size getSizeOnScreen(Size inSize) {
    double scaleFactor = this.scaleFactor;
    double newWidth = inSize.width * scaleFactor;
    double newHeight = inSize.height * scaleFactor;
    return Size(newWidth, newHeight);
  }

  @override
  Size getLogicalSize(Size inSize) {
    double scaleFactor = this.scaleFactor;
    double newWidth = inSize.width / scaleFactor;
    double newHeight = inSize.height / scaleFactor;
    return Size(newWidth, newHeight);
  }

  @override
  get alignment => _alignment;

  /// How the window should be aligned on screen
  @override
  set alignment(Alignment newAlignment) {
    var sizeOnScreen = this.sizeOnScreen;
    _alignment = newAlignment;
    //_updatePositionForSize(sizeOnScreen);
  }

  @override
  set minSize(Size newSize) {
    _minSize = newSize;
    setMinSize(_minSize.width.toInt(), _minSize.height.toInt());
  }

  @override
  set maxSize(Size newSize) {
    _maxSize = newSize;
    setMaxSize(_maxSize.width.toInt(), _maxSize.height.toInt());
  }

  @override
  set size(Size newSize) {
    var width = newSize.width;

    if ((_minSize != null) && (newSize.width < _minSize.width)) {
      width = _minSize.width;
    }

    if ((_maxSize != null) && (newSize.width > _maxSize.width)) {
      width = _maxSize.width;
    }

    var height = newSize.height;

    if ((_minSize != null) && (newSize.height < _minSize.height)) {
      height = _minSize.height;
    }

    if ((_maxSize != null) && (newSize.height > _maxSize.height)) {
      height = _maxSize.height;
    }

    Size sizeToSet = Size(width, height);
    if (_alignment == null) {
      GtkWindowResize(_handle, sizeToSet.width.toInt(), sizeToSet.height.toInt());
    } else {
      var sizeOnScreen = getSizeOnScreen((sizeToSet));
      //_updatePositionForSize(sizeOnScreen);
    }
  }

  @override
  bool get isMaximized {
    return GtkWindowIsMaximized(_handle) == 1;
  }

  @override
  Offset get position {
    return this.rect.topLeft;
  }

  @override
  set position(Offset newPosition) {
    GtkWindowMove(_handle, newPosition.dx.toInt(), newPosition.dy.toInt());
  }

  @override
  void show() {}

  @override
  void hide() {}

  @override
  set visible(bool isVisible) {
    if (isVisible) {
      show();
    } else {
      hide();
    }
  }

  @override
  void close() {
    GtkWindowClose(_handle);
  }

  @override
  void maximize() {
    GtkWindowMaximize(_handle);
  }

  @override
  void minimize() {
    GtkWindowIconify(_handle);
  }

  @override
  void restore() {
    GtkWindowUnmaximize(_handle);
  }

  @override
  void maximizeOrRestore() {
    if (this.isMaximized) {
      this.restore();
    } else {
      this.maximize();
    }
  }

  @override
  set title(String newTitle) {
    final nativeString = Utf8.toUtf8(newTitle);
    GtkWindowSetTitle(_handle, nativeString);
    free(nativeString);
  }
}
