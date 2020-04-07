#include <modules/renderer3d.h>

struct PGLTransform_T {
  mat4 transform;
};

PGLTransform* pglTransformCreate(){
  PGLTransform* ptr = calloc(1, sizeof(PGLTransform));
  glm_mat4_identity(ptr->transform);
  return ptr;
}

void pglTransformLoad(PGLTransform* t, PGLTransform* source){
  glm_mat4_copy(source->transform, t->transform);
}

void pglTransformApply(PGLTransform* t, PGLTransform* source){
  glm_mat4_mul(t, source, t);
}

void pglTransformVector(PGLTransform* t, float* in, float* out){
  glm_mat4_mulv3(t, in, 1, out);
}

void pglTransformRotate(PGLTransform* transform, float x, float y, float z) {
  vec3 v = {x,y,z};
  float dist = glm_vec3_distance(GLM_VEC3_ZERO, v);
  glm_vec3_norm(v);
  glm_rotate(transform->transform, dist, v);
}

void pglTransformScale(PGLTransform* transform, float x, float y, float z) {
  vec3 vec = {x,y,z};
  glm_scale(transform->transform, vec);
}

void pglTransformTranslate(PGLTransform* transform, float x, float y, float z) {
  vec3 vec = {x,y,z};
  glm_translate(transform->transform, vec);
}

void pglTransformReset(PGLTransform* ptr){
  glm_mat4_identity(ptr->transform);
}

float* pglTransformMatrix(PGLTransform* transform) {
  return (float*)transform->transform;
}

void pglTransformDelete(PGLTransform* transform){
  free(transform);
}
