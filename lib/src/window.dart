import 'dart:ui';
import 'package:flutter/painting.dart';

abstract class Window {
  Rect get rect;

  set rect(Rect newRect);

  Size get size;

  Size get sizeOnScreen;

  double get borderSize;

  int get dpi;

  double get scaleFactor;

  double get titleBarHeight;

  Size get titleBarButtonSize;

  Size getSizeOnScreen(Size inSize);

  Size getLogicalSize(Size inSize);

  Alignment get alignment;

  set alignment(Alignment newAlignment);

  set minSize(Size newSize);

  set maxSize(Size newSize);

  set size(Size newSize);

  bool get isMaximized;

  Offset get position;

  set position(Offset newPosition);

  void show();

  void hide();

  set visible(bool isVisible);

  void close();

  void maximize();

  void minimize();

  void restore();

  void maximizeOrRestore();

  set title(String newTitle);
}
