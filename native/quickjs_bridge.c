#include "quickjs_bridge.h"
#include "quickjs/quickjs.h"

#include <stdlib.h>
#include <string.h>

struct quickjs_runtime_handle {
    JSRuntime *runtime;
    JSContext *context;
    double last_number;
    char *last_error;
};

static char *quickjs_bridge_copy_string(const char *message) {
    if (message == NULL) {
        message = "unknown QuickJS error";
    }

    size_t length = strlen(message);
    char *copy = (char *)malloc(length + 1);
    if (copy == NULL) {
        return NULL;
    }

    memcpy(copy, message, length + 1);
    return copy;
}

static void quickjs_runtime_set_error(quickjs_runtime_handle *handle, const char *message) {
    if (handle == NULL) {
        return;
    }

    free(handle->last_error);
    handle->last_error = quickjs_bridge_copy_string(message);
}

static void quickjs_runtime_clear_error(quickjs_runtime_handle *handle) {
    if (handle == NULL) {
        return;
    }

    free(handle->last_error);
    handle->last_error = NULL;
}

quickjs_runtime_handle *quickjs_runtime_create(void) {
    quickjs_runtime_handle *handle = (quickjs_runtime_handle *)calloc(1, sizeof(quickjs_runtime_handle));
    if (handle == NULL) {
        return NULL;
    }

    handle->runtime = JS_NewRuntime();
    if (handle->runtime == NULL) {
        free(handle);
        return NULL;
    }

    handle->context = JS_NewContext(handle->runtime);
    if (handle->context == NULL) {
        JS_FreeRuntime(handle->runtime);
        free(handle);
        return NULL;
    }

    return handle;
}

void quickjs_runtime_destroy(quickjs_runtime_handle *handle) {
    if (handle == NULL) {
        return;
    }

    if (handle->context != NULL) {
        JS_FreeContext(handle->context);
    }
    if (handle->runtime != NULL) {
        JS_FreeRuntime(handle->runtime);
    }

    free(handle->last_error);
    free(handle);
}

int64_t quickjs_runtime_eval_number(quickjs_runtime_handle *handle, const char *source) {
    if (handle == NULL || handle->context == NULL) {
        return 1;
    }
    if (source == NULL) {
        quickjs_runtime_set_error(handle, "source must not be null");
        return 1;
    }

    quickjs_runtime_clear_error(handle);

    JSValue value = JS_Eval(handle->context, source, strlen(source), "<eval>", JS_EVAL_TYPE_GLOBAL);
    if (JS_IsException(value)) {
        JSValue exception = JS_GetException(handle->context);
        const char *message = JS_ToCString(handle->context, exception);
        quickjs_runtime_set_error(handle, message);
        JS_FreeCString(handle->context, message);
        JS_FreeValue(handle->context, exception);
        return 1;
    }

    double number = 0.0;
    if (JS_ToFloat64(handle->context, &number, value) != 0) {
        JS_FreeValue(handle->context, value);
        quickjs_runtime_set_error(handle, "evaluation result is not a number");
        return 1;
    }

    JS_FreeValue(handle->context, value);
    handle->last_number = number;
    return 0;
}

double quickjs_runtime_last_number(quickjs_runtime_handle *handle) {
    if (handle == NULL) {
        return 0.0;
    }

    return handle->last_number;
}

const char *quickjs_runtime_last_error(quickjs_runtime_handle *handle) {
    if (handle == NULL || handle->last_error == NULL) {
        return "";
    }

    return handle->last_error;
}

