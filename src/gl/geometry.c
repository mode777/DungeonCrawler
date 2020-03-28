#include <modules/gl.h>

PGLTexture* pglCreateTexture(PGLImage* img){
  GLuint texture;
  glGenTextures(1, &texture);

  GLenum pixelType = img->channels == 4 ? GL_RGBA : GL_RGB;
  glBindTexture(GL_TEXTURE_2D, texture);
  glTexImage2D(GL_TEXTURE_2D, 0, pixelType, img->width, img->height, 0, GL_RGBA, GL_UNSIGNED_BYTE, img->pixels);
  glGenerateMipmap(GL_TEXTURE_2D);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
  
  PGLTexture* wrapper = calloc(1, sizeof(PGLTexture));
  wrapper->handle = texture;

  return pglTakeTexture(wrapper);
}

PGLTexture* pglTakeTexture(PGLTexture* texture){
  texture->refCount++;
  return texture;
}

void pglReleaseTexture(PGLTexture* texture){
  texture->refCount--;
  if(texture->refCount < 1){
    pglLog(PGL_MODULE_GL, PGL_LOG_DEBUG, "Destroy texture %i", texture->handle);
    glDeleteTextures(1, &texture->handle);
    free(texture);
  }
}

PGLGeometryBuffer* pglCreateGeometryBuffer(void* data, GLsizei offset, GLsizei size, GLsizei stride, bool areIndices){
  PGLGeometryBuffer* buffer = calloc(1, sizeof(PGLGeometryBuffer));

  buffer->stride = stride;
  GLenum target = areIndices ? GL_ELEMENT_ARRAY_BUFFER : GL_ARRAY_BUFFER;

  glGenBuffers(1, &buffer->handle);
  glBindBuffer(target, buffer->handle);
  glBufferData(target, size, (void*)((char*)data+offset), GL_STATIC_DRAW);
  
  pglCheckGlError();

  return pglTakeGeometryBuffer(buffer);
}

PGLGeometryBuffer* pglTakeGeometryBuffer(PGLGeometryBuffer* buffer) {
  buffer->refCount++;
  return buffer;
}

void pglReleaseGeometryBuffer(PGLGeometryBuffer* buffer){
  if(buffer == NULL)
    return;

  buffer->refCount--;
  if(buffer->refCount < 1){
    pglLog(PGL_MODULE_GL, PGL_LOG_DEBUG, "Destroy buffer %i", buffer->handle);
    glDeleteBuffers(1, &buffer->handle);
    free(buffer);
  }  
}