#ifndef RENDERER3D_H
#define RENDERER3D_H

#include <modules/gl.h>

typedef enum {
  PGL_UNI3D_PROJECTION,
  PGL_UNI3D_MODEL,
  PGL_UNI3D_VIEW,
  PGL_UNI3D_TEXTURE0,
  PGL_UNI3D_MAX,
} PGLUniform3D;

typedef struct PGLTransform_T PGLTransform;

void pgl3DOrbitCamera(float rad, float gamma);
// void pgl3DDollyCamera(float amount);
// void pgl3DPanCamera();
// void pgl3DSwingCamera();
void pgl3DSetModelTransform(PGLTransform* transform);
void pgl3DInit();
void pgl3DSetViewport(float width, float height);
void pgl3DDrawPrimitive(PGLPrimitive *prim);
void pgl3DSetCameraTransform(PGLTransform* transform);

PGLTransform* pglTransformCreate();
void pglTransformReset(PGLTransform* trans);
void pglTransformRotate(PGLTransform* transform, float x, float y, float z);
void pglTransformScale(PGLTransform* transform, float x, float y, float z);
void pglTransformTranslate(PGLTransform* transform, float x, float y, float z);
void pglTransformLoadMatrix(mat4 matrix);
float* pglTransformMatrix(PGLTransform* transform);
void pglTransformDelete(PGLTransform* transform);

#endif