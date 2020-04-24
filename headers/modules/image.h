#ifndef ASSETS_H
#define ASSETS_H

#include "common.h"

typedef struct {
  unsigned int width;
  unsigned int height;
  unsigned int channels;
  unsigned char * pixels;
} PGLImage;

PGLImage* pglImageLoad(const char* filename, int channels);
PGLImage* pglImageFromMemory(void* data, size_t offset, size_t size, int channels);
PGLImage* pglImageCreate(size_t width, size_t height, int channels);
void pglImageBlit(PGLImage* dst, PGLImage* src, size_t sx, size_t sy, size_t sw, size_t sh, size_t dx, size_t dy);
void pglImageSaveTga(PGLImage* image, const char* path);
void pglImageDestroy(PGLImage* image);

#endif