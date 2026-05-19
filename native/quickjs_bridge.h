#ifndef INTEROP_JAVASCRIPT_QUICKJS_BRIDGE_H
#define INTEROP_JAVASCRIPT_QUICKJS_BRIDGE_H

#include <stdint.h>

typedef struct quickjs_runtime_handle quickjs_runtime_handle;
typedef struct quickjs_value_handle quickjs_value_handle;

quickjs_runtime_handle *quickjs_runtime_create(void);
void quickjs_runtime_destroy(quickjs_runtime_handle *handle);
const char *quickjs_runtime_last_error(quickjs_runtime_handle *handle);

quickjs_value_handle *quickjs_runtime_eval_value(quickjs_runtime_handle *handle, const char *source);
quickjs_value_handle *quickjs_runtime_new_undefined(quickjs_runtime_handle *handle);
quickjs_value_handle *quickjs_runtime_new_null(quickjs_runtime_handle *handle);
quickjs_value_handle *quickjs_runtime_new_bool(quickjs_runtime_handle *handle, int64_t value);
quickjs_value_handle *quickjs_runtime_new_number(quickjs_runtime_handle *handle, double value);
quickjs_value_handle *quickjs_runtime_new_string(quickjs_runtime_handle *handle, const char *value);
int64_t quickjs_runtime_set_global_value(quickjs_runtime_handle *handle, const char *name, quickjs_value_handle *value);

void quickjs_value_destroy(quickjs_value_handle *handle);
int64_t quickjs_value_kind(quickjs_value_handle *handle);
int64_t quickjs_value_to_bool(quickjs_value_handle *handle);
double quickjs_value_to_number(quickjs_value_handle *handle);
const char *quickjs_value_to_string(quickjs_value_handle *handle);
void quickjs_bridge_free_string(const char *value);
const char *quickjs_value_runtime_last_error(quickjs_value_handle *handle);

int64_t quickjs_value_is_array(quickjs_value_handle *handle);
int64_t quickjs_value_is_function(quickjs_value_handle *handle);
int64_t quickjs_value_array_length(quickjs_value_handle *handle);
quickjs_value_handle *quickjs_value_get_property(quickjs_value_handle *handle, const char *name);
int64_t quickjs_value_set_property(quickjs_value_handle *handle, const char *name, quickjs_value_handle *value);
quickjs_value_handle *quickjs_value_get_index(quickjs_value_handle *handle, int64_t index);
int64_t quickjs_value_set_index(quickjs_value_handle *handle, int64_t index, quickjs_value_handle *value);
int64_t quickjs_value_key_count(quickjs_value_handle *handle);
const char *quickjs_value_key_at(quickjs_value_handle *handle, int64_t index);

quickjs_value_handle *quickjs_value_call0(quickjs_value_handle *function);
quickjs_value_handle *quickjs_value_call1(quickjs_value_handle *function, quickjs_value_handle *arg0);
quickjs_value_handle *quickjs_value_call2(quickjs_value_handle *function, quickjs_value_handle *arg0, quickjs_value_handle *arg1);
quickjs_value_handle *quickjs_value_call_method0(quickjs_value_handle *function, quickjs_value_handle *this_value);
quickjs_value_handle *quickjs_value_call_method1(quickjs_value_handle *function, quickjs_value_handle *this_value, quickjs_value_handle *arg0);
quickjs_value_handle *quickjs_value_call_method2(quickjs_value_handle *function, quickjs_value_handle *this_value, quickjs_value_handle *arg0, quickjs_value_handle *arg1);
quickjs_value_handle *quickjs_value_construct0(quickjs_value_handle *constructor);
quickjs_value_handle *quickjs_value_construct1(quickjs_value_handle *constructor, quickjs_value_handle *arg0);
quickjs_value_handle *quickjs_value_construct2(quickjs_value_handle *constructor, quickjs_value_handle *arg0, quickjs_value_handle *arg1);

#endif