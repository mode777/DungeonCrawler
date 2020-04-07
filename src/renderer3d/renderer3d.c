#include <modules/renderer3d.h>

mat4 view;
mat4 projection;
mat4 ident;

static GLuint texture = 0;
static GLuint el_buffer = 0;

vec3 eye = {0, 0, 0};
vec3 target = {1, 0, 0};
vec3 up = {0, 1, 0};

//projection
float aspect = 1.78f;
float fov = 45;
float near = 0.1f;
float far = 100.0f;

GLuint shader;
int uniforms[PGL_UNI3D_MAX];
int attributeLocations[PGL_ATTR_MAX];

static void vec3_print(vec3 vec){
  printf("%f, %f, %f\n", vec[0], vec[1], vec[2]);
}

static void updateProjection()
{
  glm_perspective(glm_rad(fov), aspect, near, far, projection);
  //glm_ortho(-10*aspect, 10, -10, 10, near, far, projection);
  glUniformMatrix4fv(uniforms[PGL_UNI3D_PROJECTION], 1, GL_FALSE, (float *)projection);
}

static void updateView()
{
  glm_lookat(eye, target, up, view);
  //glm_mat4_identity(view);
  glUniformMatrix4fv(uniforms[PGL_UNI3D_VIEW], 1, GL_FALSE, (float *)view);
}

void pgl3DSetCamera(float* eye, float* target, float* up) {
  glm_lookat(eye, target, up, view);
  glUniformMatrix4fv(uniforms[PGL_UNI3D_VIEW], 1, GL_FALSE, (float *)view);
}

static void resetModelTransform()
{
  glUniformMatrix4fv(uniforms[PGL_UNI3D_MODEL], 1, GL_FALSE, (float *)ident);
}

void pgl3DSetViewport(float width, float height){
  glViewport(0,0, (GLsizei)width, (GLsizei)height);
  aspect = width / height;
  updateProjection();
}

// void pgl3DOrbitCamera(float rad, float gamma)
// {
//   eye[0] = sin(gamma) * rad;
//   eye[2] = cos(gamma) * rad;
//   updateView();
// }

void pgl3DSetModelTransform(PGLTransform* transform){
  glUniformMatrix4fv(uniforms[PGL_UNI3D_MODEL], 1, GL_FALSE, pglTransformMatrix(transform));
}

void pgl3DInit()
{
  for(PGLAttributeType i = 0; i < PGL_ATTR_MAX; i++){
    attributeLocations[i] = -1;
  }

  for (PGLUniform3D i = 0; i < PGL_UNI3D_MAX; i++)
  {
    uniforms[i] = -1;
  }

  GLuint prog = pglLoadProgramFile("./shaders/3d.vertex.glsl", "./shaders/3d.fragment.glsl");
  assert(prog != 0);

  attributeLocations[PGL_ATTR_POSITION] = glGetAttribLocation(prog, "vPosition");
  attributeLocations[PGL_ATTR_COLOR] = glGetAttribLocation(prog, "vColor");
  attributeLocations[PGL_ATTR_TEXCOORD0] = glGetAttribLocation(prog, "vTexcoord");

  uniforms[PGL_UNI3D_TEXTURE0] = glGetUniformLocation(prog, "uTexture");
  uniforms[PGL_UNI3D_PROJECTION] = glGetUniformLocation(prog, "uProjection");
  uniforms[PGL_UNI3D_MODEL] = glGetUniformLocation(prog, "uModel");
  uniforms[PGL_UNI3D_VIEW] = glGetUniformLocation(prog, "uView");

  glUseProgram(prog);

  glm_mat4_identity(ident);
  resetModelTransform();
  updateView();
  updateProjection();
}

void pgl3DDrawPrimitive(PGLPrimitive *prim){
  for (size_t i = 0; i < prim->attributeCount; i++)
  {

    PGLAttribute attr = prim->attributes[i];
    int location = attributeLocations[attr.attributeType];
    
    if(location == -1)
      continue;

    //printf("activating attribute type: %i, buffer: %i, location: %i, numComp: %i, compType: %i\n", attr.attributeType, attr.buffer->handle, location, attr.numComponents, attr.componentType);
    glBindBuffer(GL_ARRAY_BUFFER, attr.buffer->handle);

    //glVertexAttribPointer(location, attr.numComponents, GL_FLOAT, false, 0, 0);
    glVertexAttribPointer(location, attr.numComponents, attr.componentType, attr.normalized, attr.buffer->stride, (void*)attr.offset);
    glEnableVertexAttribArray(location);
  }

  GLuint ctext = prim->material.diffuse->handle; 
  if(texture != ctext){
    glBindTexture(GL_TEXTURE_2D, ctext);
    texture = ctext;
  }

  GLuint cel_buffer = prim->index.buffer->handle;
  if(el_buffer != cel_buffer){
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, cel_buffer);
  	el_buffer = cel_buffer;
  }
  //pglCheckGlError();
  glDrawElements(GL_TRIANGLES, prim->index.count, prim->index.componentType, 0);  
  pglCheckGlError();
}