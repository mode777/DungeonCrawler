#include "wrenapi.h"
#include <modules/renderer3d.h>

void Renderer_getErrors_0(WrenVM* vm){
  wrenSetSlotNewList(vm, 0);
  GLenum err;
  while((err = glGetError()) != GL_NO_ERROR)
  {
    wrenSetSlotString(vm, 1, pglGetGlErrorString(err));
    wrenInsertInList(vm, 0, -1, 1);
  }
}

void Renderer_setViewport_4(WrenVM* vm){
  vec4 vp;
  for (int i = 1; i <= 4; i++)
  {
    vp[i-1] = (float)wrenGetSlotDouble(vm, i);
  }
  pgl3DSetViewport(vp[0], vp[1], vp[2], vp[3]);  
}

static void Renderer_enableAttribute_1(WrenVM* vm){
  PGLAttribute* attr = (PGLAttribute*)wrenGetSlotForeign(vm, 1);
  pglAttributeEnable(attr);
}

static void Renderer_drawIndices_1(WrenVM* vm){
  PGLVertexIndices* indices = (PGLVertexIndices*)wrenGetSlotForeign(vm, 1);
  pglIndicesDraw(indices);
}

static void Renderer_drawIndices_2(WrenVM* vm){
  PGLVertexIndices* indices = (PGLVertexIndices*)wrenGetSlotForeign(vm, 1);
  int count = (int)wrenGetSlotDouble(vm, 2);
  pglIndicesDrawi(indices,count);
}

static void Renderer_setUniformMat4_2(WrenVM* vm){
  int type = (int)wrenGetSlotDouble(vm, 1);
  void* ptr = wrenGetSlotForeign(vm, 2);
  float* mat = (float*)(((size_t)ptr) + ((size_t)ptr)%16);
  if(mat == NULL) pgl_wren_runtime_error(vm, "Mat4 is null");
  pglSetUniformMat4(type, mat);
}

static void Renderer_setUniformVec3_2(WrenVM* vm){
  int type = (int)wrenGetSlotDouble(vm, 1);
  vec3 v;
  get_vec(vm, 2,0,0, v,3);
  pglSetUniformVec3(type, v);
}


static void Renderer_setUniformVec2_2(WrenVM* vm){
  int type = (int)wrenGetSlotDouble(vm, 1);
  vec2 v;
  get_vec(vm, 2,0,0, v,2);
  pglSetUniformVec2(type, v);
}

static void Renderer_setUniformFloat_2(WrenVM* vm){
  int type = (int)wrenGetSlotDouble(vm, 1);
  float f = (float)wrenGetSlotDouble(vm, 2);
  pglSetUniformf(type, f);
}

static void Renderer_setProgram_1(WrenVM* vm){
  PGLProgram* prog = *(PGLProgram**)wrenGetSlotForeign(vm, 1);
  pgl3DSetProgram(prog);
}

static void Renderer_setUniformTexture_3(WrenVM* vm){
  int type = (int)wrenGetSlotDouble(vm,1);
  int unit = (int)wrenGetSlotDouble(vm,2);
  if(wrenGetSlotType(vm, 3) == WREN_TYPE_NULL) { 
    pgl_wren_runtime_error(vm, "Texture is null");
    return;
  }
  GLuint texture = *(GLuint*)wrenGetSlotForeign(vm, 3);

  pglSetTextureUnit(unit, texture);
  pglSetUniformi(type, unit);
}

static void Renderer_setBackgroundColor_3(WrenVM* vm){
  float r = (float)wrenGetSlotDouble(vm,1);
  float g = (float)wrenGetSlotDouble(vm,2);
  float b = (float)wrenGetSlotDouble(vm,3);
  glClearColor(r, g, b, 1.0);
}

static void Renderer_toggleFeature_2(WrenVM* vm){
  GLenum cap = (GLenum)wrenGetSlotDouble(vm,1);
  bool on = wrenGetSlotBool(vm, 2);
  if(on){
    glEnable(cap);
  } else {
    glDisable(cap);
  }
}

static void Renderer_blendFunc_2(WrenVM* vm){
  GLenum src = (GLenum)wrenGetSlotDouble(vm,1);
  GLenum dst = (GLenum)wrenGetSlotDouble(vm,2);
  glBlendFunc(src,dst);
}
