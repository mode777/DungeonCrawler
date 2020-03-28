#include <modules/renderer3d.h>

struct PGLTransform_T {
  mat4 translation;
  mat4 rotation;
  mat4 scale;
  mat4 transform;
  bool dirty;
};

PGLTransform* pglTransformCreate(){
  PGLTransform* ptr = calloc(1, sizeof(PGLTransform));
  glm_mat4_identity(ptr->translation);
  glm_mat4_identity(ptr->rotation);
  glm_mat4_identity(ptr->scale);
  glm_mat4_identity(ptr->transform);
  ptr->dirty = false;

  assert(ptr->translation[0][0] == 1);

  return ptr;
}

void pglTransformRotate(PGLTransform* transform, float x, float y, float z) {
  vec3 v = {x,y,z};
  float dist = glm_vec3_distance(GLM_VEC3_ZERO, v);
  glm_vec3_norm(v);
  glm_rotate(transform->rotation, dist, v);
  transform->dirty = true;
}

void pglTransformScale(PGLTransform* transform, float x, float y, float z) {
  vec3 vec = {x,y,z};
  glm_scale(transform->scale, vec);
  transform->dirty = true;
}

void pglTransformTranslate(PGLTransform* transform, float x, float y, float z) {
  vec3 vec = {x,y,z};
  glm_translate(transform->translation, vec);
  transform->dirty = true;  
}

static void calculate_transform(PGLTransform* transform){
  glm_mat4_identity(transform->transform);
  mat4 tmp;
  glm_mat4_mul(transform->rotation, transform->scale, tmp);
  glm_mat4_mul(tmp, transform->translation, transform->transform);
  transform->dirty = false;
}

void pglTransformReset(PGLTransform* ptr){
  glm_mat4_identity(ptr->translation);
  glm_mat4_identity(ptr->rotation);
  glm_mat4_identity(ptr->scale);
  glm_mat4_identity(ptr->transform);
  ptr->dirty = false;
}


float* pglTransformMatrix(PGLTransform* transform) {
  if(transform->dirty)
    calculate_transform(transform);

  return (float*)transform->transform;
}

void pglTransformDelete(PGLTransform* transform){
  free(transform);
}
