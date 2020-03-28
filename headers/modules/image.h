#ifndef ASSETS_H
#define ASSETS_H

#include "common.h"

typedef struct {
  unsigned int width;
  unsigned int height;
  unsigned int channels;
  unsigned char * pixels;
} PGLImage;

PGLImage* pglLoadImage(const char* filename, int channels);
void pglDestroyImage(PGLImage* image);

#endif