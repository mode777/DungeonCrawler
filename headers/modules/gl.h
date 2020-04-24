#ifndef COMMONGL_H
#define COMMONGL_H

#include "common.h"
#include <GLES2/gl2.h>
#include <cglm/cglm.h>

typedef unsigned char color[4];

typedef enum {
  PGL_ATTR_UNKNOWN = 0,
  PGL_ATTR_POSITION = 1,
  PGL_ATTR_COLOR = 2,
  PGL_ATTR_NORMAL = 3,
  PGL_ATTR_TANGENT = 4,
  PGL_ATTR_TEXCOORD0 = 5,
  PGL_ATTR_TEXCOORD1 = 6,
  PGL_ATTR_MAX = 64
} PGLAttributeType;

typedef struct {
  GLuint handle;
  int refCount;
} PGLTexture;

typedef struct {
  PGLTexture* diffuse;
} PGLMaterial;

typedef struct {
  GLsizei stride;
  GLuint handle;
  int refCount;
} PGLGeometryBuffer;

typedef struct { 
  GLsizei count;
  PGLAttributeType attributeType; 
  GLenum componentType;
  PGLGeometryBuffer* buffer;
  GLuint offset;
  GLubyte numComponents;
  GLboolean normalized;
} PGLAttribute;

typedef struct { 
  GLuint buffer;
  PGLAttributeType type;
  int numComponents;
  GLenum componentType;
  int stride;
  int offset;
  GLboolean normalized;
} PGLAttribute2;

typedef struct {
  GLuint buffer;
  GLenum componentType;
  int count;
} PGLVertexIndices;

typedef struct {
  GLsizei attributeCount;
  PGLAttribute* attributes;
  PGLAttribute index;
  PGLMaterial material;
} PGLPrimitive;


const char* pglGetGlErrorString(GLenum const err);
void pglCheckGlErrorImpl(const char* fname, int line);
#define pglCheckGlError() pglCheckGlErrorImpl(__FILE__,__LINE__)

GLuint pglLoadProgram(const char *vertShaderSrc, const char *fragShaderSrc);
GLuint pglLoadProgramFile(const char *vertShaderFile, const char *fragShaderFile);

PGLTexture* pglTextureFromMemory(void* pixels, int width, int height, int channels);
PGLTexture* pglTextureTake(PGLTexture* texture);
void pglTextureDelete(PGLTexture* texture);

PGLGeometryBuffer* pglCreateGeometryBuffer(void* data, GLsizei offset, GLsizei size, GLsizei stride, bool areIndices);
PGLGeometryBuffer* pglTakeGeometryBuffer(PGLGeometryBuffer* buffer);
void pglReleaseGeometryBuffer(PGLGeometryBuffer* buffer);

#endif