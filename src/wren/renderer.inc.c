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

static void Renderer_setUniformMat4_2(WrenVM* vm){
  int type = (int)wrenGetSlotDouble(vm, 1);
  float* mat = (float*)wrenGetSlotForeign(vm, 2);
  pglSetUniformMat4(type, mat);
}

static void Renderer_setUniformVec3_2(WrenVM* vm){
  int type = (int)wrenGetSlotDouble(vm, 1);
  vec3 v;
  get_vec3(vm, 2,0,0, v);
  pglSetUniformVec3(type, v);
}

static void Renderer_setProgram_1(WrenVM* vm){
  PGLProgram* prog = *(PGLProgram**)wrenGetSlotForeign(vm, 1);
  pgl3DSetProgram(prog);
}

static void Renderer_setUniformTexture_3(WrenVM* vm){
  int type = (int)wrenGetSlotDouble(vm,1);
  int unit = (int)wrenGetSlotDouble(vm,2);
  PGLTexture* texture = *(PGLTexture**)wrenGetSlotForeign(vm, 3);
  pglSetTextureUnit(unit, texture->handle);
  pglSetUniformi(type, unit);
}