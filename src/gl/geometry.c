#include <modules/gl.h>

GLuint pglTextureFromMemory(void* pixels, int width, int height, int channels){
  GLuint texture;
  glGenTextures(1, &texture);

  GLenum pixelType;

  switch(channels){
    case 1:
      pixelType = GL_LUMINANCE;
      break;
    case 2:
      pixelType = GL_LUMINANCE_ALPHA;
      break;
    case 3:
      pixelType = GL_RGB;
      break;
    case 4:
      pixelType = GL_RGBA;
      break;
  }

  glBindTexture(GL_TEXTURE_2D, texture);
  glTexImage2D(GL_TEXTURE_2D, 0, pixelType, width, height, 0, pixelType, GL_UNSIGNED_BYTE, pixels);
  
  return texture;
}




