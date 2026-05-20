#include "quickjs_bridge.h"
#include "quickjs/quickjs.h"
#include "quickjs/quickjs-libc.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define QUICKJS_VALUE_UNDEFINED 0
#define QUICKJS_VALUE_NULL 1
#define QUICKJS_VALUE_BOOL 2
#define QUICKJS_VALUE_NUMBER 3
#define QUICKJS_VALUE_STRING 4
#define QUICKJS_VALUE_BIGINT 5
#define QUICKJS_VALUE_OBJECT 6
#define QUICKJS_VALUE_FUNCTION 7

struct quickjs_runtime_handle {
    JSRuntime *runtime;
    JSContext *context;
    char *last_error;
    struct quickjs_module_cache_entry *module_cache;
    int std_module_enabled;
};

struct quickjs_value_handle {
    quickjs_runtime_handle *runtime;
    JSValue value;
};

struct quickjs_module_cache_entry {
    char *path;
    JSValue namespace_value;
    struct quickjs_module_cache_entry *next;
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

static unsigned char *quickjs_bridge_read_file(const char *path, size_t *length) {
    FILE *file = fopen(path, "rb");
    if (file == NULL) {
        return NULL;
    }

    if (fseek(file, 0, SEEK_END) != 0) {
        fclose(file);
        return NULL;
    }

    long file_size = ftell(file);
    if (file_size < 0) {
        fclose(file);
        return NULL;
    }

    if (fseek(file, 0, SEEK_SET) != 0) {
        fclose(file);
        return NULL;
    }

    unsigned char *buffer = (unsigned char *)malloc((size_t)file_size + 1);
    if (buffer == NULL) {
        fclose(file);
        return NULL;
    }

    size_t read_count = fread(buffer, 1, (size_t)file_size, file);
    fclose(file);
    if (read_count != (size_t)file_size) {
        free(buffer);
        return NULL;
    }

    buffer[file_size] = '\0';
    *length = (size_t)file_size;
    return buffer;
}

static void quickjs_runtime_capture_exception(quickjs_runtime_handle *handle) {
    if (handle == NULL || handle->context == NULL) {
        return;
    }

    JSValue exception = JS_GetException(handle->context);
    const char *message = JS_ToCString(handle->context, exception);
    quickjs_runtime_set_error(handle, message);
    JS_FreeCString(handle->context, message);
    JS_FreeValue(handle->context, exception);
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
        struct quickjs_module_cache_entry *entry = handle->module_cache;
        while (entry != NULL) {
            struct quickjs_module_cache_entry *next = entry->next;
            JS_FreeValue(handle->context, entry->namespace_value);
            free(entry->path);
            free(entry);
            entry = next;
        }

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

int64_t quickjs_runtime_enable_std_module(quickjs_runtime_handle *handle) {
    if (handle == NULL || handle->runtime == NULL || handle->context == NULL) {
        return 1;
    }
    if (handle->std_module_enabled) {
        return 0;
    }

    quickjs_runtime_clear_error(handle);
    JS_SetModuleLoaderFunc2(handle->runtime, NULL, js_module_loader, js_module_check_attributes, NULL);
    if (js_init_module_std(handle->context, "std") == NULL) {
        quickjs_runtime_capture_exception(handle);
        return 1;
    }

    handle->std_module_enabled = 1;
    return 0;
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
        quickjs_runtime_capture_exception(handle);
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
        quickjs_runtime_capture_exception(handle);
        return 1;
    }

    return 0;
}

quickjs_value_handle *quickjs_runtime_import_module(quickjs_runtime_handle *handle, const char *path) {
    if (handle == NULL || handle->context == NULL) {
        return NULL;
    }
    if (path == NULL) {
        quickjs_runtime_set_error(handle, "module path must not be null");
        return NULL;
    }

    quickjs_runtime_clear_error(handle);

    for (struct quickjs_module_cache_entry *entry = handle->module_cache; entry != NULL; entry = entry->next) {
        if (strcmp(entry->path, path) == 0) {
            return quickjs_value_handle_create(handle, JS_DupValue(handle->context, entry->namespace_value));
        }
    }

    size_t source_length = 0;
    unsigned char *source = quickjs_bridge_read_file(path, &source_length);
    if (source == NULL) {
        quickjs_runtime_set_error(handle, "failed to read JavaScript module file");
        return NULL;
    }

    JSValue compiled = JS_Eval(
        handle->context,
        (const char *)source,
        source_length,
        path,
        JS_EVAL_TYPE_MODULE | JS_EVAL_FLAG_COMPILE_ONLY);
    free(source);
    if (JS_IsException(compiled)) {
        quickjs_runtime_capture_exception(handle);
        return NULL;
    }

    if (JS_ResolveModule(handle->context, compiled) < 0) {
        JS_FreeValue(handle->context, compiled);
        quickjs_runtime_capture_exception(handle);
        return NULL;
    }

    JSModuleDef *module = (JSModuleDef *)JS_VALUE_GET_PTR(compiled);
    JSValue eval_result = JS_EvalFunction(handle->context, compiled);
    if (JS_IsException(eval_result)) {
        quickjs_runtime_capture_exception(handle);
        return NULL;
    }
    JS_FreeValue(handle->context, eval_result);

    JSValue namespace_value = JS_GetModuleNamespace(handle->context, module);
    if (JS_IsException(namespace_value)) {
        quickjs_runtime_capture_exception(handle);
        return NULL;
    }

    struct quickjs_module_cache_entry *entry = (struct quickjs_module_cache_entry *)calloc(1, sizeof(struct quickjs_module_cache_entry));
    if (entry == NULL) {
        JS_FreeValue(handle->context, namespace_value);
        quickjs_runtime_set_error(handle, "failed to allocate JavaScript module cache entry");
        return NULL;
    }
    entry->path = quickjs_bridge_copy_string(path);
    if (entry->path == NULL) {
        free(entry);
        JS_FreeValue(handle->context, namespace_value);
        quickjs_runtime_set_error(handle, "failed to allocate JavaScript module path");
        return NULL;
    }
    entry->namespace_value = JS_DupValue(handle->context, namespace_value);
    entry->next = handle->module_cache;
    handle->module_cache = entry;

    return quickjs_value_handle_create(handle, namespace_value);
}

void quickjs_value_destroy(quickjs_value_handle *handle) {
    if (handle == NULL) {
        return;
    }

    if (handle->runtime != NULL && handle->runtime->context != NULL) {
        JS_FreeValue(handle->runtime->context, handle->value);
    }

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
    if (JS_IsFunction(handle->runtime->context, handle->value)) {
        return QUICKJS_VALUE_FUNCTION;
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

    int value = JS_ToBool(handle->runtime->context, handle->value);
    if (value < 0) {
        quickjs_runtime_set_error(handle->runtime, "failed to convert JavaScript value to boolean");
        return 0;
    }

    return value ? 1 : 0;
}

double quickjs_value_to_number(quickjs_value_handle *handle) {
    if (handle == NULL || handle->runtime == NULL || handle->runtime->context == NULL) {
        return 0.0;
    }

    double value = 0.0;
    if (JS_ToFloat64(handle->runtime->context, &value, handle->value) != 0) {
        quickjs_runtime_set_error(handle->runtime, "failed to convert JavaScript value to number");
        return 0.0;
    }

    return value;
}

const char *quickjs_value_to_string(quickjs_value_handle *handle) {
    if (handle == NULL || handle->runtime == NULL || handle->runtime->context == NULL) {
        return NULL;
    }

    const char *value = JS_ToCString(handle->runtime->context, handle->value);
    if (value == NULL) {
        quickjs_runtime_set_error(handle->runtime, "failed to convert JavaScript value to string");
        return NULL;
    }

    char *copy = quickjs_bridge_copy_string(value);
    JS_FreeCString(handle->runtime->context, value);
    if (copy == NULL) {
        quickjs_runtime_set_error(handle->runtime, "failed to allocate JavaScript string result");
        return NULL;
    }

    return copy;
}

void quickjs_bridge_free_string(const char *value) {
    free((void *)value);
}

const char *quickjs_value_runtime_last_error(quickjs_value_handle *handle) {
    if (handle == NULL || handle->runtime == NULL) {
        return "";
    }

    return quickjs_runtime_last_error(handle->runtime);
}

int64_t quickjs_value_is_array(quickjs_value_handle *handle) {
    if (handle == NULL || handle->runtime == NULL || handle->runtime->context == NULL) {
        return 0;
    }

    return JS_IsArray(handle->runtime->context, handle->value) ? 1 : 0;
}

int64_t quickjs_value_is_function(quickjs_value_handle *handle) {
    if (handle == NULL || handle->runtime == NULL || handle->runtime->context == NULL) {
        return 0;
    }

    return JS_IsFunction(handle->runtime->context, handle->value) ? 1 : 0;
}

int64_t quickjs_value_array_length(quickjs_value_handle *handle) {
    if (handle == NULL || handle->runtime == NULL || handle->runtime->context == NULL) {
        return -1;
    }

    JSContext *ctx = handle->runtime->context;
    JSValue length_value = JS_GetPropertyStr(ctx, handle->value, "length");
    if (JS_IsException(length_value)) {
        quickjs_runtime_set_error(handle->runtime, "failed to read JavaScript array length");
        return -1;
    }

    double length_number = 0.0;
    if (JS_ToFloat64(ctx, &length_number, length_value) != 0) {
        JS_FreeValue(ctx, length_value);
        quickjs_runtime_set_error(handle->runtime, "failed to convert JavaScript array length");
        return -1;
    }

    JS_FreeValue(ctx, length_value);
    return (int64_t)length_number;
}

quickjs_value_handle *quickjs_value_get_property(quickjs_value_handle *handle, const char *name) {
    if (handle == NULL || handle->runtime == NULL || handle->runtime->context == NULL) {
        return NULL;
    }
    if (name == NULL) {
        quickjs_runtime_set_error(handle->runtime, "property name must not be null");
        return NULL;
    }

    quickjs_runtime_clear_error(handle->runtime);
    JSValue value = JS_GetPropertyStr(handle->runtime->context, handle->value, name);
    if (JS_IsException(value)) {
        JSValue exception = JS_GetException(handle->runtime->context);
        const char *message = JS_ToCString(handle->runtime->context, exception);
        quickjs_runtime_set_error(handle->runtime, message);
        JS_FreeCString(handle->runtime->context, message);
        JS_FreeValue(handle->runtime->context, exception);
        return NULL;
    }

    return quickjs_value_handle_create(handle->runtime, value);
}

int64_t quickjs_value_set_property(quickjs_value_handle *handle, const char *name, quickjs_value_handle *value) {
    if (handle == NULL || handle->runtime == NULL || handle->runtime->context == NULL) {
        return 1;
    }
    if (name == NULL) {
        quickjs_runtime_set_error(handle->runtime, "property name must not be null");
        return 1;
    }
    if (value == NULL || value->runtime != handle->runtime) {
        quickjs_runtime_set_error(handle->runtime, "property value does not belong to this runtime");
        return 1;
    }

    quickjs_runtime_clear_error(handle->runtime);
    int status = JS_SetPropertyStr(
        handle->runtime->context,
        handle->value,
        name,
        JS_DupValue(handle->runtime->context, value->value));
    if (status < 0) {
        JSValue exception = JS_GetException(handle->runtime->context);
        const char *message = JS_ToCString(handle->runtime->context, exception);
        quickjs_runtime_set_error(handle->runtime, message);
        JS_FreeCString(handle->runtime->context, message);
        JS_FreeValue(handle->runtime->context, exception);
        return 1;
    }

    return 0;
}

quickjs_value_handle *quickjs_value_get_index(quickjs_value_handle *handle, int64_t index) {
    if (handle == NULL || handle->runtime == NULL || handle->runtime->context == NULL) {
        return NULL;
    }
    if (index < 0) {
        quickjs_runtime_set_error(handle->runtime, "array index must not be negative");
        return NULL;
    }

    quickjs_runtime_clear_error(handle->runtime);
    JSValue value = JS_GetPropertyUint32(handle->runtime->context, handle->value, (uint32_t)index);
    if (JS_IsException(value)) {
        JSValue exception = JS_GetException(handle->runtime->context);
        const char *message = JS_ToCString(handle->runtime->context, exception);
        quickjs_runtime_set_error(handle->runtime, message);
        JS_FreeCString(handle->runtime->context, message);
        JS_FreeValue(handle->runtime->context, exception);
        return NULL;
    }

    return quickjs_value_handle_create(handle->runtime, value);
}

int64_t quickjs_value_set_index(quickjs_value_handle *handle, int64_t index, quickjs_value_handle *value) {
    if (handle == NULL || handle->runtime == NULL || handle->runtime->context == NULL) {
        return 1;
    }
    if (index < 0) {
        quickjs_runtime_set_error(handle->runtime, "array index must not be negative");
        return 1;
    }
    if (value == NULL || value->runtime != handle->runtime) {
        quickjs_runtime_set_error(handle->runtime, "array value does not belong to this runtime");
        return 1;
    }

    quickjs_runtime_clear_error(handle->runtime);
    int status = JS_SetPropertyUint32(
        handle->runtime->context,
        handle->value,
        (uint32_t)index,
        JS_DupValue(handle->runtime->context, value->value));
    if (status < 0) {
        JSValue exception = JS_GetException(handle->runtime->context);
        const char *message = JS_ToCString(handle->runtime->context, exception);
        quickjs_runtime_set_error(handle->runtime, message);
        JS_FreeCString(handle->runtime->context, message);
        JS_FreeValue(handle->runtime->context, exception);
        return 1;
    }

    return 0;
}

int64_t quickjs_value_key_count(quickjs_value_handle *handle) {
    if (handle == NULL || handle->runtime == NULL || handle->runtime->context == NULL) {
        return -1;
    }

    JSPropertyEnum *properties = NULL;
    uint32_t property_count = 0;
    if (JS_GetOwnPropertyNames(
            handle->runtime->context,
            &properties,
            &property_count,
            handle->value,
            JS_GPN_STRING_MASK | JS_GPN_ENUM_ONLY) != 0) {
        quickjs_runtime_set_error(handle->runtime, "failed to enumerate JavaScript object keys");
        return -1;
    }

    JS_FreePropertyEnum(handle->runtime->context, properties, property_count);
    return (int64_t)property_count;
}

const char *quickjs_value_key_at(quickjs_value_handle *handle, int64_t index) {
    if (handle == NULL || handle->runtime == NULL || handle->runtime->context == NULL) {
        return NULL;
    }
    if (index < 0) {
        quickjs_runtime_set_error(handle->runtime, "key index must not be negative");
        return NULL;
    }

    JSPropertyEnum *properties = NULL;
    uint32_t property_count = 0;
    if (JS_GetOwnPropertyNames(
            handle->runtime->context,
            &properties,
            &property_count,
            handle->value,
            JS_GPN_STRING_MASK | JS_GPN_ENUM_ONLY) != 0) {
        quickjs_runtime_set_error(handle->runtime, "failed to enumerate JavaScript object keys");
        return NULL;
    }

    if ((uint64_t)index >= property_count) {
        JS_FreePropertyEnum(handle->runtime->context, properties, property_count);
        quickjs_runtime_set_error(handle->runtime, "key index is out of range");
        return NULL;
    }

    const char *atom_string = JS_AtomToCString(handle->runtime->context, properties[index].atom);
    if (atom_string == NULL) {
        JS_FreePropertyEnum(handle->runtime->context, properties, property_count);
        quickjs_runtime_set_error(handle->runtime, "failed to convert JavaScript object key");
        return NULL;
    }

    char *copy = quickjs_bridge_copy_string(atom_string);
    JS_FreeCString(handle->runtime->context, atom_string);
    JS_FreePropertyEnum(handle->runtime->context, properties, property_count);
    if (copy == NULL) {
        quickjs_runtime_set_error(handle->runtime, "failed to allocate JavaScript object key");
        return NULL;
    }

    return copy;
}

static quickjs_value_handle *quickjs_value_call_internal(
    quickjs_value_handle *function,
    JSValueConst this_value,
    int argc,
    JSValueConst *argv) {
    if (function == NULL || function->runtime == NULL || function->runtime->context == NULL) {
        return NULL;
    }

    quickjs_runtime_clear_error(function->runtime);
    JSValue result = JS_Call(function->runtime->context, function->value, this_value, argc, argv);
    if (JS_IsException(result)) {
        JSValue exception = JS_GetException(function->runtime->context);
        const char *message = JS_ToCString(function->runtime->context, exception);
        quickjs_runtime_set_error(function->runtime, message);
        JS_FreeCString(function->runtime->context, message);
        JS_FreeValue(function->runtime->context, exception);
        return NULL;
    }

    return quickjs_value_handle_create(function->runtime, result);
}

static quickjs_value_handle *quickjs_value_construct_internal(
    quickjs_value_handle *constructor,
    int argc,
    JSValueConst *argv) {
    if (constructor == NULL || constructor->runtime == NULL || constructor->runtime->context == NULL) {
        return NULL;
    }

    quickjs_runtime_clear_error(constructor->runtime);
    JSValue result = JS_CallConstructor(constructor->runtime->context, constructor->value, argc, argv);
    if (JS_IsException(result)) {
        JSValue exception = JS_GetException(constructor->runtime->context);
        const char *message = JS_ToCString(constructor->runtime->context, exception);
        quickjs_runtime_set_error(constructor->runtime, message);
        JS_FreeCString(constructor->runtime->context, message);
        JS_FreeValue(constructor->runtime->context, exception);
        return NULL;
    }

    return quickjs_value_handle_create(constructor->runtime, result);
}

quickjs_value_handle *quickjs_value_call0(quickjs_value_handle *function) {
    return quickjs_value_call_internal(function, JS_UNDEFINED, 0, NULL);
}

quickjs_value_handle *quickjs_value_call1(quickjs_value_handle *function, quickjs_value_handle *arg0) {
    if (function == NULL || arg0 == NULL || arg0->runtime != function->runtime) {
        return NULL;
    }

    JSValueConst argv[1] = {arg0->value};
    return quickjs_value_call_internal(function, JS_UNDEFINED, 1, argv);
}

quickjs_value_handle *quickjs_value_call2(quickjs_value_handle *function, quickjs_value_handle *arg0, quickjs_value_handle *arg1) {
    if (function == NULL || arg0 == NULL || arg1 == NULL || arg0->runtime != function->runtime || arg1->runtime != function->runtime) {
        return NULL;
    }

    JSValueConst argv[2] = {arg0->value, arg1->value};
    return quickjs_value_call_internal(function, JS_UNDEFINED, 2, argv);
}

quickjs_value_handle *quickjs_value_call_method0(quickjs_value_handle *function, quickjs_value_handle *this_value) {
    if (function == NULL || this_value == NULL || this_value->runtime != function->runtime) {
        return NULL;
    }

    return quickjs_value_call_internal(function, this_value->value, 0, NULL);
}

quickjs_value_handle *quickjs_value_call_method1(quickjs_value_handle *function, quickjs_value_handle *this_value, quickjs_value_handle *arg0) {
    if (function == NULL || this_value == NULL || arg0 == NULL || this_value->runtime != function->runtime || arg0->runtime != function->runtime) {
        return NULL;
    }

    JSValueConst argv[1] = {arg0->value};
    return quickjs_value_call_internal(function, this_value->value, 1, argv);
}

quickjs_value_handle *quickjs_value_call_method2(quickjs_value_handle *function, quickjs_value_handle *this_value, quickjs_value_handle *arg0, quickjs_value_handle *arg1) {
    if (function == NULL || this_value == NULL || arg0 == NULL || arg1 == NULL || this_value->runtime != function->runtime || arg0->runtime != function->runtime || arg1->runtime != function->runtime) {
        return NULL;
    }

    JSValueConst argv[2] = {arg0->value, arg1->value};
    return quickjs_value_call_internal(function, this_value->value, 2, argv);
}

quickjs_value_handle *quickjs_value_construct(quickjs_value_handle *constructor, quickjs_value_handle **args, int numArgs) {
    if (constructor == NULL) {
        return NULL;
    }

    JSValueConst argv[numArgs];
    for (int i = 0; i < numArgs; i++) {
        if (args[i] == NULL || args[i]->runtime != constructor->runtime) {
            return NULL;
        }
        argv[i] = args[i]->value;
    }
    return quickjs_value_construct_internal(constructor, numArgs, argv);
}