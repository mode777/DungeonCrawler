#include <modules/image.h>

#define STB_IMAGE_IMPLEMENTATION
#include <stb/stb_image.h>

PGLImage* pglLoadImage(const char* filename, int channels){
  PGLImage* image = malloc(sizeof(PGLImage));

  int raw_channels, width, height;
  unsigned char *img = stbi_load(filename, &width, &height, &raw_channels, channels);
  if(img == NULL) {
    pglLog(PGL_MODULE_IMAGE, PGL_LOG_ERROR, "Error in loading image: %s, Reason: %s", filename, stbi_failure_reason());
    return NULL;
  }
  pglLog(PGL_MODULE_IMAGE, PGL_LOG_INFO, "Loaded image %s with a width of %dpx, a height of %dpx and %d channels", filename, width, height, channels);

  image->channels = channels;
  image->width = width;
  image->height = height;
  image->pixels = img;

  return image;
}

inline void pglDestroyImage(PGLImage* image){
  pglLog(PGL_MODULE_IMAGE, PGL_LOG_DEBUG, "Freeing image %p", image);
  stbi_image_free(image->pixels);
  free(image);
}

