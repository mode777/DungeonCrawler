#include <modules/gl.h>

const char* pglGetGlErrorString(GLenum const err){
  switch (err)
  {
    // opengl 2 errors (8)
    case GL_NO_ERROR:
      return "GL_NO_ERROR";

    case GL_INVALID_ENUM:
      return "GL_INVALID_ENUM";
    case GL_INVALID_VALUE:
      return "GL_INVALID_VALUE";

    case GL_INVALID_OPERATION:
      return "GL_INVALID_OPERATION";

    case GL_OUT_OF_MEMORY:
      return "GL_OUT_OF_MEMORY";

    // opengl 3 errors (1)
    case GL_INVALID_FRAMEBUFFER_OPERATION:
      return "GL_INVALID_FRAMEBUFFER_OPERATION";

    // gles 2, 3 and gl 4 error are handled by the switch above
    default:
      assert(!"unknown error");
      return NULL;
  }
}


void pglCheckGlErrorImpl(const char* fname, int line){
   GLenum error = glGetError();

  if(error != GL_NO_ERROR){
    pglLog(PGL_MODULE_GL, PGL_LOG_ERROR, "GL Error: %s in file %s, line: %i", pglGetGlErrorString(error), fname, line);    
    assert(0);
  }
}