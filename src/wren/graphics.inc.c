#include "wrenapi.h"
#include <modules/gl.h>
#include <modules/image.h>
#include <modules/memory.h>

static void Texture_allocate(WrenVM* vm){
  GLuint* wrenHandle = pgl_wren_new(vm, GLuint);
  pglLog(PGL_MODULE_WREN, PGL_LOG_DEBUG, "Allocated Texture %p", wrenHandle);
  *wrenHandle = NULL;
}

static void Texture_finalize(void* data){
  pglLog(PGL_MODULE_WREN, PGL_LOG_DEBUG, "Free Texture %p", data);
  glDeleteTextures(1, (GLuint*)data);
}

static void Texture_image_1(WrenVM* vm){
  GLuint* handle = ((GLuint*)wrenGetSlotForeign(vm, 0));
  PGLImage* img = *((PGLImage**)wrenGetSlotForeign(vm, 1));
  
  GLuint texture = pglTextureFromMemory(img->pixels, img->width, img->height, img->channels); 

  *handle = texture;
}

static void Texture_minFilter_1(WrenVM* vm){
  GLuint handle = *((GLuint*)wrenGetSlotForeign(vm, 0));
  GLenum para = (GLenum)wrenGetSlotDouble(vm, 1);
  glBindTexture(GL_TEXTURE_2D, handle);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, para);
}

static void Texture_magFilter_1(WrenVM* vm){
  GLuint handle = *((GLuint*)wrenGetSlotForeign(vm, 0));
  GLenum para = (GLenum)wrenGetSlotDouble(vm, 1);
  glBindTexture(GL_TEXTURE_2D, handle);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, para);
}

static void Texture_wrap_2(WrenVM* vm){
  GLuint handle = *((GLuint*)wrenGetSlotForeign(vm, 0));
  GLenum s = (GLenum)wrenGetSlotDouble(vm, 1);
  GLenum t = (GLenum)wrenGetSlotDouble(vm, 2);
  glBindTexture(GL_TEXTURE_2D, handle);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, s);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, t);
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
  PGLAttribute* attr = pgl_wren_new(vm, PGLAttribute);
  attr->buffer = *(GLuint*)wrenGetSlotForeign(vm, 1);
  attr->type = (unsigned int)wrenGetSlotDouble(vm, 2);
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

static void InternalShader_allocate(WrenVM* vm){
  const char* vs = wrenGetSlotString(vm, 1);
  const char* fs = wrenGetSlotString(vm, 2);
  PGLProgram* p = pglProgramCreate(vs,fs);
  if(p == NULL){
    pgl_wren_runtime_error(vm, "Shader compilation error");
  } 
  PGLProgram** prog = pgl_wren_new(vm, PGLProgram*);
  *prog = p;
  pglLog(PGL_MODULE_WREN, PGL_LOG_DEBUG, "Allocated Program %p", prog);
}

static void InternalShader_finalize(void* data){
  pglLog(PGL_MODULE_WREN, PGL_LOG_DEBUG, "Free Program %p", data);
  pglProgramDelete(*(PGLProgram**)data);
}

static void InternalShader_bindAttribute_2(WrenVM* vm){
  PGLProgram* p = *(PGLProgram**)wrenGetSlotForeign(vm, 0);
  int type = (int)wrenGetSlotDouble(vm, 1);
  const char* name = wrenGetSlotString(vm, 2);
  p->attributes[type] = glGetAttribLocation(p->program, name);
}

static void InternalShader_bindUniform_2(WrenVM* vm){
  PGLProgram* p = *(PGLProgram**)wrenGetSlotForeign(vm, 0);
  int type = (int)wrenGetSlotDouble(vm, 1);
  const char* name = wrenGetSlotString(vm, 2);
  p->uniforms[type] = glGetUniformLocation(p->program, name);
}




