import 'dart:ffi';
import 'dart:ui';
import 'package:flutter/painting.dart';

import './native_api.dart';
import './window.dart';

Rect _getMonitorRectForWindow(int handle) {
}

class GtkWindow extends Window {
  int _handle;
  Size _minSize;
  Size _maxSize;
  Alignment _alignment = Alignment.center;

  /// *int handle* must be a valid win32 window handle
  GtkWindow(int handle) : _handle = handle;

  @override
  Rect get rect {
    Rect result;
    return result;
  }

  @override
  set rect(Rect newRect) {
  }

  @override
  Size get size {
    Size result;
    return result;
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
    return 96;
  }

  @override
  double get scaleFactor {
    return this.dpi / 96.0;
  }

  @override
  double get titleBarHeight {
    // NOTE: This might be difficult to retrieve from gtk
    return 0.0;
  }

  @override
  Size get titleBarButtonSize {
    // NOTE: This might be difficult to retrieve from gtk
    Size result;
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
      //SetWindowPos(_handle, 0, 0, 0, sizeToSet.width.toInt(), sizeToSet.height.toInt(), SWP_NOMOVE);
    } else {
      var sizeOnScreen = getSizeOnScreen((sizeToSet));
      //_updatePositionForSize(sizeOnScreen);
    }
  }

  @override
  bool get isMaximized {
    return false;
  }

  @override
  Offset get position {
    var winRect = this.rect;
    return Offset(winRect.left, winRect.top);
  }

  @override
  set position(Offset newPosition) {
  }

  @override
  void show() {
  }

  @override
  void hide() {
  }

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
  }

  @override
  void maximize() {
  }

  @override
  void minimize() {
  }

  @override
  void restore() {
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
  }

}
