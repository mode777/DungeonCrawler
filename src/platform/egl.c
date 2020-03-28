#include "egl.h"
#include <EGL/egl.h>
#include "modules/platform.h"

#define CASE_STR( value ) case value: return #value; 
const char* eglGetErrorString( EGLint error )
{
    switch( error )
    {
    CASE_STR( EGL_SUCCESS             )
    CASE_STR( EGL_NOT_INITIALIZED     )
    CASE_STR( EGL_BAD_ACCESS          )
    CASE_STR( EGL_BAD_ALLOC           )
    CASE_STR( EGL_BAD_ATTRIBUTE       )
    CASE_STR( EGL_BAD_CONTEXT         )
    CASE_STR( EGL_BAD_CONFIG          )
    CASE_STR( EGL_BAD_CURRENT_SURFACE )
    CASE_STR( EGL_BAD_DISPLAY         )
    CASE_STR( EGL_BAD_SURFACE         )
    CASE_STR( EGL_BAD_MATCH           )
    CASE_STR( EGL_BAD_PARAMETER       )
    CASE_STR( EGL_BAD_NATIVE_PIXMAP   )
    CASE_STR( EGL_BAD_NATIVE_WINDOW   )
    CASE_STR( EGL_CONTEXT_LOST        )
    default: return "Unknown";
    }
}
#undef CASE_STR

EGLDisplay eglDisplay;
EGLSurface eglSurface;

void initEgl(void* hwnd){
  // Create EGL display connection
  eglDisplay = eglGetDisplay(EGL_DEFAULT_DISPLAY);
	assert(eglDisplay != EGL_NO_DISPLAY);

  // Initialize EGL for this display, returns EGL version
  eglInitialize(eglDisplay, NULL, NULL);

  eglBindAPI(EGL_OPENGL_ES_API);

 EGLint attribList[] =
  {
      EGL_RENDERABLE_TYPE, EGL_OPENGL_ES2_BIT,
      EGL_SURFACE_TYPE, EGL_SWAP_BEHAVIOR_PRESERVED_BIT,
      EGL_RED_SIZE,       5,
      EGL_GREEN_SIZE,     6,
      EGL_BLUE_SIZE,      5,
      EGL_ALPHA_SIZE,     EGL_DONT_CARE,
      EGL_DEPTH_SIZE,     8,
      EGL_STENCIL_SIZE,   1,
      #ifndef _WIN32
      // ANGLE does not support multisampling this way
      EGL_SAMPLE_BUFFERS, 1,
      #endif
      EGL_NONE
  };

  EGLint numConfigs;
  EGLConfig windowConfig = 0;
  EGLBoolean result = eglChooseConfig(eglDisplay, attribList, &windowConfig, 1, &numConfigs);
	
  assert(EGL_FALSE != result);

  EGLint contextAttributes[] = { 
    EGL_CONTEXT_CLIENT_VERSION, 2, 
    EGL_NONE 
  };
	
  EGLContext eglContext = eglCreateContext(eglDisplay, windowConfig, EGL_NO_CONTEXT, contextAttributes);
	assert(eglContext != EGL_NO_CONTEXT);
  

  EGLint surfaceAttributes[] = { EGL_NONE };
  eglSurface = eglCreateWindowSurface(eglDisplay, windowConfig, hwnd, surfaceAttributes);  
	assert(eglSurface != EGL_NO_SURFACE);

  #ifndef __EMSCRIPTEN__
	// preserve the buffers on swap
	result = eglSurfaceAttrib(eglDisplay, eglSurface, EGL_SWAP_BEHAVIOR, EGL_BUFFER_PRESERVED);
	assert(EGL_FALSE != result);
  #endif

  eglMakeCurrent(eglDisplay, eglSurface, eglSurface, eglContext);
  
  eglSwapInterval(eglDisplay, 1);
  int error = eglGetError();
  if(error != EGL_SUCCESS){
    pglLog(PGL_MODULE_PLATFORM, PGL_LOG_ERROR, "EGL not initialized. %s", eglGetErrorString(error));
  }
  else {
    pglLog(PGL_MODULE_PLATFORM, PGL_LOG_INFO, "EGL initialized");
  }
}

void pglPresent(){
  eglSwapBuffers(eglDisplay, eglSurface);
}
