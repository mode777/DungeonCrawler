#include <modules/image.h>

#define STB_IMAGE_IMPLEMENTATION
#include <stb/stb_image.h>

PGLImage* pglImageLoad(const char* filename, int channels){
  PGLImage* image = calloc(1, sizeof(PGLImage));

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

PGLImage* pglImageFromMemory(void* data, size_t offset, size_t size, int channels){
  PGLImage* image = calloc(1, sizeof(PGLImage));

  int raw_channels;
  image->pixels = (unsigned char*)stbi_load_from_memory((stbi_uc*)(((char*)data)+offset),(int)size, &image->width, &image->height, &raw_channels, channels);
  image->channels = channels;
  pglLog(PGL_MODULE_IMAGE, PGL_LOG_INFO, "Loaded image with a width of %dpx, a height of %dpx and %d channels", image->width, image->height, channels);

  return image;
}

PGLImage* pglImageCreate(size_t width, size_t height, int channels){
  PGLImage* image = calloc(1, sizeof(PGLImage));
  image->channels = channels;
  image->width = width;
  image->height = height;
  image->pixels = calloc(width*height,channels);

  return image;
}

inline void pglImageDestroy(PGLImage* image){
  pglLog(PGL_MODULE_IMAGE, PGL_LOG_DEBUG, "Freeing image %p", image);
  free(image->pixels);
  free(image);
}

void pglImageBlit(PGLImage* dst, PGLImage* src, size_t sx, size_t sy, size_t sw, size_t sh, size_t dx, size_t dy){
  if(dx + sw > dst->width || dy + sh > dst->height || sx + sw > src->width || sy + sh > src->height){
    pglLog(PGL_MODULE_IMAGE, PGL_LOG_ERROR, "Cannot blit image: Out of bounds");
    return;
  }
  if(dst->channels != src->channels){
    pglLog(PGL_MODULE_IMAGE, PGL_LOG_ERROR, "Cannot blit image: Pixel formats don't match");
    return;
  }
  
  int dstLineSize = dst->channels * dst->width;
  int dstOffsetSize = dst->channels * dx;
  int srcLineSize = src->channels * src->width;
  int srcOffsetSize = src->channels * sx;
  int rowSize = src->channels * sw;

  int d_offset = (dstLineSize * dy + dstOffsetSize);
  int s_offset = (srcLineSize * sy + srcOffsetSize);
  unsigned char* srcPtr = src->pixels;
  unsigned char* dstPtr = dst->pixels;

  for (size_t i = 0; i < sh; i++)
  {
    memcpy(dstPtr + d_offset, srcPtr + s_offset, rowSize);
    d_offset += dstLineSize;
    s_offset += srcLineSize;
  }
}

void pglImageSaveTga(PGLImage* image, const char* path){
  if(image->channels != 3 && image->channels != 4){
    pglLog(PGL_MODULE_IMAGE, PGL_LOG_ERROR, "Cannot save image: Unknown pixel format");
    return;
  }

  FILE* fptr = fopen(path, "wb");

  if(fptr == NULL){
    pglLog(PGL_MODULE_IMAGE, PGL_LOG_ERROR, "Cannot save image: Unable to open path");
    return;
  }

  // header
  putc(0,fptr);
  putc(0,fptr);
  putc(2,fptr);
  putc(0,fptr); putc(0,fptr);
  putc(0,fptr); putc(0,fptr);
  putc(0,fptr);
  putc(0,fptr); putc(0,fptr);
  putc(0,fptr); putc(0,fptr);
  putc((image->width & 0x00FF),fptr);
  putc((image->width & 0xFF00) / 256,fptr);
  putc((image->height & 0x00FF),fptr);
  putc((image->height & 0xFF00) / 256,fptr);
  putc(image->channels * 8,fptr);     
  putc(0,fptr);

  // data
  int size = image->channels;
  unsigned char* pixels = image->pixels;
  //pixels
  for (int y = (image->height)-1; y >= 0; y--)
  {
    for (int x = 0; x < image->width; x++)
    {
      const char* pixel = &pixels[((y * image->width)+x)*size];

      putc((int)pixel[2], fptr);
      putc((int)pixel[1], fptr);
      putc((int)pixel[0], fptr);
      if(size == 4){
        putc((int)pixel[3], fptr);
      }
    } 
  }  

  fclose(fptr);
  
  pglLog(PGL_MODULE_IMAGE, PGL_LOG_INFO, "Wrote image %s", path);
}

