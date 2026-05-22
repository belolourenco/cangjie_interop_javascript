#include "quickjs_bridge.h"
#include "quickjs/quickjs.h"
#include "quickjs/quickjs-libc.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

enum {
    QUICKJS_VALUE_UNDEFINED,
    QUICKJS_VALUE_NULL,
    QUICKJS_VALUE_BOOL,
    QUICKJS_VALUE_NUMBER,
    QUICKJS_VALUE_STRING,
    QUICKJS_VALUE_BIGINT,
    QUICKJS_VALUE_OBJECT,
    QUICKJS_VALUE_FUNCTION,
};

struct module_cache_entry {
    char *path;
    JSValue namespace_value;
    struct module_cache_entry *next;
};

struct runtime_handle {
    JSRuntime *runtime;
    JSContext *context;
    char *last_error;
    struct module_cache_entry *module_cache;
    int std_module_enabled;
};

struct value_handle {
    runtime_handle *runtime;
    JSValue value;
};

static char *copy_string(const char *value) {
    if (value == NULL) {
        value = "unknown QuickJS error";
    }

    size_t length = strlen(value);
    char *copy = (char *)malloc(length + 1);
    if (copy != NULL) {
        memcpy(copy, value, length + 1);
    }
    return copy;
}

static void set_error(runtime_handle *runtime, const char *message) {
    if (runtime == NULL) {
        return;
    }

    free(runtime->last_error);
    runtime->last_error = copy_string(message);
}

static void clear_error(runtime_handle *runtime) {
    if (runtime == NULL) {
        return;
    }

    free(runtime->last_error);
    runtime->last_error = NULL;
}

static void capture_exception(runtime_handle *runtime) {
    if (runtime == NULL || runtime->context == NULL) {
        return;
    }

    JSValue exception = JS_GetException(runtime->context);
    const char *message = JS_ToCString(runtime->context, exception);
    set_error(runtime, message);
    JS_FreeCString(runtime->context, message);
    JS_FreeValue(runtime->context, exception);
}

static int valid_runtime(runtime_handle *runtime) {
    return runtime != NULL && runtime->runtime != NULL && runtime->context != NULL;
}

static int valid_value(value_handle *value) {
    return value != NULL && valid_runtime(value->runtime);
}

static value_handle *new_value_handle(runtime_handle *runtime, JSValue value) {
    if (!valid_runtime(runtime)) {
        return NULL;
    }

    value_handle *handle = (value_handle *)calloc(1, sizeof(value_handle));
    if (handle == NULL) {
        JS_FreeValue(runtime->context, value);
        set_error(runtime, "failed to allocate JavaScript value handle");
        return NULL;
    }

    handle->runtime = runtime;
    handle->value = value;
    return handle;
}

static JSValue new_mutable_namespace_object(runtime_handle *handle, JSValueConst namespace_value) {
    JSContext *ctx = handle->context;
    JSValue object = JS_NewObject(ctx);
    if (JS_IsException(object)) {
        return JS_EXCEPTION;
    }

    JSPropertyEnum *properties = NULL;
    uint32_t property_count = 0;
    int status = JS_GetOwnPropertyNames(
        ctx,
        &properties,
        &property_count,
        namespace_value,
        JS_GPN_STRING_MASK | JS_GPN_ENUM_ONLY);
    if (status < 0) {
        JS_FreeValue(ctx, object);
        return JS_EXCEPTION;
    }

    for (uint32_t i = 0; i < property_count; i++) {
        JSValue value = JS_GetProperty(ctx, namespace_value, properties[i].atom);
        if (JS_IsException(value)) {
            JS_FreePropertyEnum(ctx, properties, property_count);
            JS_FreeValue(ctx, object);
            return JS_EXCEPTION;
        }

        status = JS_DefinePropertyValue(ctx, object, properties[i].atom, value, JS_PROP_C_W_E);
        if (status < 0) {
            JS_FreePropertyEnum(ctx, properties, property_count);
            JS_FreeValue(ctx, object);
            return JS_EXCEPTION;
        }
    }

    JS_FreePropertyEnum(ctx, properties, property_count);
    return object;
}

static unsigned char *read_file(const char *path, size_t *length) {
    FILE *file = fopen(path, "rb");
    if (file == NULL) {
        return NULL;
    }

    if (fseek(file, 0, SEEK_END) != 0) {
        fclose(file);
        return NULL;
    }

    long size = ftell(file);
    if (size < 0 || fseek(file, 0, SEEK_SET) != 0) {
        fclose(file);
        return NULL;
    }

    unsigned char *buffer = (unsigned char *)malloc((size_t)size + 1);
    if (buffer == NULL) {
        fclose(file);
        return NULL;
    }

    size_t read_count = fread(buffer, 1, (size_t)size, file);
    fclose(file);
    if (read_count != (size_t)size) {
        free(buffer);
        return NULL;
    }

    buffer[size] = '\0';
    *length = (size_t)size;
    return buffer;
}

runtime_handle *runtime_create(void) {
    runtime_handle *handle = (runtime_handle *)calloc(1, sizeof(runtime_handle));
    if (handle == NULL) {
        return NULL;
    }

    handle->runtime = JS_NewRuntime();
    handle->context = handle->runtime == NULL ? NULL : JS_NewContext(handle->runtime);
    if (handle->context == NULL) {
        if (handle->runtime != NULL) {
            JS_FreeRuntime(handle->runtime);
        }
        free(handle);
        return NULL;
    }

    return handle;
}

const char *runtime_last_error(runtime_handle *handle) {
    return handle == NULL || handle->last_error == NULL ? "" : handle->last_error;
}

int64_t runtime_enable_std_module(runtime_handle *handle) {
    if (!valid_runtime(handle)) {
        return 1;
    }
    if (handle->std_module_enabled) {
        return 0;
    }

    clear_error(handle);
    JS_SetModuleLoaderFunc2(handle->runtime, NULL, js_module_loader, js_module_check_attributes, NULL);
    if (js_init_module_std(handle->context, "std") == NULL) {
        capture_exception(handle);
        return 1;
    }

    handle->std_module_enabled = 1;
    return 0;
}

value_handle *runtime_eval_value(runtime_handle *handle, const char *source) {
    if (!valid_runtime(handle)) {
        return NULL;
    }
    if (source == NULL) {
        set_error(handle, "source must not be null");
        return NULL;
    }

    clear_error(handle);
    JSValue value = JS_Eval(handle->context, source, strlen(source), "<eval>", JS_EVAL_TYPE_GLOBAL);
    if (JS_IsException(value)) {
        capture_exception(handle);
        return NULL;
    }

    return new_value_handle(handle, value);
}

value_handle *runtime_get_global_property(runtime_handle *handle, const char *name) {
    if (!valid_runtime(handle)) {
        return NULL;
    }
    if (name == NULL) {
        set_error(handle, "global property name must not be null");
        return NULL;
    }

    clear_error(handle);
    JSValue global = JS_GetGlobalObject(handle->context);
    JSValue value = JS_GetPropertyStr(handle->context, global, name);
    JS_FreeValue(handle->context, global);
    if (JS_IsException(value)) {
        capture_exception(handle);
        return NULL;
    }

    return new_value_handle(handle, value);
}

value_handle *runtime_new_bool(runtime_handle *handle, int64_t value) {
    if (!valid_runtime(handle)) {
        return NULL;
    }

    clear_error(handle);
    return new_value_handle(handle, JS_NewBool(handle->context, value != 0));
}

value_handle *runtime_new_number(runtime_handle *handle, double value) {
    if (!valid_runtime(handle)) {
        return NULL;
    }

    clear_error(handle);
    return new_value_handle(handle, JS_NewFloat64(handle->context, value));
}

value_handle *runtime_new_string(runtime_handle *handle, const char *value) {
    if (!valid_runtime(handle)) {
        return NULL;
    }
    if (value == NULL) {
        set_error(handle, "string value must not be null");
        return NULL;
    }

    clear_error(handle);
    JSValue js_value = JS_NewString(handle->context, value);
    if (JS_IsException(js_value)) {
        capture_exception(handle);
        return NULL;
    }

    return new_value_handle(handle, js_value);
}

value_handle *runtime_import_module(runtime_handle *handle, const char *path) {
    if (!valid_runtime(handle)) {
        return NULL;
    }
    if (path == NULL) {
        set_error(handle, "module path must not be null");
        return NULL;
    }

    clear_error(handle);
    for (struct module_cache_entry *entry = handle->module_cache; entry != NULL; entry = entry->next) {
        if (strcmp(entry->path, path) == 0) {
            return new_value_handle(handle, JS_DupValue(handle->context, entry->namespace_value));
        }
    }

    size_t source_length = 0;
    unsigned char *source = read_file(path, &source_length);
    if (source == NULL) {
        set_error(handle, "failed to read JavaScript module file");
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
        capture_exception(handle);
        return NULL;
    }

    if (JS_ResolveModule(handle->context, compiled) < 0) {
        JS_FreeValue(handle->context, compiled);
        capture_exception(handle);
        return NULL;
    }

    JSModuleDef *module = (JSModuleDef *)JS_VALUE_GET_PTR(compiled);
    JSValue eval_result = JS_EvalFunction(handle->context, compiled);
    if (JS_IsException(eval_result)) {
        capture_exception(handle);
        return NULL;
    }
    JS_FreeValue(handle->context, eval_result);

    JSValue namespace_value = JS_GetModuleNamespace(handle->context, module);
    if (JS_IsException(namespace_value)) {
        capture_exception(handle);
        return NULL;
    }

    JSValue mutable_namespace = new_mutable_namespace_object(handle, namespace_value);
    JS_FreeValue(handle->context, namespace_value);
    if (JS_IsException(mutable_namespace)) {
        capture_exception(handle);
        return NULL;
    }

    struct module_cache_entry *entry = (struct module_cache_entry *)calloc(1, sizeof(struct module_cache_entry));
    if (entry == NULL) {
        JS_FreeValue(handle->context, mutable_namespace);
        set_error(handle, "failed to allocate JavaScript module cache entry");
        return NULL;
    }

    entry->path = copy_string(path);
    if (entry->path == NULL) {
        free(entry);
        JS_FreeValue(handle->context, mutable_namespace);
        set_error(handle, "failed to allocate JavaScript module path");
        return NULL;
    }

    entry->namespace_value = JS_DupValue(handle->context, mutable_namespace);
    entry->next = handle->module_cache;
    handle->module_cache = entry;

    return new_value_handle(handle, mutable_namespace);
}

void value_destroy(value_handle *handle) {
    if (handle == NULL) {
        return;
    }

    if (valid_runtime(handle->runtime)) {
        JS_FreeValue(handle->runtime->context, handle->value);
    }
    free(handle);
}

int64_t value_kind(value_handle *handle) {
    if (!valid_value(handle)) {
        return QUICKJS_VALUE_UNDEFINED;
    }

    JSContext *ctx = handle->runtime->context;
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
    if (JS_IsBigInt(ctx, handle->value)) {
        return QUICKJS_VALUE_BIGINT;
    }
    if (JS_IsFunction(ctx, handle->value)) {
        return QUICKJS_VALUE_FUNCTION;
    }
    if (JS_IsObject(handle->value)) {
        return QUICKJS_VALUE_OBJECT;
    }

    return QUICKJS_VALUE_UNDEFINED;
}

int64_t value_to_bool(value_handle *handle) {
    if (!valid_value(handle)) {
        return 0;
    }

    int value = JS_ToBool(handle->runtime->context, handle->value);
    if (value < 0) {
        set_error(handle->runtime, "failed to convert JavaScript value to boolean");
        return 0;
    }
    return value ? 1 : 0;
}

double value_to_number(value_handle *handle) {
    if (!valid_value(handle)) {
        return 0.0;
    }

    double value = 0.0;
    if (JS_ToFloat64(handle->runtime->context, &value, handle->value) != 0) {
        set_error(handle->runtime, "failed to convert JavaScript value to number");
        return 0.0;
    }
    return value;
}

const char *value_to_string(value_handle *handle) {
    if (!valid_value(handle)) {
        return NULL;
    }

    const char *value = JS_ToCString(handle->runtime->context, handle->value);
    if (value == NULL) {
        set_error(handle->runtime, "failed to convert JavaScript value to string");
        return NULL;
    }

    char *copy = copy_string(value);
    JS_FreeCString(handle->runtime->context, value);
    if (copy == NULL) {
        set_error(handle->runtime, "failed to allocate JavaScript string result");
    }
    return copy;
}

void bridge_free_string(const char *value) {
    free((void *)value);
}

int64_t value_is_array(value_handle *handle) {
    return valid_value(handle) && JS_IsArray(handle->runtime->context, handle->value) ? 1 : 0;
}

int64_t value_array_length(value_handle *handle) {
    if (!valid_value(handle)) {
        return -1;
    }

    JSValue length = JS_GetPropertyStr(handle->runtime->context, handle->value, "length");
    if (JS_IsException(length)) {
        capture_exception(handle->runtime);
        return -1;
    }

    double number = 0.0;
    int status = JS_ToFloat64(handle->runtime->context, &number, length);
    JS_FreeValue(handle->runtime->context, length);
    if (status != 0) {
        set_error(handle->runtime, "failed to convert JavaScript array length");
        return -1;
    }

    return (int64_t)number;
}

value_handle *value_get_property(value_handle *handle, const char *name) {
    if (!valid_value(handle)) {
        return NULL;
    }
    if (name == NULL) {
        set_error(handle->runtime, "property name must not be null");
        return NULL;
    }

    clear_error(handle->runtime);
    JSValue value = JS_GetPropertyStr(handle->runtime->context, handle->value, name);
    if (JS_IsException(value)) {
        capture_exception(handle->runtime);
        return NULL;
    }

    return new_value_handle(handle->runtime, value);
}

int64_t value_set_property(value_handle *handle, const char *name, value_handle *value) {
    if (!valid_value(handle)) {
        return 1;
    }
    if (name == NULL) {
        set_error(handle->runtime, "property name must not be null");
        return 1;
    }
    if (value == NULL || value->runtime != handle->runtime) {
        set_error(handle->runtime, "property value does not belong to this runtime");
        return 1;
    }

    clear_error(handle->runtime);
    int status = JS_SetPropertyStr(
        handle->runtime->context,
        handle->value,
        name,
        JS_DupValue(handle->runtime->context, value->value));
    if (status < 0) {
        capture_exception(handle->runtime);
        return 1;
    }

    return 0;
}

value_handle *value_get_index(value_handle *handle, int64_t index) {
    if (!valid_value(handle)) {
        return NULL;
    }
    if (index < 0) {
        set_error(handle->runtime, "array index must not be negative");
        return NULL;
    }

    clear_error(handle->runtime);
    JSValue value = JS_GetPropertyUint32(handle->runtime->context, handle->value, (uint32_t)index);
    if (JS_IsException(value)) {
        capture_exception(handle->runtime);
        return NULL;
    }

    return new_value_handle(handle->runtime, value);
}

int64_t value_set_index(value_handle *handle, int64_t index, value_handle *value) {
    if (!valid_value(handle)) {
        return 1;
    }
    if (index < 0) {
        set_error(handle->runtime, "array index must not be negative");
        return 1;
    }
    if (value == NULL || value->runtime != handle->runtime) {
        set_error(handle->runtime, "array value does not belong to this runtime");
        return 1;
    }

    clear_error(handle->runtime);
    int status = JS_SetPropertyUint32(
        handle->runtime->context,
        handle->value,
        (uint32_t)index,
        JS_DupValue(handle->runtime->context, value->value));
    if (status < 0) {
        capture_exception(handle->runtime);
        return 1;
    }

    return 0;
}

static int fill_argv(value_handle *owner, value_handle **args, int num_args, JSValueConst *argv) {
    if (!valid_value(owner)) {
        return 1;
    }
    if (num_args < 0) {
        set_error(owner->runtime, "argument count must not be negative");
        return 1;
    }
    if (num_args > 0 && args == NULL) {
        set_error(owner->runtime, "argument array must not be null");
        return 1;
    }

    for (int i = 0; i < num_args; i++) {
        if (args[i] == NULL || args[i]->runtime != owner->runtime) {
            set_error(owner->runtime, "argument does not belong to this runtime");
            return 1;
        }
        argv[i] = args[i]->value;
    }

    return 0;
}

value_handle *value_call(
    value_handle *function,
    value_handle *this_value,
    value_handle **args,
    int num_args) {
    if (!valid_value(function)) {
        return NULL;
    }
    if (this_value != NULL && this_value->runtime != function->runtime) {
        set_error(function->runtime, "this value does not belong to this runtime");
        return NULL;
    }
    if (num_args < 0) {
        set_error(function->runtime, "argument count must not be negative");
        return NULL;
    }

    JSValueConst argv[num_args > 0 ? num_args : 1];
    if (fill_argv(function, args, num_args, argv) != 0) {
        return NULL;
    }

    clear_error(function->runtime);
    JSValue result = JS_Call(
        function->runtime->context,
        function->value,
        this_value == NULL ? JS_UNDEFINED : this_value->value,
        num_args,
        num_args > 0 ? argv : NULL);
    if (JS_IsException(result)) {
        capture_exception(function->runtime);
        return NULL;
    }

    return new_value_handle(function->runtime, result);
}

value_handle *value_construct(
    value_handle *constructor,
    value_handle **args,
    int num_args) {
    if (!valid_value(constructor)) {
        return NULL;
    }
    if (num_args < 0) {
        set_error(constructor->runtime, "argument count must not be negative");
        return NULL;
    }

    JSValueConst argv[num_args > 0 ? num_args : 1];
    if (fill_argv(constructor, args, num_args, argv) != 0) {
        return NULL;
    }

    clear_error(constructor->runtime);
    JSValue result = JS_CallConstructor(
        constructor->runtime->context,
        constructor->value,
        num_args,
        num_args > 0 ? argv : NULL);
    if (JS_IsException(result)) {
        capture_exception(constructor->runtime);
        return NULL;
    }

    return new_value_handle(constructor->runtime, result);
}
