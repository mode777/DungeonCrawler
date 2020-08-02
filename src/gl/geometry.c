#include <modules/gl.h>

GLuint pglTextureFromMemory(void* pixels, int width, int height, int channels){
  GLuint texture;
  glGenTextures(1, &texture);

  GLenum pixelType = channels == 4 ? GL_RGBA : GL_RGB;
  glBindTexture(GL_TEXTURE_2D, texture);
  glTexImage2D(GL_TEXTURE_2D, 0, pixelType, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, pixels);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
  
  return texture;
}



