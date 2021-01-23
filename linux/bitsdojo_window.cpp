#include "bitsdojo_window.h"

#include <cinttypes>
#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>

#include "include/bitsdojo_window/fl_bitsdojo_window_plugin.h"

extern FlBitsdojoWindowPlugin *pluginInst;

BDW_API void bitsdojo_window_setMinSize(int width, int height) {
}

BDW_API void bitsdojo_window_setMaxSize(int width, int height) {
}

BDW_API uint8_t bitsdojo_window_getAppState() {
	return 0;
}

BDW_API void bitsdojo_window_setAppState(uint8_t appState) {
}

BDW_API GtkWindow* bitsdojo_window_getFlutterWindow() {
	return get_window(pluginInst);
}

