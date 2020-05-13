#ifndef PLATFORM_H
#define PLATFORM_H

#include "common.h"

typedef struct { 
  PGLHandle handle; 
  size_t width;
  size_t height;
} PGLWindow;

typedef PGLHandle PGLFile;
typedef void (*PGLUpdateFunc)(double);
typedef void (*PGLMouseMoveFunc)(int, int);
typedef void (*PGLKeyFunc)(const char *);
typedef struct {
  PGLUpdateFunc update;
  PGLMouseMoveFunc mouseMove;
  PGLKeyFunc keyUp;
  PGLKeyFunc keyDown;
} PGLPlatformCallbacks;

typedef struct {
  size_t width;
  size_t height;
  const char* title; 
} PGLWindowConfig;

typedef struct {
  int x;
  int y;
} PGLMousePos;

void pglPlatformInit();

void pglWindowConfig(PGLWindowConfig* config);
PGLWindow* pglCreateWindow();
void pglDestroyWindow(PGLWindow* win);
void pglRegisterCallbacks(PGLPlatformCallbacks* callbacks);
void pglRun();
void pglPresent();

bool pglIsKeyDown(const char* key);
PGLMousePos pglGetMousePosition();
void pglSetMousePosition(int x, int y);

PGLFile pglFileOpen(const char* filename, const char* mode);
long pglFileSize(PGLFile file);
char* pglFileReadString(PGLFile file, long size, size_t* read);
char* pglFileReadBytes(PGLFile file, long size, size_t* read);
void pglFileClose(PGLFile file);
char* pglFileReadAllText(const char* filename);
char* pglFileReadAllBytes(const char* filename);
void pglQuit();

#endif
