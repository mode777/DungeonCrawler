#include "wrenapi.h"
#include <modules/gl.h>
#include <modules/image.h>
#include <modules/memory.h>

static void Texture_allocate(WrenVM* vm){
  PGLTexture** wrenHandle = pgl_wren_new(vm, PGLTexture*);
  pglLog(PGL_MODULE_WREN, PGL_LOG_DEBUG, "Allocated Texture %p", wrenHandle);
  *wrenHandle = NULL;
}

static void Texture_finalize(void* data){
  pglLog(PGL_MODULE_WREN, PGL_LOG_DEBUG, "Free Texture %p", data);
  PGLTexture* texture = *(PGLTexture**)data;
  pglTextureDelete(texture);
}

static void Texture_image_1(WrenVM* vm){
  PGLTexture** handle = ((PGLTexture**)wrenGetSlotForeign(vm, 0));
  PGLImage* img = *((PGLImage**)wrenGetSlotForeign(vm, 1));
  
  PGLTexture* texture = pglTextureFromMemory(img->pixels, img->width, img->height, img->channels); 

  *handle = texture;
}

static void GraphicsBuffer_allocate(WrenVM* vm){
  GLuint* handle = pgl_wren_new(vm, GLuint);
  pglLog(PGL_MODULE_WREN, PGL_LOG_DEBUG, "Allocated GBuffer %p", handle);
  glGenBuffers(1, handle);
}

static void GraphicsBuffer_finalize(void* data){
  pglLog(PGL_MODULE_WREN, PGL_LOG_DEBUG, "Free GBuffer %p", data);
  glDeleteBuffers(1, (GLuint*)data);
}

static void GraphicsBuffer_init_4(WrenVM* vm){
  GLuint glBuffer = *(GLuint*)wrenGetSlotForeign(vm, 0);
  PGLBuffer* pglBuffer = *(PGLBuffer**)wrenGetSlotForeign(vm, 1);
  int offset = (int)wrenGetSlotDouble(vm, 2);
  GLsizeiptr size= (GLsizeiptr)wrenGetSlotDouble(vm, 3);
  GLenum target = wrenGetSlotBool(vm, 4) ? GL_ELEMENT_ARRAY_BUFFER : GL_ARRAY_BUFFER;

  glBindBuffer(target, glBuffer);
  glBufferData(target, size, (void*)((pglBuffer->data) + offset), GL_STATIC_DRAW);
}

static void InternalAttribute_allocate(WrenVM* vm){
  PGLAttribute2* attr = pgl_wren_new(vm, PGLAttribute2);
  attr->buffer = *(GLuint*)wrenGetSlotForeign(vm, 1);
  attr->type = (PGLAttributeType)wrenGetSlotDouble(vm, 2);
  attr->numComponents = (int)wrenGetSlotDouble(vm, 3);
  attr->componentType = (GLenum)wrenGetSlotDouble(vm, 4);
  attr->normalized = wrenGetSlotBool(vm, 5);
  attr->stride = (int)wrenGetSlotDouble(vm, 6);
  attr->offset = (int)wrenGetSlotDouble(vm, 7);
  pglLog(PGL_MODULE_WREN, PGL_LOG_DEBUG, "Allocated Attribute %p", attr);
}

static void InternalAttribute_finalize(void* data){
  // nothing
  pglLog(PGL_MODULE_WREN, PGL_LOG_DEBUG, "Free Attribute %p", data);
}

static void InternalAttribute_enable_0(WrenVM* vm){
  PGLAttribute2* attr = (PGLAttribute2*)wrenGetSlotForeign(vm, 0);
  pglAttributeEnable(attr);
}

static void InternalVertexIndices_allocate(WrenVM* vm){
  PGLVertexIndices* attr = pgl_wren_new(vm, PGLVertexIndices);
  attr->buffer = *(GLuint*)wrenGetSlotForeign(vm, 1);
  attr->count = (int)wrenGetSlotDouble(vm,2);
  attr->componentType = (GLenum)wrenGetSlotDouble(vm, 3);
  pglLog(PGL_MODULE_WREN, PGL_LOG_DEBUG, "Allocated Vertex Indices %p", attr);
}

static void InternalVertexIndices_finalize(void* data){
  // nothing
  pglLog(PGL_MODULE_WREN, PGL_LOG_DEBUG, "Free Vertex Indices %p", data);
}

static void InternalVertexIndices_draw_0(WrenVM* vm){
  PGLVertexIndices* indices = (PGLVertexIndices*)wrenGetSlotForeign(vm, 0);
  pglIndicesDraw(indices);
}



// static void InternalIndices_allocate(WrenVM* vm){

// }
// static void Buffer_allocate(WrenVM* vm){
//   char** handle = pgl_wren_new(vm, char*); 
//   pglLog(PGL_MODULE_WREN, PGL_LOG_DEBUG, "Allocated Buffer %p", handle);  
//   const char* path = wrenGetSlotString(vm, 1); 
//   *handle = pglFileReadAllBytes(path);
  
//   if(*handle == NULL){
//     pgl_wren_runtime_error(vm, "File does not exist");
//     return;
//   }
// }

// static void Buffer_finalize(void* data){
//   pglLog(PGL_MODULE_WREN, PGL_LOG_DEBUG, "Free Buffer %p", data);
//   free(*((char**)data));
// }

// static void GeometryBuffer_allocate(WrenVM* vm){
//   char* data = *(char**)wrenGetSlotForeign(vm, 1);
//   int offset = (int)wrenGetSlotDouble(vm, 2);
//   int size = (int)wrenGetSlotDouble(vm, 3);
//   GLsizei stride = (GLsizei)wrenGetSlotDouble(vm, 4);  
//   bool areIndices = wrenGetSlotBool(vm, 5);

//   PGLGeometryBuffer* buffer = pglCreateGeometryBuffer(data, offset, size, stride, areIndices);
  
//   PGLGeometryBuffer** foreign = pgl_wren_new(vm, PGLGeometryBuffer*);
//   pglLog(PGL_MODULE_WREN, PGL_LOG_DEBUG, "Allocated GeometryBuffer %p", foreign);
//   *foreign = buffer;
// }

// static void GeometryBuffer_finalize(void* data){
//   pglLog(PGL_MODULE_WREN, PGL_LOG_DEBUG, "Free GeometryBuffer %p", data);
//   PGLGeometryBuffer* buffer = *(PGLGeometryBuffer**)data;
//   pglReleaseGeometryBuffer(buffer);
// }

// static void Attribute_allocate(WrenVM* vm){

//   PGLAttribute* attribute = calloc(1, sizeof(PGLAttribute));

//   attribute->buffer = pglTakeGeometryBuffer(*(PGLGeometryBuffer**)wrenGetSlotForeign(vm, 1));
//   attribute->attributeType = (PGLAttributeType)wrenGetSlotDouble(vm, 2);
//   attribute->componentType = (GLenum)wrenGetSlotDouble(vm, 3);
//   attribute->numComponents = (GLubyte)wrenGetSlotDouble(vm, 4);
//   attribute->offset = (GLuint)wrenGetSlotDouble(vm, 5);
//   attribute->normalized = (GLboolean)wrenGetSlotBool(vm, 6);
//   attribute->count = (GLsizei)wrenGetSlotDouble(vm, 7);
  
//   PGLAttribute** foreign = pgl_wren_new(vm, PGLAttribute*);
//   pglLog(PGL_MODULE_WREN, PGL_LOG_DEBUG, "Allocated Attribute %p", foreign);
//   *foreign = attribute;
// }

// static void Attribute_finalize(void* data){
//   pglLog(PGL_MODULE_WREN, PGL_LOG_DEBUG, "Free Attribute %p", data);
//   PGLAttribute* attribute = *(PGLAttribute**)data;
//   pglReleaseGeometryBuffer(attribute->buffer);
//   free(attribute);
// }

// static void Material_allocate(WrenVM* vm){

//   PGLMaterial* material = calloc(1, sizeof(PGLMaterial));

//   PGLTexture* texture = *(PGLTexture**)wrenGetSlotForeign(vm, 1);
//   material->diffuse = pglTakeTexture(texture);
  
//   PGLMaterial** foreign = pgl_wren_new(vm, PGLMaterial*);
//   pglLog(PGL_MODULE_WREN, PGL_LOG_DEBUG, "Allocate Material %p", foreign);
//   *foreign = material;  
// }

// static void Material_finalize(void* data){
//   pglLog(PGL_MODULE_WREN, PGL_LOG_DEBUG, "Free Material %p", data);
//   PGLMaterial* mat = *(PGLMaterial**)data;
//   pglReleaseTexture(mat->diffuse);
//   free(mat);
// }

// static void Primitive_allocate(WrenVM* vm){
//   PGLPrimitive* prim = calloc(1, sizeof(PGLPrimitive));

//   PGLAttribute* indexAttribute = *(PGLAttribute**)wrenGetSlotForeign(vm, 1);
//   prim->index = *indexAttribute;
//   pglTakeGeometryBuffer(prim->index.buffer);
//   prim->attributeCount = wrenGetListCount(vm, 2);
//   prim->attributes = calloc(prim->attributeCount, sizeof(PGLAttribute));
//   for (size_t i = 0; i < prim->attributeCount; i++)
//   {
//     wrenGetListElement(vm, 2, i, 1);
//     PGLAttribute attr = **(PGLAttribute**)wrenGetSlotForeign(vm, 1);
//     prim->attributes[i] = attr; 
//     pglTakeGeometryBuffer(prim->attributes[i].buffer);    
//   }

//   prim->material = **(PGLMaterial**)wrenGetSlotForeign(vm, 3);
//   pglLog(PGL_MODULE_WREN, PGL_LOG_DEBUG, "Allocate Primitve %p", prim->material);
//   pglTakeTexture(prim->material.diffuse);
//   PGLPrimitive** foreign = pgl_wren_new(vm, PGLPrimitive*);
//   *foreign = prim;
// }

// static void Primitive_finalize(void* data){
//   pglLog(PGL_MODULE_WREN, PGL_LOG_DEBUG, "Free Primitve", data);
//   PGLPrimitive* prim = *(PGLPrimitive**)data;
//   pglReleaseGeometryBuffer(prim->index.buffer);
//   pglReleaseTexture(prim->material.diffuse);
//   for (size_t i = 0; i < prim->attributeCount; i++)
//   {
//     pglReleaseGeometryBuffer(prim->attributes[i].buffer);
//   }
//   free(prim);
// }