#include <modules/common.h>

PGLLogSeverity levels[PGL_MODULE_ALL] = {0};

static const char *module_str(PGLModule mod)
{
  switch (mod)
  {
    case PGL_MODULE_CORE: return "CORE";
    case PGL_MODULE_GL: return "GL";
    case PGL_MODULE_JSON: return "JSON";
    case PGL_MODULE_WREN: return "WREN";
    case PGL_MODULE_PLATFORM: return "PLATFORM";
    case PGL_MODULE_RENDERER: return "RENDERER";
    case PGL_MODULE_IMAGE: return "IMAGE";
    default: return "UNKNOWN";
  }
}

static const char *severity_str(PGLLogSeverity mod)
{
  switch (mod)
  {
    case PGL_LOG_ERROR: return "ERROR";
    case PGL_LOG_WARNING: return "WARNING";
    case PGL_LOG_INFO: return "INFO";
    case PGL_LOG_DEBUG: return "DEBUG";
    default: return "";
  }
}

void pglLog(PGLModule mod, PGLLogSeverity sev, const char *formatStr, ...)
{
  //printf("%i, %i %i\n", mod, sev, levels[mod]);
  //if(sev > PGL_LOG_INFO)
  if((int)levels[mod] < sev){
    return;
  }

  va_list params;
  char buf[BUFSIZ];

  va_start(params, formatStr);

  //vsprintf_s(buf, sizeof(buf), formatStr, params);
  vsnprintf(buf, sizeof(buf), formatStr, params);
  printf("[%s] %s: %s\n", module_str(mod), severity_str(sev), buf);

  va_end(params);
}

void pglLogLevel(PGLLogSeverity sev){
  for (int i = 0; i < PGL_MODULE_ALL; i++)
  {
    levels[i] = sev;  
  }  
}

void pglLogModLevel(PGLModule mod, PGLLogSeverity sev){
  levels[mod] = sev;  
}