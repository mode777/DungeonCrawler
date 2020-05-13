#include <modules/modules.h>

//#define PGL_DEBUG

PGLWindow* window;

static void update(double delta){
  glClearColor(0.08f, 0.0f, 0.1f, 1);
  glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

  pglCallWrenUpdate(delta);

  pglPresent();

  pglCheckGlError();
}

static void vec3_print(vec3 vec){
  printf("%f, %f, %f\n", vec[0], vec[1], vec[2]);
} 

int main(int argc, char *argv[])
{
  pglLogLevel(PGL_LOG_WARNING);
  //pglLogModLevel(PGL_MODULE_WREN, PGL_LOG_DEBUG);

  pglInitWren(argc, argv);

  pglPlatformInit();

  pglCallWrenInit();

  window = pglCreateWindow();
  //pgl3DInit();
  pgl3DSetViewport(0,0, window->width, window->height);

  glEnable(GL_DEPTH_TEST);
  glEnable(GL_CULL_FACE);
  //glEnable(GL_BLEND);
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);  
  glCullFace(GL_BACK);  

  // PGLTransform* t = pglTransformCreate();
  // pglTransformTranslate(t, -1, 0, 1);
  // pglTransformRotate(t, 0, 0, -1);
  // pgl3DSetCameraTransform(t);

  PGLPlatformCallbacks callbacks = {0};
  callbacks.update = &update;
  
  pglRegisterCallbacks(&callbacks);
  pglCheckGlError();

  // PGLTransform* t = pglTransformCreate();
  // pglTransformScale(t, 2, 1, 1);
  // pglTransformRotate(t, 0, 1, 0);
  // pgl3DSetModelTransform(t);

  pglCallWrenLoad();

  pglRun();
}

