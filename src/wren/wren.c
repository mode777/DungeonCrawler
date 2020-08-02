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
char strbuffer[1024];

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
  if(strcmp(module, "random") == 0 || strcmp(module, "meta") == 0){
    return NULL;
  }
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
  if(strcmp(module, "random") == 0 || strcmp(module, "meta") == 0){
    WrenForeignClassMethods wfcm ={0};
    return wfcm;
  }

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
  strcpy(strbuffer, name);
  strcat(strbuffer, ".wren");

  PGLFile* file = pglFileOpen(strbuffer, "rb");
  
  if(file != NULL){
    size_t read;
    return pglFileReadString(file, pglFileSize(file), &read);
  }

  strcpy(strbuffer, "./scripts/");
  strcat(strbuffer, name);
  strcat(strbuffer, ".wren");
  
  file = pglFileOpen(strbuffer, "rb");
  if(file != NULL){
    size_t read;
    return pglFileReadString(file, pglFileSize(file), &read);
  }

  return NULL;
}

static WrenVM* vm;
static WrenHandle* appClass;
static WrenHandle* updateMethod;
static WrenHandle* initMethod;
static WrenHandle* loadMethod;
static int myargc;
static char** myargv;

void pglInitWren(int argc, char **argv)
{
  myargc = argc;
  myargv = argv;

  const char* mainPath;
  if(argc == 2){
    mainPath = argv[1];
  }
  else {
    pglLog(PGL_MODULE_CORE, PGL_LOG_WARNING, "Falling back to default script");
    mainPath = "./main.wren";
  }

  WrenConfiguration config;
  wrenInitConfiguration(&config);
  
  config.errorFn = errorFunc;
  config.writeFn = writeFunc;
  config.bindForeignMethodFn = bindMethodFunc;
  config.loadModuleFn = loadModule;
  config.bindForeignClassFn = bindClassFunc;

  vm = wrenNewVM(&config); 
  
  pgl_wren_bind_api();
  //pglRunWrenFile("application", "./scripts/application.wren");
  pglRunWrenFile("main", mainPath);

  if(vm == NULL)
    return;

  wrenEnsureSlots(vm, 1); 
  //TODO: This will SEGFAULT if platform module is not loaded
  wrenGetVariable(vm, "platform", "Application", 0); 

  appClass = wrenGetSlotHandle(vm, 0);
  updateMethod = wrenMakeCallHandle(vm, "update(_)");
  initMethod = wrenMakeCallHandle(vm, "init(_)");
  loadMethod = wrenMakeCallHandle(vm, "load()");
}

static void shutdown(){
  pglLog(PGL_MODULE_WREN, PGL_LOG_INFO, "Shutting down Wren VM");
  wrenFreeVM(vm);
  vm = NULL;
  pglQuit();  
} 

bool pglRunWrenFile(const char* module, const char* file){
  if(vm == NULL)
    return false;

  char* content = pglFileReadAllText(file);

  if(content == NULL){
    pglLog(PGL_MODULE_WREN, PGL_LOG_ERROR, "Script file not found: %s", file);
    return false;
  }
  pglLog(PGL_MODULE_WREN, PGL_LOG_INFO, "Loaded module %s (%s)", module, file);

  WrenInterpretResult result = wrenInterpret(
      vm,
      module,
      content);


  free(content);

  if(result != WREN_RESULT_SUCCESS){
    shutdown();
    return false;
  }

  return true;
}

void pglCallWrenUpdate(double delta){
  if(vm != NULL){

    wrenEnsureSlots(vm, 2); 
    wrenSetSlotHandle(vm, 0, appClass);
    wrenSetSlotDouble(vm, 1, delta);
    if(wrenCall(vm, updateMethod) != WREN_RESULT_SUCCESS){
      shutdown();
    }
  }
}

void pglCallWrenInit(){
  if(vm != NULL){

    wrenEnsureSlots(vm, 2); 
    wrenSetSlotNewList(vm, 1);
    for (int i = 0; i < myargc; i++)
    {
      wrenSetSlotString(vm, 0, myargv[i]);
      wrenInsertInList(vm, 1, -1, 0);
    }
    wrenSetSlotHandle(vm, 0, appClass);
    
    if(wrenCall(vm, initMethod) != WREN_RESULT_SUCCESS){
      shutdown();
    }
  }
}

void pglCallWrenLoad(){
  if(vm != NULL){

    wrenEnsureSlots(vm, 1); 
    wrenSetSlotHandle(vm, 0, appClass);
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