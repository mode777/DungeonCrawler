#ifndef PGL_MEMORY_H
#define PGL_MEMORY_H

#include "common.h"

typedef struct { 
  char* data;
  size_t size;
} PGLBuffer;

PGLBuffer* PGLBufferCreate(size_t size);
PGLBuffer* PGLBufferFromData(void* data, size_t size);
PGLBuffer* PGLBufferClone(PGLBuffer* buffer, size_t offset, size_t size);
void PGLBufferDelete(PGLBuffer* buffer);

#endif