#ifndef COMMON_H
#define COMMON_H

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <assert.h>
#include <stdarg.h>
#include <stddef.h>
#include <stdbool.h>
#include <math.h>

#if defined(__arm__) && defined(__unix__)
#define PGL_PLATFORM_RPI
#elif defined (_WIN32)
#define PGL_PLATFORM_WIN
#elif defined (EMSCRIPTEN)
#define PGL_PLATFORM_WASM
#elif defined(__unix__)
#define PGL_PLATFORM_LINUX
#endif

typedef void * PGLHandle;
typedef unsigned int PGLUHandle;

typedef enum {
  PGL_MODULE_UNKNOWN = 0,
  PGL_MODULE_CORE = 1,
  PGL_MODULE_GL = 2,
  PGL_MODULE_JSON = 3,
  PGL_MODULE_WREN = 4,
  PGL_MODULE_PLATFORM = 5,
  PGL_MODULE_RENDERER = 6,
  PGL_MODULE_IMAGE = 7,
  PGL_MODULE_ALL = 8
} PGLModule;

typedef enum {
  PGL_LOG_OFF = 0,
  PGL_LOG_ERROR = 1,
  PGL_LOG_WARNING = 2,
  PGL_LOG_INFO = 3,
  PGL_LOG_DEBUG = 4,
  PGL_LOG_ALL = ~0
} PGLLogSeverity;

void pglLog(PGLModule mod, PGLLogSeverity sev, const char *formatStr, ...);
void pglLogLevel(PGLLogSeverity sev);
void pglLogModLevel(PGLModule mod, PGLLogSeverity sev);

#endif