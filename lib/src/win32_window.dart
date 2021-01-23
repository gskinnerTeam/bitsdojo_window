import 'dart:ffi';
import 'dart:ui';
import 'package:flutter/painting.dart';

import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

import './win32_plus.dart';
import './native_api.dart';
import './window.dart';

bool _isValidHandle(int handle, String operation) {
  // TODO: This shouldn't ever get called as it is a constraint that the handle is valid before this
  // object is constructed, this function should be removed
  if (handle == null) {
    print("Could not $operation - handle is null");
    return false;
  }
  return true;
}

Rect _getMonitorRectForWindow(int handle) {
  int monitor = MonitorFromWindow(handle, MONITOR_DEFAULTTONEAREST);
  final monitorInfo = MONITORINFO.allocate();
  final result = GetMonitorInfo(monitor, monitorInfo.addressOf);
  if (result == TRUE) {
    return Rect.fromLTRB(monitorInfo.rcWorkLeft.toDouble(), monitorInfo.rcWorkTop.toDouble(),
        monitorInfo.rcWorkRight.toDouble(), monitorInfo.rcWorkBottom.toDouble());
  }
  return Rect.zero;
}

class Win32Window extends Window {
  int _handle;
  Size _minSize;
  Size _maxSize;
  Alignment _alignment = Alignment.center;

  /// *int handle* must be a valid win32 window handle
  Win32Window(int handle) : _handle = handle;

  @override
  Rect get rect {
    final winRect = RECT.allocate();
    GetWindowRect(_handle, winRect.addressOf);
    Rect result = winRect.toRect;
    free(winRect.addressOf);
    return result;
  }

  @override
  set rect(Rect newRect) {
    SetWindowPos(
        _handle, 0, newRect.left.toInt(), newRect.top.toInt(), newRect.width.toInt(), newRect.height.toInt(), 0);
  }

  @override
  Size get size {
    var winRect = this.rect;
    var gotSize = getLogicalSize(Size(winRect.width, winRect.height));
    return gotSize;
  }

  @override
  Size get sizeOnScreen {
    var winRect = this.rect;
    return Size(winRect.width, winRect.height);
  }

  @override
  double get borderSize {
    return this._systemMetric(SM_CXBORDER);
  }

  @override
  int get dpi {
    return GetDpiForWindow(_handle);
  }

  @override
  double get scaleFactor {
    double result = this.dpi / 96.0;
    return result;
  }

  @override
  double get titleBarHeight {
    double scaleFactor = this.scaleFactor;
    int dpiToUse = this.dpi;
    double cyCaption = _systemMetric(SM_CYCAPTION, dpiToUse: dpiToUse);
    cyCaption = (cyCaption / scaleFactor);
    double cySizeFrame = _systemMetric(SM_CYSIZEFRAME, dpiToUse: dpiToUse);
    cySizeFrame = (cySizeFrame / scaleFactor);
    double cxPaddedBorder = _systemMetric(SM_CXPADDEDBORDER, dpiToUse: dpiToUse);
    cxPaddedBorder = (cxPaddedBorder / scaleFactor).ceilToDouble();
    double result = cySizeFrame + cyCaption + cxPaddedBorder;
    return result;
  }

  @override
  Size get titleBarButtonSize {
    double height = this.titleBarHeight - this.borderSize;
    double scaleFactor = this.scaleFactor;
    double cyCaption = _systemMetric(SM_CYCAPTION);
    cyCaption /= scaleFactor;
    double width = cyCaption * 2;
    return Size(width, height);
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
    _updatePositionForSize(sizeOnScreen);
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
      SetWindowPos(_handle, 0, 0, 0, sizeToSet.width.toInt(), sizeToSet.height.toInt(), SWP_NOMOVE);
    } else {
      var sizeOnScreen = getSizeOnScreen((sizeToSet));
      _updatePositionForSize(sizeOnScreen);
    }
  }

  @override
  bool get isMaximized {
    return (IsZoomed(_handle) == 1);
  }

  @override
  Offset get position {
    var winRect = this.rect;
    return Offset(winRect.left, winRect.top);
  }

  @override
  set position(Offset newPosition) {
    SetWindowPos(_handle, 0, newPosition.dx.toInt(), newPosition.dy.toInt(), 0, 0, SWP_NOSIZE);
  }

  @override
  void show() {
    if (!_isValidHandle(_handle, "show")) return;
    SetWindowPos(_handle, 0, 0, 0, 0, 0, SWP_NOSIZE | SWP_NOMOVE | SWP_SHOWWINDOW);
  }

  @override
  void hide() {
    if (!_isValidHandle(_handle, "hide")) return;
    SetWindowPos(_handle, 0, 0, 0, 0, 0, SWP_NOSIZE | SWP_NOMOVE | SWP_HIDEWINDOW);
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
    if (!_isValidHandle(_handle, "close")) return;
    PostMessage(_handle, WM_SYSCOMMAND, SC_CLOSE, 0);
  }

  @override
  void maximize() {
    if (!_isValidHandle(_handle, "maximize")) return;
    PostMessage(_handle, WM_SYSCOMMAND, SC_MAXIMIZE, 0);
  }

  @override
  void minimize() {
    if (!_isValidHandle(_handle, "minimize")) return;

    PostMessage(_handle, WM_SYSCOMMAND, SC_MINIMIZE, 0);
  }

  @override
  void restore() {
    if (!_isValidHandle(_handle, "restore")) return;
    PostMessage(_handle, WM_SYSCOMMAND, SC_RESTORE, 0);
  }

  @override
  void maximizeOrRestore() {
    if (!_isValidHandle(_handle, "maximizeOrRestore")) return;
    if (IsZoomed(_handle) == 1) {
      this.restore();
    } else {
      this.maximize();
    }
  }

  @override
  set title(String newTitle) {
    if (!_isValidHandle(_handle, "set title")) return;
    SetWindowText(_handle, TEXT(newTitle));
  }

  double _systemMetric(int metric, {int dpiToUse = 0}) {
    var windowDpi = dpiToUse != 0 ? dpiToUse : this.dpi;
    double result = GetSystemMetricsForDpi(metric, windowDpi).toDouble();
    return result;
  }

  void _updatePositionForSize(Size sizeOnScreen) {
    var monitorRect = _getMonitorRectForWindow(_handle);
    if (_alignment == Alignment.center) {
      this.rect = Rect.fromCenter(center: monitorRect.center, width: sizeOnScreen.width, height: sizeOnScreen.height);
    }
    if (_alignment == Alignment.topLeft) {
      var topLeft = monitorRect.topLeft;
      var otherOffset = Offset(topLeft.dx + sizeOnScreen.width, topLeft.dy + sizeOnScreen.height);
      this.rect = Rect.fromPoints(topLeft, otherOffset);
      return;
    }
    if (_alignment == Alignment.topRight) {
      var topRight = monitorRect.topRight;
      var otherOffset = Offset(topRight.dx - sizeOnScreen.width, topRight.dy + sizeOnScreen.height);
      this.rect = Rect.fromPoints(otherOffset, topRight);
      return;
    }
    if (_alignment == Alignment.bottomLeft) {
      var bottomLeft = monitorRect.bottomLeft;
      var otherOffset = Offset(bottomLeft.dx + sizeOnScreen.width, bottomLeft.dy - sizeOnScreen.height);
      this.rect = Rect.fromPoints(bottomLeft, otherOffset);
    }
    if (_alignment == Alignment.bottomRight) {
      var bottomRight = monitorRect.bottomRight;
      var otherOffset = Offset(bottomRight.dx - sizeOnScreen.width, bottomRight.dy - sizeOnScreen.height);
      this.rect = Rect.fromPoints(bottomRight, otherOffset);
    }
  }
}
