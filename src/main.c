#include <modules/modules.h>

//#define PGL_DEBUG

PGLWindow* window;

static void update(double delta){
  //glClearColor(0.08f, 0.0f, 0.1f, 1);
  glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

  pglCallWrenUpdate(delta);

  pglPresent();

  //pglCheckGlError();
}

static void vec3_print(vec3 vec){
  printf("%f, %f, %f\n", vec[0], vec[1], vec[2]);
} 

int main(int argc, char *argv[])
{
  pglLogLevel(PGL_LOG_WARNING);

  pglInitWren(argc, argv);

  pglPlatformInit();

  pglCallWrenInit();

  window = pglCreateWindow();
  pgl3DSetViewport(0,0, window->width, window->height);

  PGLPlatformCallbacks callbacks = {0};
  callbacks.update = &update;
  
  pglRegisterCallbacks(&callbacks);
  pglCheckGlError();

  pglCallWrenLoad();

  pglRun();
}

