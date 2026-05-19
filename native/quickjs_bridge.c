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

struct quickjs_runtime_handle {
    JSRuntime *runtime;
    JSContext *context;
    int64_t last_kind;
    int64_t last_bool;
    double last_number;
    char *last_string;
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

static void quickjs_runtime_clear_value(quickjs_runtime_handle *handle) {
    if (handle == NULL) {
        return;
    }

    handle->last_kind = QUICKJS_VALUE_UNDEFINED;
    handle->last_bool = 0;
    handle->last_number = 0.0;
    free(handle->last_string);
    handle->last_string = NULL;
}

static int64_t quickjs_runtime_store_string_value(quickjs_runtime_handle *handle, int64_t kind, JSValueConst value) {
    const char *string_value = JS_ToCString(handle->context, value);
    if (string_value == NULL) {
        quickjs_runtime_set_error(handle, "failed to convert JavaScript value to string");
        return 1;
    }

    handle->last_string = quickjs_bridge_copy_string(string_value);
    JS_FreeCString(handle->context, string_value);
    if (handle->last_string == NULL) {
        quickjs_runtime_set_error(handle, "failed to allocate JavaScript string result");
        return 1;
    }

    handle->last_kind = kind;
    return 0;
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
    free(handle->last_string);
    free(handle);
}

int64_t quickjs_runtime_eval_value(quickjs_runtime_handle *handle, const char *source) {
    if (handle == NULL || handle->context == NULL) {
        return 1;
    }
    if (source == NULL) {
        quickjs_runtime_set_error(handle, "source must not be null");
        return 1;
    }

    quickjs_runtime_clear_error(handle);
    quickjs_runtime_clear_value(handle);

    JSValue value = JS_Eval(handle->context, source, strlen(source), "<eval>", JS_EVAL_TYPE_GLOBAL);
    if (JS_IsException(value)) {
        JSValue exception = JS_GetException(handle->context);
        const char *message = JS_ToCString(handle->context, exception);
        quickjs_runtime_set_error(handle, message);
        JS_FreeCString(handle->context, message);
        JS_FreeValue(handle->context, exception);
        return 1;
    }

    int64_t status = 0;
    if (JS_IsUndefined(value)) {
        handle->last_kind = QUICKJS_VALUE_UNDEFINED;
    } else if (JS_IsNull(value)) {
        handle->last_kind = QUICKJS_VALUE_NULL;
    } else if (JS_IsBool(value)) {
        int bool_value = JS_ToBool(handle->context, value);
        if (bool_value < 0) {
            quickjs_runtime_set_error(handle, "failed to convert JavaScript boolean result");
            status = 1;
        } else {
            handle->last_kind = QUICKJS_VALUE_BOOL;
            handle->last_bool = bool_value ? 1 : 0;
        }
    } else if (JS_IsNumber(value)) {
        double number = 0.0;
        if (JS_ToFloat64(handle->context, &number, value) != 0) {
            quickjs_runtime_set_error(handle, "failed to convert JavaScript number result");
            status = 1;
        } else {
            handle->last_kind = QUICKJS_VALUE_NUMBER;
            handle->last_number = number;
        }
    } else if (JS_IsString(value)) {
        status = quickjs_runtime_store_string_value(handle, QUICKJS_VALUE_STRING, value);
    } else if (JS_IsBigInt(handle->context, value)) {
        status = quickjs_runtime_store_string_value(handle, QUICKJS_VALUE_BIGINT, value);
    } else {
        quickjs_runtime_set_error(handle, "evaluation result is not a supported primitive value");
        status = 1;
    }

    JS_FreeValue(handle->context, value);
    return status;
}

int64_t quickjs_runtime_set_global_value(
    quickjs_runtime_handle *handle,
    const char *name,
    int64_t kind,
    int64_t bool_value,
    double number_value,
    const char *string_value) {
    if (handle == NULL || handle->context == NULL) {
        return 1;
    }
    if (name == NULL) {
        quickjs_runtime_set_error(handle, "global name must not be null");
        return 1;
    }

    quickjs_runtime_clear_error(handle);

    JSValue value = JS_UNDEFINED;
    if (kind == QUICKJS_VALUE_UNDEFINED) {
        value = JS_UNDEFINED;
    } else if (kind == QUICKJS_VALUE_NULL) {
        value = JS_NULL;
    } else if (kind == QUICKJS_VALUE_BOOL) {
        value = JS_NewBool(handle->context, bool_value != 0);
    } else if (kind == QUICKJS_VALUE_NUMBER) {
        value = JS_NewFloat64(handle->context, number_value);
    } else if (kind == QUICKJS_VALUE_STRING) {
        if (string_value == NULL) {
            quickjs_runtime_set_error(handle, "string value must not be null");
            return 1;
        }
        value = JS_NewString(handle->context, string_value);
        if (JS_IsException(value)) {
            quickjs_runtime_set_error(handle, "failed to create JavaScript string");
            return 1;
        }
    } else {
        quickjs_runtime_set_error(handle, "unsupported Cangjie value kind for JavaScript global");
        return 1;
    }

    JSValue global = JS_GetGlobalObject(handle->context);
    int status = JS_SetPropertyStr(handle->context, global, name, value);
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

int64_t quickjs_runtime_last_kind(quickjs_runtime_handle *handle) {
    if (handle == NULL) {
        return QUICKJS_VALUE_UNDEFINED;
    }

    return handle->last_kind;
}

int64_t quickjs_runtime_last_bool(quickjs_runtime_handle *handle) {
    if (handle == NULL) {
        return 0;
    }

    return handle->last_bool;
}

double quickjs_runtime_last_number(quickjs_runtime_handle *handle) {
    if (handle == NULL) {
        return 0.0;
    }

    return handle->last_number;
}

const char *quickjs_runtime_last_string(quickjs_runtime_handle *handle) {
    if (handle == NULL || handle->last_string == NULL) {
        return "";
    }

    return handle->last_string;
}

const char *quickjs_runtime_last_error(quickjs_runtime_handle *handle) {
    if (handle == NULL || handle->last_error == NULL) {
        return "";
    }

    return handle->last_error;
}

