#include "wrenapi.h"
#include <modules/renderer3d.h>
#include <modules/platform.h>
#include <modules/pgl_json.h>
#include <modules/image.h>

static void runtime_error(WrenVM* vm, const char * error){
  wrenSetSlotString(vm, 0, error); 
  wrenAbortFiber(vm, 0);
}

#define wren_new(T) (T*)wrenSetSlotNewForeign(vm, 0, 0, sizeof(T));

void Camera_orbit_2(WrenVM* vm){
  float rad = (float)wrenGetSlotDouble(vm, 1); 
  float g = (float)wrenGetSlotDouble(vm, 2);
  pgl3DOrbitCamera(rad, g); 
}

void Keyboard_isDown_1(WrenVM* vm){
  const char* key = wrenGetSlotString(vm, 1);
  bool result = pglIsKeyDown(key);
  wrenSetSlotBool(vm, 0, result);
}

void Window_config_3(WrenVM* vm){
  PGLWindowConfig win = {0};
  win.width = (size_t)wrenGetSlotDouble(vm, 1);
  win.height = (size_t)wrenGetSlotDouble(vm, 2);
  win.title = wrenGetSlotString(vm, 3);
  pglWindowConfig(&win);
}

void Renderer_render_1(WrenVM* vm){
  PGLPrimitive* prim = *(PGLPrimitive**)wrenGetSlotForeign(vm, 1);
  pgl3DDrawPrimitive(prim);
}

void Renderer_setTransform_1(WrenVM* vm){
  PGLTransform* t = *(PGLTransform**)wrenGetSlotForeign(vm, 1);
  pgl3DSetModelTransform(t);
}

void Camera_setTransform_1(WrenVM* vm){
  PGLTransform* t = *(PGLTransform**)wrenGetSlotForeign(vm, 1);
  pgl3DSetCameraTransform(t);
}

void File_allocate(WrenVM* vm){
  PGLFile* file = wren_new(PGLFile); 
  const char* path = wrenGetSlotString(vm, 1); 
  const char* mode = wrenGetSlotString(vm, 2); 
  *file = pglFileOpen(path, mode);
}

static void closeFile(PGLFile* file) 
{ 
  // Already closed.
  if (*file == NULL) return;

  fclose(*file); 
  *file = NULL; 
}

void File_finalize(void* data){
  closeFile((PGLFile*) data);
}

void File_length_0(WrenVM* vm){
  PGLFile* file = (PGLFile*)wrenGetSlotForeign(vm, 0);
  if(*file == NULL){
    runtime_error(vm, "File does not exist");
    return;
  }

  long size = pglFileSize(*file);
  wrenSetSlotDouble(vm, 0, (double)size);
}

void File_close_0(WrenVM* vm){
  PGLFile* file = (PGLFile*)wrenGetSlotForeign(vm, 0);
  closeFile(file);
}

void File_read_1(WrenVM* vm){
  PGLFile* file = (PGLFile*)wrenGetSlotForeign(vm, 0);
  long length = (long)wrenGetSlotDouble(vm, 1);
  if(*file == NULL){
    runtime_error(vm, "File does not exist");
    return;
  }
  size_t read;
  char* buffer = pglFileReadBytes(*file, length, &read);
  wrenSetSlotBytes(vm, 0, buffer, read);
  free(buffer);
}

typedef struct {
  PGLJSONParser* parser;
  WrenHandle* contentHandle;
  WrenVM* vm;
} JsonParserData;

static void JSONParser_allocate(WrenVM* vm){
  JsonParserData* parserData = wren_new(JsonParserData); 
  const char* content = wrenGetSlotString(vm, 1); 
  parserData->contentHandle = wrenGetSlotHandle(vm, 1);
  parserData->parser = pglJsonCreateParser(content);  
  parserData->vm = vm;
  if(parserData->parser == NULL){
    runtime_error(vm, "Invalid JSON");
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
        runtime_error(vm, "Current token is not a primitive value type");
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

static void Image_allocate(WrenVM* vm){
  PGLImage** file = wren_new(PGLImage*); 
  pglLog(PGL_MODULE_WREN, PGL_LOG_DEBUG, "Allocated Image %p", file);  
  const char* path = wrenGetSlotString(vm, 1); 
  int channels = (int)wrenGetSlotDouble(vm, 2); 
  *file = pglLoadImage(path, channels);

  if(*file == NULL){
    runtime_error(vm, "Image does not exist");
  }
}

static void Image_finalize(void* data){
  pglLog(PGL_MODULE_WREN, PGL_LOG_DEBUG, "Free Image %p", data);  
  PGLImage** img = data;
  pglDestroyImage(*img);
}

static void Buffer_allocate(WrenVM* vm){
  char** handle = wren_new(char*); 
  pglLog(PGL_MODULE_WREN, PGL_LOG_DEBUG, "Allocated Buffer %p", handle);  
  const char* path = wrenGetSlotString(vm, 1); 
  *handle = pglFileReadAllBytes(path);
  
  if(*handle == NULL){
    runtime_error(vm, "File does not exist");
    return;
  }
}

static void Buffer_finalize(void* data){
  pglLog(PGL_MODULE_WREN, PGL_LOG_DEBUG, "Free Buffer %p", data);
  free(*((char**)data));
}

static void GeometryBuffer_allocate(WrenVM* vm){
  char* data = *(char**)wrenGetSlotForeign(vm, 1);
  int offset = (int)wrenGetSlotDouble(vm, 2);
  int size = (int)wrenGetSlotDouble(vm, 3);
  GLsizei stride = (GLsizei)wrenGetSlotDouble(vm, 4);  
  bool areIndices = wrenGetSlotBool(vm, 5);

  PGLGeometryBuffer* buffer = pglCreateGeometryBuffer(data, offset, size, stride, areIndices);
  
  PGLGeometryBuffer** foreign = wren_new(PGLGeometryBuffer*);
  pglLog(PGL_MODULE_WREN, PGL_LOG_DEBUG, "Allocated GeometryBuffer %p", foreign);
  *foreign = buffer;
}

static void GeometryBuffer_finalize(void* data){
  pglLog(PGL_MODULE_WREN, PGL_LOG_DEBUG, "Free GeometryBuffer %p", data);
  PGLGeometryBuffer* buffer = *(PGLGeometryBuffer**)data;
  pglReleaseGeometryBuffer(buffer);
}

static void Texture_allocate(WrenVM* vm){
  
  PGLImage* img = *((PGLImage**)wrenGetSlotForeign(vm, 1));
  
  PGLTexture* wrapper = pglCreateTexture(img);

  PGLTexture** wrenHandle = wren_new(PGLTexture*);
  pglLog(PGL_MODULE_WREN, PGL_LOG_DEBUG, "Allocated Texture %p", wrenHandle);
  *wrenHandle = wrapper;
}

static void Texture_finalize(void* data){
  pglLog(PGL_MODULE_WREN, PGL_LOG_DEBUG, "Free Texture %p", data);
  PGLTexture* texture = *(PGLTexture**)data;
  pglReleaseTexture(texture);
}

static void Attribute_allocate(WrenVM* vm){

  PGLAttribute* attribute = calloc(1, sizeof(PGLAttribute));

  attribute->buffer = pglTakeGeometryBuffer(*(PGLGeometryBuffer**)wrenGetSlotForeign(vm, 1));
  attribute->attributeType = (PGLAttributeType)wrenGetSlotDouble(vm, 2);
  attribute->componentType = (GLenum)wrenGetSlotDouble(vm, 3);
  attribute->numComponents = (GLubyte)wrenGetSlotDouble(vm, 4);
  attribute->offset = (GLuint)wrenGetSlotDouble(vm, 5);
  attribute->normalized = (GLboolean)wrenGetSlotBool(vm, 6);
  attribute->count = (GLsizei)wrenGetSlotDouble(vm, 7);
  
  PGLAttribute** foreign = wren_new(PGLAttribute*);
  pglLog(PGL_MODULE_WREN, PGL_LOG_DEBUG, "Allocated Attribute %p", foreign);
  *foreign = attribute;
}

static void Attribute_finalize(void* data){
  pglLog(PGL_MODULE_WREN, PGL_LOG_DEBUG, "Free Attribute %p", data);
  PGLAttribute* attribute = *(PGLAttribute**)data;
  pglReleaseGeometryBuffer(attribute->buffer);
  free(attribute);
}

static void Material_allocate(WrenVM* vm){

  PGLMaterial* material = calloc(1, sizeof(PGLMaterial));

  PGLTexture* texture = *(PGLTexture**)wrenGetSlotForeign(vm, 1);
  material->diffuse = pglTakeTexture(texture);
  
  PGLMaterial** foreign = wren_new(PGLMaterial*);
  pglLog(PGL_MODULE_WREN, PGL_LOG_DEBUG, "Allocate Material %p", foreign);
  *foreign = material;  
}

static void Material_finalize(void* data){
  pglLog(PGL_MODULE_WREN, PGL_LOG_DEBUG, "Free Material %p", data);
  PGLMaterial* mat = *(PGLMaterial**)data;
  pglReleaseTexture(mat->diffuse);
  free(mat);
}

static void Primitive_allocate(WrenVM* vm){
  PGLPrimitive* prim = calloc(1, sizeof(PGLPrimitive));

  PGLAttribute* indexAttribute = *(PGLAttribute**)wrenGetSlotForeign(vm, 1);
  prim->index = *indexAttribute;
  pglTakeGeometryBuffer(prim->index.buffer);
  prim->attributeCount = wrenGetListCount(vm, 2);
  prim->attributes = calloc(prim->attributeCount, sizeof(PGLAttribute));
  for (size_t i = 0; i < prim->attributeCount; i++)
  {
    wrenGetListElement(vm, 2, i, 1);
    PGLAttribute attr = **(PGLAttribute**)wrenGetSlotForeign(vm, 1);
    prim->attributes[i] = attr; 
    pglTakeGeometryBuffer(prim->attributes[i].buffer);    
  }

  prim->material = **(PGLMaterial**)wrenGetSlotForeign(vm, 3);
  pglLog(PGL_MODULE_WREN, PGL_LOG_DEBUG, "Allocate Primitve %p", prim->material);
  pglTakeTexture(prim->material.diffuse);
  PGLPrimitive** foreign = wren_new(PGLPrimitive*);
  *foreign = prim;
}

static void Primitive_finalize(void* data){
  pglLog(PGL_MODULE_WREN, PGL_LOG_DEBUG, "Free Primitve", data);
  PGLPrimitive* prim = *(PGLPrimitive**)data;
  pglReleaseGeometryBuffer(prim->index.buffer);
  pglReleaseTexture(prim->material.diffuse);
  for (size_t i = 0; i < prim->attributeCount; i++)
  {
    pglReleaseGeometryBuffer(prim->attributes[i].buffer);
  }
  free(prim);
}

static void Transform_allocate(WrenVM* vm){
  PGLTransform* t = pglTransformCreate();
  PGLTransform** handle = wren_new(PGLTransform*);
  *handle = t;
}

static void Transform_finalize(void* data){
  PGLTransform* t = *(PGLTransform**)data;
  pglTransformDelete(t);
}

static void Transform_translate_3(WrenVM* vm){
  PGLTransform* t = *(PGLTransform**)wrenGetSlotForeign(vm,0);
  float x = (float)wrenGetSlotDouble(vm, 1);
  float y = (float)wrenGetSlotDouble(vm, 2);
  float z = (float)wrenGetSlotDouble(vm, 3);
  pglTransformTranslate(t, x, y, z);
}

static void Transform_rotate_3(WrenVM* vm){
  PGLTransform* t = *(PGLTransform**)wrenGetSlotForeign(vm,0);
  float x = (float)wrenGetSlotDouble(vm, 1);
  float y = (float)wrenGetSlotDouble(vm, 2);
  float z = (float)wrenGetSlotDouble(vm, 3);
  pglTransformRotate(t, x, y, z);
}

static void Transform_scale_3(WrenVM* vm){
  PGLTransform* t = *(PGLTransform**)wrenGetSlotForeign(vm,0);
  float x = (float)wrenGetSlotDouble(vm, 1);
  float y = (float)wrenGetSlotDouble(vm, 2);
  float z = (float)wrenGetSlotDouble(vm, 3);
  pglTransformScale(t, x, y, z);
}

static void Transform_reset_0(WrenVM* vm){
  PGLTransform* t = *(PGLTransform**)wrenGetSlotForeign(vm,0);
  pglTransformReset(t);
}

void pgl_wren_bind_api(){
  pgl_wren_bind_method("PGL.Camera.orbit(_,_)", Camera_orbit_2);
  pgl_wren_bind_method("PGL.Camera.setTransform(_)", Camera_setTransform_1);
  
  pgl_wren_bind_method("PGL.Keyboard.isDown(_)", Keyboard_isDown_1);
  
  pgl_wren_bind_method("PGL.Window.config(_,_,_)", Window_config_3);
  
  pgl_wren_bind_class("PGL.File", File_allocate, File_finalize);
  pgl_wren_bind_method("PGL.File.length()", File_length_0);
  pgl_wren_bind_method("PGL.File.close()", File_close_0);
  pgl_wren_bind_method("PGL.File.read(_)", File_read_1);

  pgl_wren_bind_class("json.JSONParser", JSONParser_allocate, JSONParser_finalize);
  pgl_wren_bind_method("json.JSONParser.getValue()", JSONParser_getValue_0);
  pgl_wren_bind_method("json.JSONParser.getToken()", JSONParser_getToken_0);
  pgl_wren_bind_method("json.JSONParser.nextToken()", JSONParser_nextToken_0);
  pgl_wren_bind_method("json.JSONParser.getChildren()", JSONParser_getChildren_0);
  
  pgl_wren_bind_class("PGL.Image", Image_allocate, Image_finalize);
  
  pgl_wren_bind_class("PGL.Buffer", Buffer_allocate, Buffer_finalize);
  
  pgl_wren_bind_class("PGL.GeometryBuffer", GeometryBuffer_allocate, GeometryBuffer_finalize);
  
  pgl_wren_bind_class("PGL.Attribute", Attribute_allocate, Attribute_finalize);
  
  pgl_wren_bind_class("PGL.Primitive", Primitive_allocate, Primitive_finalize);
  
  pgl_wren_bind_class("PGL.Texture", Texture_allocate, Texture_finalize);
 
  pgl_wren_bind_class("PGL.Material", Material_allocate, Material_finalize);

  pgl_wren_bind_class("PGL.Transform", Transform_allocate, Transform_finalize);
  pgl_wren_bind_method("PGL.Transform.translate(_,_,_)", Transform_translate_3);
  pgl_wren_bind_method("PGL.Transform.rotate(_,_,_)", Transform_rotate_3);
  pgl_wren_bind_method("PGL.Transform.scale(_,_,_)", Transform_scale_3);
  pgl_wren_bind_method("PGL.Transform.reset()", Transform_reset_0);

  pgl_wren_bind_method("PGL.Renderer.render(_)", Renderer_render_1);
  pgl_wren_bind_method("PGL.Renderer.setTransform(_)", Renderer_setTransform_1);
}