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