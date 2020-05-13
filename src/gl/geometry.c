#include <modules/gl.h>

PGLTexture* pglTextureFromMemory(void* pixels, int width, int height, int channels){
  GLuint texture;
  glGenTextures(1, &texture);

  GLenum pixelType = channels == 4 ? GL_RGBA : GL_RGB;
  glBindTexture(GL_TEXTURE_2D, texture);
  glTexImage2D(GL_TEXTURE_2D, 0, pixelType, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, pixels);
  glGenerateMipmap(GL_TEXTURE_2D);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
  
  PGLTexture* wrapper = calloc(1, sizeof(PGLTexture));
  wrapper->handle = texture;

  return pglTextureTake(wrapper);
}

PGLTexture* pglTextureTake(PGLTexture* texture){
  texture->refCount++;
  return texture;
}

void pglTextureDelete(PGLTexture* texture){
  texture->refCount--;
  if(texture->refCount < 1){
    pglLog(PGL_MODULE_GL, PGL_LOG_DEBUG, "Destroy texture %i", texture->handle);
    glDeleteTextures(1, &texture->handle);
    free(texture);
  }
}




