#ifndef TEXTURE_H
#define TEXTURE_H

#include "commongl.h"
#include "image.h"


typedef struct {
  GLuint handle;
} Texture;

Texture* createTextureFromImage(PGLImage* image){
  unsigned int texture;
  glGenTextures(1, &texture);
  glBindTexture(GL_TEXTURE_2D, texture);
  // set the texture wrapping/filtering options (on the currently bound texture object)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);	
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);  
  glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, image->width, image->height, 0, GL_RGBA, GL_UNSIGNED_BYTE, image->pixels);
  glGenerateMipmap(GL_TEXTURE_2D);

  Texture* textureObj = (Texture*)malloc(sizeof(Texture));
  return textureObj;
}

void destroyTexture(Texture* texture){
  glDeleteTextures(1, &(texture->handle));
  free(texture);
}

#endif