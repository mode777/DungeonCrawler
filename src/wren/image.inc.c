#include "wrenapi.h"
#include <modules/image.h>
#include <modules/memory.h>

static void Image_allocate(WrenVM* vm){
  PGLImage** image = pgl_wren_new(vm, PGLImage*); 
  pglLog(PGL_MODULE_WREN, PGL_LOG_DEBUG, "Allocated Image %p", image);  
  *image = NULL;
}

static void Image_finalize(void* data){
  pglLog(PGL_MODULE_WREN, PGL_LOG_DEBUG, "Free Image %p", data);  
  PGLImage** img = data;
  pglImageDestroy(*img);
}

static void Image_load_2(WrenVM* vm){
  PGLImage** handle = (PGLImage**)wrenGetSlotForeign(vm, 0); 
  const char* path = wrenGetSlotString(vm, 1);  
  int channels = (int)wrenGetSlotDouble(vm, 2);  
  PGLImage* image = pglImageLoad(path, channels);
  if(image == NULL){
    pgl_wren_runtime_error(vm, "File not found");
  }
  *handle = image;  
}

static void Image_buffer_4(WrenVM* vm){
  PGLImage** handle = (PGLImage**)wrenGetSlotForeign(vm, 0); 
  PGLBuffer* buffer = *(PGLBuffer**)wrenGetSlotForeign(vm,1);
  size_t offset = (size_t)wrenGetSlotDouble(vm, 2);
  size_t size = (size_t)wrenGetSlotDouble(vm, 3);
  int channels = (int)wrenGetSlotDouble(vm, 4);

  if(offset+size>buffer->size){
    pgl_wren_runtime_error(vm, "Data size out of bounds");
  }

  PGLImage* image = pglImageFromMemory(buffer->data, offset, size, channels);

  *handle = image;  
}

static void Image_allocate_3(WrenVM* vm){
  PGLImage** handle = (PGLImage**)wrenGetSlotForeign(vm, 0); 
  size_t width = (size_t)wrenGetSlotDouble(vm, 1);
  size_t height = (size_t)wrenGetSlotDouble(vm, 2);
  int channels = (int)wrenGetSlotDouble(vm, 3);

  PGLImage* image = pglImageCreate(width, height, channels);

  *handle = image;  
}

static void Image_put_7(WrenVM* vm){
  PGLImage* dst = *(PGLImage**)wrenGetSlotForeign(vm, 0); 
  PGLImage* src = *(PGLImage**)wrenGetSlotForeign(vm, 1); 
  size_t sx = (size_t)wrenGetSlotDouble(vm, 2);
  size_t sy = (size_t)wrenGetSlotDouble(vm, 3);
  size_t sw = (size_t)wrenGetSlotDouble(vm, 4);
  size_t sh = (size_t)wrenGetSlotDouble(vm, 5);
  size_t dx = (size_t)wrenGetSlotDouble(vm, 6);
  size_t dy = (size_t)wrenGetSlotDouble(vm, 7);

  pglImageBlit(dst, src, sx, sy, sw, sh, dx, dy);
}

static void Image_getPixel_3(WrenVM* vm){
  PGLImage* image = *(PGLImage**)wrenGetSlotForeign(vm, 0); 
  int x = (int)wrenGetSlotDouble(vm, 1);
  int y = (int)wrenGetSlotDouble(vm, 2);
  int count = wrenGetListCount(vm, 3);
  if(count < image->channels){
    pgl_wren_runtime_error(vm, "Pixel vector does not have the right amount of components");
  }
  
  unsigned char* pixel = &image->pixels[(y * image->width + x)*image->channels];
  for (size_t i = 0; i < image->channels; i++)
  {
    wrenSetSlotDouble(vm, 0, (double)pixel[i]);
    wrenSetListElement(vm, 3, i, 0);
  }
}

static void Image_getPixelInt_2(WrenVM* vm){
  PGLImage* image = *(PGLImage**)wrenGetSlotForeign(vm, 0); 
  int x = (int)wrenGetSlotDouble(vm, 1);
  int y = (int)wrenGetSlotDouble(vm, 2);
  unsigned int pixel = ((unsigned int*)image->pixels)[(y * image->width + x)];
  wrenSetSlotDouble(vm, 0, (double)pixel);
}

static void Image_setPixel_3(WrenVM* vm){
  PGLImage* image = *(PGLImage**)wrenGetSlotForeign(vm, 0); 
  unsigned int x = (unsigned int)wrenGetSlotDouble(vm, 1);
  unsigned int y = (unsigned int)wrenGetSlotDouble(vm, 2);
  if(x >= image->width || y >= image->height){
    pgl_wren_runtime_error(vm, "Pixel out of bounds");
  }
  int count = wrenGetListCount(vm, 3);
  if(count != image->channels){
    pgl_wren_runtime_error(vm, "Pixel vector does not have the right amount of components");
  }
  
  unsigned char* pixel = &image->pixels[(y * image->width + x)*image->channels];
  for (size_t i = 0; i < count; i++)
  {
    wrenGetListElement(vm, 3, i, 0);
    unsigned char c = (unsigned char)wrenGetSlotDouble(vm, 0);
    pixel[i] = c;
  }
  wrenSetSlotNull(vm, 0);
}

static void Image_save_1(WrenVM* vm){
  PGLImage* image = *(PGLImage**)wrenGetSlotForeign(vm, 0); 
  const char* path = wrenGetSlotString(vm, 1);

  pglImageSaveTga(image, path);
}

static void Image_getWidth_0(WrenVM* vm){
  PGLImage* image = *(PGLImage**)wrenGetSlotForeign(vm, 0); 
  wrenSetSlotDouble(vm ,0, (double)image->width);
}

static void Image_getHeight_0(WrenVM* vm){
  PGLImage* image = *(PGLImage**)wrenGetSlotForeign(vm, 0); 
  wrenSetSlotDouble(vm ,0, (double)image->height);
}