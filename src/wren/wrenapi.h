#ifndef WRENAPI_H
#define WRENAPI_H
#include <modules/pgl_wren.h>
#include <wren.h>

void pgl_wren_bind_method(const char* name, WrenForeignMethodFn func);
void pgl_wren_bind_class(const char* name, WrenForeignMethodFn allocator, WrenFinalizerFn finalizer);
void pgl_wren_bind_api();

#define pgl_wren_new(vm, T) (T*)wrenSetSlotNewForeign(vm, 0, 0, sizeof(T));

#endif