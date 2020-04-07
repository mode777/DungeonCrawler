#include "wrenapi.h"
#include <modules/pgl_json.h>

typedef struct {
  PGLJSONParser* parser;
  WrenHandle* contentHandle;
  WrenVM* vm;
} JsonParserData;

static void JSONParser_allocate(WrenVM* vm){
  JsonParserData* parserData = pgl_wren_new(vm, JsonParserData); 
  const char* content = wrenGetSlotString(vm, 1); 
  parserData->contentHandle = wrenGetSlotHandle(vm, 1);
  parserData->parser = pglJsonCreateParser(content);  
  parserData->vm = vm;
  if(parserData->parser == NULL){
    pgl_wren_runtime_error(vm, "Invalid JSON");
  }
}

static void JSONParser_finalize(void* handle){
  JsonParserData* data = (JsonParserData*)handle;
  pglJsonDestroyParser(data->parser);
  wrenReleaseHandle(data->vm, data->contentHandle);
}

static void JSONParser_getValue_0(WrenVM* vm){
    JsonParserData* data = (JsonParserData*)wrenGetSlotForeign(vm, 0);
    switch (pglJsonGetToken(data->parser))
    {
      case PGL_JSON_NUMBER: 
        wrenSetSlotDouble(vm, 0, pglJsonGetDoubleVal(data->parser));
        break;
      case PGL_JSON_STRING: {
        char* str = pglJsonGetStringVal(data->parser);
        wrenSetSlotString(vm, 0, str);
        free(str);
        break;      
      }
      case PGL_JSON_BOOLEAN: 
        wrenSetSlotBool(vm, 0, pglJsonGetBoolVal(data->parser));
        break;
      case PGL_JSON_NULL:
        wrenSetSlotNull(vm, 0);
        break;
      default:
        pgl_wren_runtime_error(vm, "Current token is not a primitive value type");
        break;
  } 
}

static void JSONParser_getToken_0(WrenVM* vm){
  JsonParserData* data = (JsonParserData*)wrenGetSlotForeign(vm, 0);
  wrenSetSlotDouble(vm, 0, (double)pglJsonGetToken(data->parser));
}

static void JSONParser_nextToken_0(WrenVM* vm){
  JsonParserData* data = (JsonParserData*)wrenGetSlotForeign(vm, 0);
  wrenSetSlotBool(vm, 0, pglJsonNextToken(data->parser));
}

static void JSONParser_getChildren_0(WrenVM* vm){
  JsonParserData* data = (JsonParserData*)wrenGetSlotForeign(vm, 0);
  wrenSetSlotDouble(vm, 0, (double)pglJsonGetChildTokens(data->parser));
}