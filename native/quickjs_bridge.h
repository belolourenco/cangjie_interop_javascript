#ifndef INTEROP_JAVASCRIPT_QUICKJS_BRIDGE_H
#define INTEROP_JAVASCRIPT_QUICKJS_BRIDGE_H

#include <stdint.h>

typedef struct quickjs_runtime_handle quickjs_runtime_handle;

quickjs_runtime_handle *quickjs_runtime_create(void);
void quickjs_runtime_destroy(quickjs_runtime_handle *handle);

int64_t quickjs_runtime_eval_number(quickjs_runtime_handle *handle, const char *source);
double quickjs_runtime_last_number(quickjs_runtime_handle *handle);
const char *quickjs_runtime_last_error(quickjs_runtime_handle *handle);

#endif

