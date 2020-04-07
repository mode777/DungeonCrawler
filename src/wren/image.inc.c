#include "wrenapi.h"
#include <modules/image.h>

static void Image_allocate(WrenVM* vm){
  PGLImage** file = pgl_wren_new(vm, PGLImage*); 
  pglLog(PGL_MODULE_WREN, PGL_LOG_DEBUG, "Allocated Image %p", file);  
  const char* path = wrenGetSlotString(vm, 1); 
  int channels = (int)wrenGetSlotDouble(vm, 2); 
  *file = pglLoadImage(path, channels);

  if(*file == NULL){
    pgl_wren_runtime_error(vm, "Image does not exist");
  }
}

static void Image_finalize(void* data){
  pglLog(PGL_MODULE_WREN, PGL_LOG_DEBUG, "Free Image %p", data);  
  PGLImage** img = data;
  pglDestroyImage(*img);
}
