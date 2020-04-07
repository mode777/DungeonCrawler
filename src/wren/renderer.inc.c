#include "wrenapi.h"
#include <modules/renderer3d.h>

void Renderer_render_1(WrenVM* vm){
  PGLPrimitive* prim = *(PGLPrimitive**)wrenGetSlotForeign(vm, 1);
  pgl3DDrawPrimitive(prim);
}

void Renderer_setTransform_1(WrenVM* vm){
  PGLTransform* t = *(PGLTransform**)wrenGetSlotForeign(vm, 1);
  pgl3DSetModelTransform(t);
}

void Renderer_setCamera_9(WrenVM* vm){
  
  vec3 vectors[3];
  
  for (size_t i = 0; i < 3; i++)
  {
    for (size_t j = 0; j < 3; j++)
    {
      vectors[i][j] = (float)wrenGetSlotDouble(vm, i*3+j+1);
    }    
  }

  pgl3DSetCamera(vectors[0], vectors[1], vectors[2]);
}

static void Transform_allocate(WrenVM* vm){
  PGLTransform* t = pglTransformCreate();
  PGLTransform** handle = pgl_wren_new(vm, PGLTransform*);
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

static void Transform_load_1(WrenVM* vm){
  PGLTransform* t = *(PGLTransform**)wrenGetSlotForeign(vm,0);
  PGLTransform* source = *(PGLTransform**)wrenGetSlotForeign(vm,1);
  pglTransformLoad(t, source);
}

static void Transform_apply_1(WrenVM* vm){
  PGLTransform* t = *(PGLTransform**)wrenGetSlotForeign(vm,0);
  PGLTransform* source = *(PGLTransform**)wrenGetSlotForeign(vm,1);
  pglTransformApply(t, source);
}

static void Transform_transformVectors_1(WrenVM* vm){
  PGLTransform* t = *(PGLTransform**)wrenGetSlotForeign(vm,0);
  int vectors = wrenGetListCount(vm, 1) / 3;
  for (size_t i = 0; i < vectors; i++)
  {
    vec3 v;
    for (size_t j = 0; j < 3; j++)
    {
      wrenGetListElement(vm, 1, i*3+j, 0);
      v[j] = (float)wrenGetSlotDouble(vm, 0);
    }
    pglTransformVector(t, v, v);
    for (size_t j = 0; j < 3; j++)
    {
      wrenSetSlotDouble(vm, 0, v[j]);
      wrenSetListElement(vm, 1, i*3+j, 0);
    }
  }  
}