#include "quickjs_bridge.h"
#include "quickjs/quickjs.h"

int64_t quickjs_bridge_smoke(void) {
    JSRuntime *runtime = NULL;
    return runtime == NULL ? 1 : 0;
}

