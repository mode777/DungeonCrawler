#include <modules/renderer3d.h>

static vec4 viewport = {0,0,0,0};

static PGLProgram* program;
static GLenum activeTexture = GL_TEXTURE0;

void pgl3DSetProgram(PGLProgram* p){
  program = p;
  glUseProgram(p->program);
}

void pgl3DSetViewport(float x, float y, float width, float height){
  viewport[0] = x;
  viewport[1] = y;
  viewport[2] = width;
  viewport[3] = height;
  glViewport((GLint)x, (GLint)y, (GLsizei)width, (GLsizei)height);
}

float* pgl3DGetViewport(){
  return &viewport[0];
}

#define CHECKPROG if(program == NULL) return

void pglAttributeEnable(PGLAttribute* a){
  CHECKPROG;

  PGLAttribute attr = *a;
  int location = program->attributes[attr.type];
    
  if(location == -1){
    pglLog(PGL_MODULE_RENDERER, PGL_LOG_DEBUG, "Unknown attribute %i", attr.type);
    return;
  }

  glBindBuffer(GL_ARRAY_BUFFER, attr.buffer);

  glVertexAttribPointer(location, attr.numComponents, attr.componentType, attr.normalized, attr.stride, (void*)attr.offset);
  glEnableVertexAttribArray(location);
}

void pglIndicesDraw(PGLVertexIndices* i) {
  PGLVertexIndices idx = *i;
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, idx.buffer);
  glDrawElements(GL_TRIANGLES, idx.count, idx.componentType, 0);
}

void pglSetUniformMat4(int type, float* mat){
  CHECKPROG;

  int location = program->uniforms[type];

  if(location == -1){
    pglLog(PGL_MODULE_RENDERER, PGL_LOG_DEBUG, "Unknown uniform %i", type);
    return;
  }

  glUniformMatrix4fv(location, 1, GL_FALSE, mat);
}

void pglSetUniformVec3(int type, float* v3){
  CHECKPROG;

  int location = program->uniforms[type];

  if(location == -1){
    pglLog(PGL_MODULE_RENDERER, PGL_LOG_DEBUG, "Unknown uniform %i", type);
    return;
  }
  glUniform3fv(location, 1, v3);
}

void pglSetUniformi(int type, int i){
  CHECKPROG;

  int location = program->uniforms[type];

  if(location == -1){
    pglLog(PGL_MODULE_RENDERER, PGL_LOG_DEBUG, "Unknown uniform %i", type);
    return;
  }

  glUniform1i(location, i);
}

void pglSetTextureUnit(int unit, GLuint texture){
  GLenum eUnit = GL_TEXTURE0 + unit;
  if(unit != activeTexture){
    glActiveTexture(eUnit);
  }
  glBindTexture(GL_TEXTURE_2D, texture);
}

#undef CHECKPROG