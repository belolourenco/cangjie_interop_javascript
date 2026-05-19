#include "quickjs_bridge.h"
#include "quickjs/quickjs.h"

#include <stdlib.h>
#include <string.h>

#define QUICKJS_VALUE_UNDEFINED 0
#define QUICKJS_VALUE_NULL 1
#define QUICKJS_VALUE_BOOL 2
#define QUICKJS_VALUE_NUMBER 3
#define QUICKJS_VALUE_STRING 4
#define QUICKJS_VALUE_BIGINT 5
#define QUICKJS_VALUE_OBJECT 6

struct quickjs_runtime_handle {
    JSRuntime *runtime;
    JSContext *context;
    char *last_error;
};

struct quickjs_value_handle {
    quickjs_runtime_handle *runtime;
    JSValue value;
    char *last_error;
    char *last_string;
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

static void quickjs_value_set_error(quickjs_value_handle *handle, const char *message) {
    if (handle == NULL) {
        return;
    }

    free(handle->last_error);
    handle->last_error = quickjs_bridge_copy_string(message);
}

static void quickjs_value_clear_error(quickjs_value_handle *handle) {
    if (handle == NULL) {
        return;
    }

    free(handle->last_error);
    handle->last_error = NULL;
}

static quickjs_value_handle *quickjs_value_handle_create(quickjs_runtime_handle *runtime, JSValue value) {
    if (runtime == NULL || runtime->context == NULL) {
        return NULL;
    }

    quickjs_value_handle *handle = (quickjs_value_handle *)calloc(1, sizeof(quickjs_value_handle));
    if (handle == NULL) {
        JS_FreeValue(runtime->context, value);
        quickjs_runtime_set_error(runtime, "failed to allocate JavaScript value handle");
        return NULL;
    }

    handle->runtime = runtime;
    handle->value = value;
    return handle;
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

const char *quickjs_runtime_last_error(quickjs_runtime_handle *handle) {
    if (handle == NULL || handle->last_error == NULL) {
        return "";
    }

    return handle->last_error;
}

quickjs_value_handle *quickjs_runtime_eval_value(quickjs_runtime_handle *handle, const char *source) {
    if (handle == NULL || handle->context == NULL) {
        return NULL;
    }
    if (source == NULL) {
        quickjs_runtime_set_error(handle, "source must not be null");
        return NULL;
    }

    quickjs_runtime_clear_error(handle);

    JSValue value = JS_Eval(handle->context, source, strlen(source), "<eval>", JS_EVAL_TYPE_GLOBAL);
    if (JS_IsException(value)) {
        JSValue exception = JS_GetException(handle->context);
        const char *message = JS_ToCString(handle->context, exception);
        quickjs_runtime_set_error(handle, message);
        JS_FreeCString(handle->context, message);
        JS_FreeValue(handle->context, exception);
        return NULL;
    }

    return quickjs_value_handle_create(handle, value);
}

quickjs_value_handle *quickjs_runtime_new_undefined(quickjs_runtime_handle *handle) {
    quickjs_runtime_clear_error(handle);
    return quickjs_value_handle_create(handle, JS_UNDEFINED);
}

quickjs_value_handle *quickjs_runtime_new_null(quickjs_runtime_handle *handle) {
    quickjs_runtime_clear_error(handle);
    return quickjs_value_handle_create(handle, JS_NULL);
}

quickjs_value_handle *quickjs_runtime_new_bool(quickjs_runtime_handle *handle, int64_t value) {
    if (handle == NULL || handle->context == NULL) {
        return NULL;
    }

    quickjs_runtime_clear_error(handle);
    return quickjs_value_handle_create(handle, JS_NewBool(handle->context, value != 0));
}

quickjs_value_handle *quickjs_runtime_new_number(quickjs_runtime_handle *handle, double value) {
    if (handle == NULL || handle->context == NULL) {
        return NULL;
    }

    quickjs_runtime_clear_error(handle);
    return quickjs_value_handle_create(handle, JS_NewFloat64(handle->context, value));
}

quickjs_value_handle *quickjs_runtime_new_string(quickjs_runtime_handle *handle, const char *value) {
    if (handle == NULL || handle->context == NULL) {
        return NULL;
    }
    if (value == NULL) {
        quickjs_runtime_set_error(handle, "string value must not be null");
        return NULL;
    }

    quickjs_runtime_clear_error(handle);
    JSValue string_value = JS_NewString(handle->context, value);
    if (JS_IsException(string_value)) {
        quickjs_runtime_set_error(handle, "failed to create JavaScript string");
        return NULL;
    }

    return quickjs_value_handle_create(handle, string_value);
}

int64_t quickjs_runtime_set_global_value(quickjs_runtime_handle *handle, const char *name, quickjs_value_handle *value) {
    if (handle == NULL || handle->context == NULL) {
        return 1;
    }
    if (name == NULL) {
        quickjs_runtime_set_error(handle, "global name must not be null");
        return 1;
    }
    if (value == NULL || value->runtime != handle) {
        quickjs_runtime_set_error(handle, "global value does not belong to this runtime");
        return 1;
    }

    quickjs_runtime_clear_error(handle);

    JSValue global = JS_GetGlobalObject(handle->context);
    int status = JS_SetPropertyStr(handle->context, global, name, JS_DupValue(handle->context, value->value));
    JS_FreeValue(handle->context, global);
    if (status < 0) {
        JSValue exception = JS_GetException(handle->context);
        const char *message = JS_ToCString(handle->context, exception);
        quickjs_runtime_set_error(handle, message);
        JS_FreeCString(handle->context, message);
        JS_FreeValue(handle->context, exception);
        return 1;
    }

    return 0;
}

void quickjs_value_destroy(quickjs_value_handle *handle) {
    if (handle == NULL) {
        return;
    }

    if (handle->runtime != NULL && handle->runtime->context != NULL) {
        JS_FreeValue(handle->runtime->context, handle->value);
    }

    free(handle->last_error);
    free(handle->last_string);
    free(handle);
}

int64_t quickjs_value_kind(quickjs_value_handle *handle) {
    if (handle == NULL || handle->runtime == NULL || handle->runtime->context == NULL) {
        return QUICKJS_VALUE_UNDEFINED;
    }

    if (JS_IsUndefined(handle->value)) {
        return QUICKJS_VALUE_UNDEFINED;
    }
    if (JS_IsNull(handle->value)) {
        return QUICKJS_VALUE_NULL;
    }
    if (JS_IsBool(handle->value)) {
        return QUICKJS_VALUE_BOOL;
    }
    if (JS_IsNumber(handle->value)) {
        return QUICKJS_VALUE_NUMBER;
    }
    if (JS_IsString(handle->value)) {
        return QUICKJS_VALUE_STRING;
    }
    if (JS_IsBigInt(handle->runtime->context, handle->value)) {
        return QUICKJS_VALUE_BIGINT;
    }
    if (JS_IsObject(handle->value)) {
        return QUICKJS_VALUE_OBJECT;
    }

    return QUICKJS_VALUE_UNDEFINED;
}

int64_t quickjs_value_to_bool(quickjs_value_handle *handle) {
    if (handle == NULL || handle->runtime == NULL || handle->runtime->context == NULL) {
        return 0;
    }

    quickjs_value_clear_error(handle);
    int value = JS_ToBool(handle->runtime->context, handle->value);
    if (value < 0) {
        quickjs_value_set_error(handle, "failed to convert JavaScript value to boolean");
        return 0;
    }

    return value ? 1 : 0;
}

double quickjs_value_to_number(quickjs_value_handle *handle) {
    if (handle == NULL || handle->runtime == NULL || handle->runtime->context == NULL) {
        return 0.0;
    }

    quickjs_value_clear_error(handle);
    double value = 0.0;
    if (JS_ToFloat64(handle->runtime->context, &value, handle->value) != 0) {
        quickjs_value_set_error(handle, "failed to convert JavaScript value to number");
        return 0.0;
    }

    return value;
}

const char *quickjs_value_to_string(quickjs_value_handle *handle) {
    if (handle == NULL || handle->runtime == NULL || handle->runtime->context == NULL) {
        return "";
    }

    quickjs_value_clear_error(handle);
    free(handle->last_string);
    handle->last_string = NULL;

    const char *value = JS_ToCString(handle->runtime->context, handle->value);
    if (value == NULL) {
        quickjs_value_set_error(handle, "failed to convert JavaScript value to string");
        return "";
    }

    handle->last_string = quickjs_bridge_copy_string(value);
    JS_FreeCString(handle->runtime->context, value);
    if (handle->last_string == NULL) {
        quickjs_value_set_error(handle, "failed to allocate JavaScript string result");
        return "";
    }

    return handle->last_string;
}

const char *quickjs_value_last_error(quickjs_value_handle *handle) {
    if (handle == NULL || handle->last_error == NULL) {
        return "";
    }

    return handle->last_error;
}