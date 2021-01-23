// Copyright 2018 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
#include "include/bitsdojo_window/fl_bitsdojo_window_plugin.h"

#include <cmath>
#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>

const char kChannelName[] = "bitsdojo/window";
const char kBadArgumentsError[] = "Invalid arguments";
const char kDragAppWindowMethod[] = "dragAppWindow";

struct _FlBitsdojoWindowPlugin {
  GObject parent_instance;

  FlPluginRegistrar* registrar;

  // Connection to Flutter engine.
  FlMethodChannel* channel;
};

G_DEFINE_TYPE(FlBitsdojoWindowPlugin, fl_bitsdojo_window_plugin, g_object_get_type())

FlBitsdojoWindowPlugin *pluginInst = nullptr;

// Gets the window being controlled.
GtkWindow* get_window(FlBitsdojoWindowPlugin* self) {
  FlView* view = fl_plugin_registrar_get_view(self->registrar);
  if (view == nullptr) return nullptr;

  return GTK_WINDOW(gtk_widget_get_toplevel(GTK_WIDGET(view)));
}

static FlMethodResponse* start_window_drag_at_position(FlBitsdojoWindowPlugin *self, FlValue *args) {
  if (fl_value_get_type(args) != FL_VALUE_TYPE_LIST ||
      fl_value_get_length(args) != 2) {
    return FL_METHOD_RESPONSE(fl_method_error_response_new(
        kBadArgumentsError, "Expected 2-element list", nullptr));
  }
  double x = fl_value_get_float(fl_value_get_list_value(args, 0));
  double y = fl_value_get_float(fl_value_get_list_value(args, 1));

  auto window = get_window(self);

  gint winX, winY;
  gtk_window_get_position(window, &winX, &winY);

  gtk_window_begin_move_drag(window,
		  1,
		  winX + static_cast<gint>(x),
		  winY + static_cast<gint>(y),
		  static_cast<guint32>(g_get_real_time()));

  return FL_METHOD_RESPONSE(fl_method_success_response_new(nullptr));
}

// Called when a method call is received from Flutter.
static void method_call_cb(FlMethodChannel* channel, FlMethodCall* method_call,
                           gpointer user_data) {
  FlBitsdojoWindowPlugin* self = FL_BITSDOJO_WINDOW_PLUGIN(user_data);

  const gchar* method = fl_method_call_get_name(method_call);
  FlValue* args = fl_method_call_get_args(method_call);

  g_autoptr(FlMethodResponse) response = nullptr;
  if (strcmp(method, kDragAppWindowMethod) == 0) {
    response = start_window_drag_at_position(self, args);
  } else {
    response = FL_METHOD_RESPONSE(fl_method_not_implemented_response_new());
  }

  g_autoptr(GError) error = nullptr;
  if (!fl_method_call_respond(method_call, response, &error))
    g_warning("Failed to send method call response: %s", error->message);
}

static void fl_bitsdojo_window_plugin_dispose(GObject* object) {
  FlBitsdojoWindowPlugin* self = FL_BITSDOJO_WINDOW_PLUGIN(object);

  g_clear_object(&self->registrar);
  g_clear_object(&self->channel);

  G_OBJECT_CLASS(fl_bitsdojo_window_plugin_parent_class)->dispose(object);
}

static void fl_bitsdojo_window_plugin_class_init(FlBitsdojoWindowPluginClass* klass) {
  G_OBJECT_CLASS(klass)->dispose = fl_bitsdojo_window_plugin_dispose;
}

static void fl_bitsdojo_window_plugin_init(FlBitsdojoWindowPlugin* self) {
	pluginInst = self;
}

FlBitsdojoWindowPlugin* fl_bitsdojo_window_plugin_new(FlPluginRegistrar* registrar) {
  FlBitsdojoWindowPlugin* self = FL_BITSDOJO_WINDOW_PLUGIN(
      g_object_new(fl_bitsdojo_window_plugin_get_type(), nullptr));

  self->registrar = FL_PLUGIN_REGISTRAR(g_object_ref(registrar));

  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  self->channel =
      fl_method_channel_new(fl_plugin_registrar_get_messenger(registrar),
                            kChannelName, FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(self->channel, method_call_cb,
                                            g_object_ref(self), g_object_unref);

  return self;
}

void fl_bitsdojo_window_plugin_register_with_registrar(FlPluginRegistrar* registrar) {
  FlBitsdojoWindowPlugin* plugin = fl_bitsdojo_window_plugin_new(registrar);
  g_object_unref(plugin);
}
