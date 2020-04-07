// CAUTION: Do this only once
#define STB_DS_IMPLEMENTATION
#include <stb/stb_ds.h>

#include <modules/platform.h>
#include "wrenapi.h"

typedef struct {
  char * key;
  WrenForeignMethodFn value;
} Binding;

typedef struct {
  char* key;
  WrenForeignClassMethods value;
} ClassBinding;

Binding* bindings = NULL;
ClassBinding* classBindings = NULL;

const void errorFunc(WrenVM *vm, WrenErrorType type, const char *module, int line, const char *message)
{  
  pglLog(PGL_MODULE_WREN, PGL_LOG_ERROR, "Module: %s Line:%i, %s", module, line, message);
}

void writeFunc(WrenVM *vm, const char *text)
{
  printf("%s", text);
}

static char* getMethodName(const char* module, 
  const char* className, 
  bool isStatic, 
  const char* signature)
{
  int length = strlen(module) + strlen(className) + strlen(signature) + 3;
  char *str = (char*)malloc(length);
  sprintf(str, "%s.%s.%s", module, className, signature);
  return str;
}

static char* getClassName(const char* module, 
  const char* className)
{
  int length = strlen(module) + strlen(className) + 2;
  char *str = (char*)malloc(length);
  sprintf(str, "%s.%s", module, className);
  return str;
}

static WrenForeignMethodFn bindMethodFunc( 
  WrenVM* vm, 
  const char* module, 
  const char* className, 
  bool isStatic, 
  const char* signature) 
{
  char* fullName = getMethodName(module, className, isStatic, signature);
  WrenForeignMethodFn func = shget(bindings, fullName);
  if(func == NULL){
    pglLog(PGL_MODULE_WREN, PGL_LOG_WARNING, "No binding registered for foreign method %s", fullName);
  }
  free(fullName);
  return func;
}

WrenForeignClassMethods bindClassFunc( 
  WrenVM* vm, 
  const char* module, 
  const char* className)
{
  char* fullName = getClassName(module, className);
  
  int index = shgeti(classBindings, fullName);
  free(fullName);
  if(index == -1){
    pglLog(PGL_MODULE_WREN, PGL_LOG_WARNING, "No binding registered for foreign class %s", fullName);
    WrenForeignClassMethods wfcm ={0};
    return wfcm;  
  }
  else {
    return classBindings[index].value;
  }
}

static char* loadModule(WrenVM* vm, const char* name){
  printf("should load Module %s\n", name);
  return NULL;
}

static WrenVM* vm;
static WrenHandle* gameClass;
static WrenHandle* updateMethod;
static WrenHandle* initMethod;
static WrenHandle* loadMethod;

void pglInitWren(const char * mainPath)
{
  WrenConfiguration config;
  wrenInitConfiguration(&config);
  
  config.errorFn = errorFunc;
  config.writeFn = writeFunc;
  config.bindForeignMethodFn = bindMethodFunc;
  config.loadModuleFn = loadModule;
  config.bindForeignClassFn = bindClassFunc;

  vm = wrenNewVM(&config); 
  
  pgl_wren_bind_api();
  pglRunWrenFile("json", "./scripts/json.wren");
  pglRunWrenFile("pgl", "./scripts/pgl.wren");
  pglRunWrenFile("gltf", "./scripts/gltf.wren");
  pglRunWrenFile("main", mainPath);

  wrenEnsureSlots(vm, 1); 
  wrenGetVariable(vm, "pgl", "Game", 0); 
  gameClass = wrenGetSlotHandle(vm, 0);
  updateMethod = wrenMakeCallHandle(vm, "update(_)");
  initMethod = wrenMakeCallHandle(vm, "init()");
  loadMethod = wrenMakeCallHandle(vm, "load()");
}

static void shutdown(){
  pglLog(PGL_MODULE_WREN, PGL_LOG_INFO, "Shutting down Wren VM");
  wrenFreeVM(vm);
  vm = NULL;
  
} 

void pglRunWrenFile(const char* module, const char* file){
  char* content = pglFileReadAllText(file);

  if(content == NULL){
    pglLog(PGL_MODULE_WREN, PGL_LOG_ERROR, "Script file not found: %s", file);
    return;
  }
  pglLog(PGL_MODULE_WREN, PGL_LOG_INFO, "Loaded module %s (%s)", module, file);

  WrenInterpretResult result = wrenInterpret(
      vm,
      module,
      content);

  free(content);

  if(result != WREN_RESULT_SUCCESS){
    shutdown();
    return;
  }
}

void pglCallWrenUpdate(double delta){
  if(vm != NULL){

    wrenEnsureSlots(vm, 2); 
    wrenSetSlotHandle(vm, 0, gameClass);
    wrenSetSlotDouble(vm, 1, delta);
    if(wrenCall(vm, updateMethod) != WREN_RESULT_SUCCESS){
      shutdown();
    }
  }
}

void pglCallWrenInit(){
  if(vm != NULL){

    wrenEnsureSlots(vm, 1); 
    wrenSetSlotHandle(vm, 0, gameClass);
    if(wrenCall(vm, initMethod) != WREN_RESULT_SUCCESS){
      shutdown();
    }
  }
}

void pglCallWrenLoad(){
  if(vm != NULL){

    wrenEnsureSlots(vm, 1); 
    wrenSetSlotHandle(vm, 0, gameClass);
    if(wrenCall(vm, loadMethod) != WREN_RESULT_SUCCESS){
      shutdown();
    }
  }
}

void pgl_wren_bind_method(const char* name, WrenForeignMethodFn func){
  shput(bindings, name, func);
}

void pgl_wren_bind_class(const char* name, WrenForeignMethodFn allocator, WrenFinalizerFn finalizer){
  WrenForeignClassMethods methods = {
    allocator = allocator,
    finalizer = finalizer
  };
  shput(classBindings, name, methods);
}