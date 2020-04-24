#include <modules/memory.h>

PGLBuffer* PGLBufferCreate(size_t size) {
  PGLBuffer* inst = malloc(sizeof(PGLBuffer));
  inst->size = size;
  inst->data = calloc(size, 1);

  return inst;
}

PGLBuffer* PGLBufferFromData(void* data, size_t size) {
  PGLBuffer* inst = malloc(sizeof(PGLBuffer));
  inst->size = size;
  inst->data = (char*)data;

  return inst;
}

PGLBuffer* PGLBufferClone(PGLBuffer* buffer, size_t offset, size_t size) {
  PGLBuffer* inst = PGLBufferCreate(size);
  memcpy(inst->data, buffer->data + offset, size);

  return inst;
}

void PGLBufferDelete(PGLBuffer* buffer) {
  free(buffer->data);
  free(buffer);
}