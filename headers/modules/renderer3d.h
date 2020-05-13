#ifndef RENDERER3D_H
#define RENDERER3D_H

#include <modules/gl.h>

typedef struct PGLTransform_T PGLTransform;

void pgl3DSetProgram(PGLProgram* program);
void pgl3DSetViewport(float x, float y, float width, float height);
float* pgl3DGetViewport();

void pglAttributeEnable(PGLAttribute* attr);
void pglIndicesDraw(PGLVertexIndices* idx);
void pglSetUniformMat4(int type, float* mat);
void pglSetUniformVec3(int type, float* v3);
void pglSetUniformi(int type, int i);
void pglSetTextureUnit(int unit, GLuint texture);

#endif