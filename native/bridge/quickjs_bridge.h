#ifndef INTEROP_JAVASCRIPT_BRIDGE_H
#define INTEROP_JAVASCRIPT_BRIDGE_H

#include <stdint.h>

typedef struct js_runtime_handle js_runtime_handle;
typedef struct js_value_handle js_value_handle;

js_runtime_handle *js_runtime_create(void);
void js_runtime_destroy(js_runtime_handle *handle);
const char *js_runtime_last_error(js_runtime_handle *handle);
int64_t js_runtime_enable_std_module(js_runtime_handle *handle);

js_value_handle *js_runtime_eval_value(js_runtime_handle *handle, const char *source);
js_value_handle *js_runtime_get_global_property(js_runtime_handle *handle, const char *name);
js_value_handle *js_runtime_new_bool(js_runtime_handle *handle, int64_t value);
js_value_handle *js_runtime_new_number(js_runtime_handle *handle, double value);
js_value_handle *js_runtime_new_string(js_runtime_handle *handle, const char *value);
js_value_handle *js_runtime_new_bigint(js_runtime_handle *handle, const char *value);
js_value_handle *js_runtime_import_module(js_runtime_handle *handle, const char *path);

void js_value_destroy(js_value_handle *handle);
int64_t js_value_kind(js_value_handle *handle);
int64_t js_value_to_bool(js_value_handle *handle);
double js_value_to_number(js_value_handle *handle);
const char *js_value_to_string(js_value_handle *handle);
void js_bridge_free_string(const char *value);

int64_t js_value_is_array(js_value_handle *handle);
int64_t js_value_array_length(js_value_handle *handle);
js_value_handle *js_value_get_property(js_value_handle *handle, const char *name);
int64_t js_value_set_property(js_value_handle *handle, const char *name, js_value_handle *value);
js_value_handle *js_value_get_index(js_value_handle *handle, int64_t index);
int64_t js_value_set_index(js_value_handle *handle, int64_t index, js_value_handle *value);

js_value_handle *js_value_call(js_value_handle *function, js_value_handle *this_value, js_value_handle **args, int numArgs);
js_value_handle *js_value_construct(js_value_handle *constructor, js_value_handle **args, int numArgs);

#endif
