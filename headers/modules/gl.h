#ifndef COMMONGL_H
#define COMMONGL_H

#include "common.h"
#include <GLES2/gl2.h>
#include <cglm/cglm.h>

typedef struct { 
  GLuint buffer;
  unsigned int type;
  int numComponents;
  GLenum componentType;
  int stride;
  int offset;
  GLboolean normalized;
} PGLAttribute;

typedef struct {
  GLuint buffer;
  GLenum componentType;
  int count;
} PGLVertexIndices;

#define PGL_MAX_ATTRIBUTES 32
#define PGL_MAX_UNIFORMS 32

typedef struct {
  GLuint program;
  char attributes[PGL_MAX_ATTRIBUTES];
  char uniforms[PGL_MAX_UNIFORMS];
} PGLProgram;

const char* pglGetGlErrorString(GLenum const err);
void pglCheckGlErrorImpl(const char* fname, int line);
#define pglCheckGlError() pglCheckGlErrorImpl(__FILE__,__LINE__)

GLuint pglTextureFromMemory(void* pixels, int width, int height, int channels);

PGLProgram* pglProgramCreate(const char *vertShaderSrc, const char *fragShaderSrc);
void pglProgramDelete(PGLProgram* p);

#endif