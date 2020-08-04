#include "wrenapi.h"
#include <modules/renderer3d.h>
#include <modules/math.h>

inline static void get_vec3(WrenVM* vm, int listSlot, int listIndex, int slot, float* out){
  for (int i = 0; i < 3; i++)
  {
    wrenGetListElement(vm, listSlot, listIndex+i, slot);
    out[i] = (float)wrenGetSlotDouble(vm, slot);
  }
}

inline static void set_vec3(WrenVM* vm, int listSlot, int listIndex, int slot, float* in){
  for (int i = 0; i < 3; i++)
  {
    wrenSetSlotDouble(vm, slot, (double)in[i]);
    wrenSetListElement(vm, listSlot, listIndex+i, slot);
  }
}

inline static void get_vec(WrenVM* vm, int listSlot, int listIndex, int slot, float* out, int size){
  for (int i = 0; i < size; i++)
  {
    wrenGetListElement(vm, listSlot, listIndex+i, slot);
    out[i] = (float)wrenGetSlotDouble(vm, slot);
  }
}

inline static void set_vec(WrenVM* vm, int listSlot, int listIndex, int slot, float* in, int size){
  for (int i = 0; i < size; i++)
  {
    wrenSetSlotDouble(vm, slot, (double)in[i]);
    wrenSetListElement(vm, listSlot, listIndex+i, slot);
  }
}

static void Mat4_allocate(WrenVM* vm){
  char* handle = wrenSetSlotNewForeign(vm, 0, 0, sizeof(mat4)+16);
  pglLog(PGL_MODULE_WREN, PGL_LOG_DEBUG, "Allocated matrix4 %p", handle);
}

static void Mat4_finalize(void* data){
  //nothing
  pglLog(PGL_MODULE_WREN, PGL_LOG_DEBUG, "Free matrix4 %p", data);
}

static void Mat4_identity_0(WrenVM* vm){
  void* ptr = wrenGetSlotForeign(vm, 0);
  float* mat = (float*)(((size_t)ptr) + ((size_t)ptr)%16);
  glm_mat4_identity(mat);
}

static void Mat4_translate_3(WrenVM* vm){
  void* ptr = wrenGetSlotForeign(vm, 0);
  float* m = (float*)(((size_t)ptr) + ((size_t)ptr)%16);
  vec3 v;
  v[0] = (float)wrenGetSlotDouble(vm, 1);
  v[1] = (float)wrenGetSlotDouble(vm, 2);
  v[2] = (float)wrenGetSlotDouble(vm, 3);
  glm_translate(m, v);
}

static void Mat4_rotateX_1(WrenVM* vm){
  void* ptr = wrenGetSlotForeign(vm, 0);
  float* m = (float*)(((size_t)ptr) + ((size_t)ptr)%16);
  float angle = (float)wrenGetSlotDouble(vm, 1);
  glm_rotate_x(m, angle, m);
}

static void Mat4_rotateY_1(WrenVM* vm){
  void* ptr = wrenGetSlotForeign(vm, 0);
  float* m = (float*)(((size_t)ptr) + ((size_t)ptr)%16);

  float angle = (float)wrenGetSlotDouble(vm, 1);
  glm_rotate_y(m, angle, m);
}

static void Mat4_rotateZ_1(WrenVM* vm){
  void* ptr = wrenGetSlotForeign(vm, 0);
  float* m = (float*)(((size_t)ptr) + ((size_t)ptr)%16);

  float angle = (float)wrenGetSlotDouble(vm, 1);
  glm_rotate_z(m, angle, m);
}

static void Mat4_rotateQuat_4(WrenVM* vm){
  void* ptr = wrenGetSlotForeign(vm, 0);
  float* m = (float*)(((size_t)ptr) + ((size_t)ptr)%16);

  mat4 mat;
  float q[4];
  q[0] = (float)wrenGetSlotDouble(vm, 1);
  q[1] = (float)wrenGetSlotDouble(vm, 2);
  q[2] = (float)wrenGetSlotDouble(vm, 3);
  q[3] = (float)wrenGetSlotDouble(vm, 4);
  glm_quat_mat4(q, mat);
  glm_mat4_mul(m, mat, m);
}

static void Mat4_scale_3(WrenVM* vm){
  void* ptr = wrenGetSlotForeign(vm, 0);
  float* m = (float*)(((size_t)ptr) + ((size_t)ptr)%16);

  vec3 v;
  v[0] = (float)wrenGetSlotDouble(vm, 1);
  v[1] = (float)wrenGetSlotDouble(vm, 2);
  v[2] = (float)wrenGetSlotDouble(vm, 3);
  glm_scale(m, v);
}

static void Mat4_copy_1(WrenVM* vm){
  void* ptr = wrenGetSlotForeign(vm, 0);
  float* m = (float*)(((size_t)ptr) + ((size_t)ptr)%16);

  float* src = wrenGetSlotForeign(vm, 1);
  glm_mat4_copy(src, m);
}

static void Mat4_mul_1(WrenVM* vm){
  void* ptr = wrenGetSlotForeign(vm, 0);
  float* m = (float*)(((size_t)ptr) + ((size_t)ptr)%16);

  float* src = wrenGetSlotForeign(vm, 1);
  glm_mat4_mul(m, src, m);
}

static void Mat4_mulVec_1(WrenVM* vm){
  void* ptr = wrenGetSlotForeign(vm, 0);
  float* m = (float*)(((size_t)ptr) + ((size_t)ptr)%16);
  int vectors = wrenGetListCount(vm, 1) / 3;
  for (size_t i = 0; i < vectors; i++)
  {
    vec3 v;
    get_vec3(vm, 1, i*3, 0, v);
    glm_mat4_mulv3(m, v, 1, v);
    set_vec3(vm, 1, i*3, 0, v);
  }  
}

static void Mat4_project_1(WrenVM* vm){
  void* ptr = wrenGetSlotForeign(vm, 0);
  float* m = (float*)(((size_t)ptr) + ((size_t)ptr)%16);
  int vectors = wrenGetListCount(vm, 1) / 3;
  for (size_t i = 0; i < vectors; i++)
  {
    vec3 v;
    get_vec3(vm, 1, i*3, 0, v);
    float* vp = pgl3DGetViewport();
    glm_project(v, m, vp, v);
    v[1] = vp[3] - v[1];
    set_vec3(vm, 1, i*3, 0, v);
  }  
}

static void Mat4_unproject_1(WrenVM* vm){
  void* ptr = wrenGetSlotForeign(vm, 0);
  float* m = (float*)(((size_t)ptr) + ((size_t)ptr)%16);
  mat4 inv;
  glm_mat4_inv_fast(m,inv);
  int vectors = wrenGetListCount(vm, 1) / 3;
  for (size_t i = 0; i < vectors; i++)
  {
    vec3 v;
    get_vec3(vm, 1, i*3, 0, v);
    float* vp = pgl3DGetViewport();
    v[1] = vp[3] - v[1];
    glm_unprojecti(v, inv, vp, v);
    set_vec3(vm, 1, i*3, 0, v);
  }  
}

static void Mat4_perspective_3(WrenVM* vm){
  void* ptr = wrenGetSlotForeign(vm, 0);
  float* m = (float*)(((size_t)ptr) + ((size_t)ptr)%16);
  float fov = (float)wrenGetSlotDouble(vm, 1);
  float near = (float)wrenGetSlotDouble(vm, 2);
  float far = (float)wrenGetSlotDouble(vm, 3);
  float* vp = pgl3DGetViewport();
  glm_perspective(fov, vp[2]/vp[3], near, far, m);
}

static void Mat4_ortho_0(WrenVM* vm){
  void* ptr = wrenGetSlotForeign(vm, 0);
  float* m = (float*)(((size_t)ptr) + ((size_t)ptr)%16);
  float* vp = pgl3DGetViewport();
  glm_ortho(vp[0],vp[2],vp[3], vp[1], 0,1,m);
}

static void Mat4_lookAt_3(WrenVM* vm){
  void* ptr = wrenGetSlotForeign(vm, 0);
  float* m = (float*)(((size_t)ptr) + ((size_t)ptr)%16);
  vec3 eye, target, up;
  get_vec3(vm, 1, 0, 0, eye);
  get_vec3(vm, 2, 0, 0, target);
  get_vec3(vm, 3, 0, 0, up);
  glm_lookat(eye, target, up, m);
}

static void Mat4_transpose_0(WrenVM* vm){
  void* ptr = wrenGetSlotForeign(vm, 0);
  float* m = (float*)(((size_t)ptr) + ((size_t)ptr)%16);
  glm_mat4_transpose(m);
}

static void Mat4_invert_0(WrenVM* vm){
  void* ptr = wrenGetSlotForeign(vm, 0);
  float* m = (float*)(((size_t)ptr) + ((size_t)ptr)%16);
  glm_mat4_inv_fast(m,m);
}

static void Noise_seed_1(WrenVM* vm){
  int seed = (int)wrenGetSlotDouble(vm, 1);
  pglPerlinSeed(seed);
}

static void Noise_perlin2d_4(WrenVM* vm){
  double x = wrenGetSlotDouble(vm, 1);
  double y = wrenGetSlotDouble(vm, 2);
  double f = wrenGetSlotDouble(vm, 3);
  double d = (int)wrenGetSlotDouble(vm, 4);
  double n = pglPerlin2d(x,y,f,d);
  wrenSetSlotDouble(vm, 0, n);
}