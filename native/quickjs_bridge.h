#ifndef INTEROP_JAVASCRIPT_QUICKJS_BRIDGE_H
#define INTEROP_JAVASCRIPT_QUICKJS_BRIDGE_H

#include <stdint.h>

typedef struct quickjs_runtime_handle quickjs_runtime_handle;

quickjs_runtime_handle *quickjs_runtime_create(void);
void quickjs_runtime_destroy(quickjs_runtime_handle *handle);

int64_t quickjs_runtime_eval_value(quickjs_runtime_handle *handle, const char *source);
int64_t quickjs_runtime_set_global_value(
    quickjs_runtime_handle *handle,
    const char *name,
    int64_t kind,
    int64_t bool_value,
    double number_value,
    const char *string_value);
int64_t quickjs_runtime_last_kind(quickjs_runtime_handle *handle);
int64_t quickjs_runtime_last_bool(quickjs_runtime_handle *handle);
double quickjs_runtime_last_number(quickjs_runtime_handle *handle);
const char *quickjs_runtime_last_string(quickjs_runtime_handle *handle);
const char *quickjs_runtime_last_error(quickjs_runtime_handle *handle);

#endif

