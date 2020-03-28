#include <modules/platform.h>

PGLFile pglFileOpen(const char* filename, const char* mode){
  FILE* file = fopen(filename, "rb");
  return (PGLFile)file;
}

long pglFileSize(PGLFile file){
  long old = ftell(file);
  long numbytes;
  fseek(file, 0L, SEEK_END);
  numbytes = ftell(file);
  fseek(file, old, SEEK_SET);
  return numbytes;
}

char* pglFileReadString(PGLFile file, long size, size_t* read){
  char* buffer = (char*)malloc((size+1) * sizeof(char));	
  *read = fread(buffer, sizeof(char), size, file);
  buffer[(int)*read] = 0;
  return buffer;
}

char* pglFileReadBytes(PGLFile file, long size, size_t* read){  
  char* buffer = (char*)malloc(size * sizeof(char));	
  *read = fread(buffer, sizeof(char), size, file);
  return buffer;
}

void pglFileClose(PGLFile file){
  fclose(file);
}

char *pglFileReadAllText(const char *filename)
{
  PGLFile file = pglFileOpen(filename, "rb");
  if(file == NULL){
    pglLog(PGL_MODULE_PLATFORM, PGL_LOG_ERROR, "File not found %s", filename);
    return NULL;
  }
  long size = pglFileSize(file);
  size_t read;
  char * str = pglFileReadString(file, size, &read);
  pglFileClose(file);
  return str;
}

char *pglFileReadAllBytes(const char *filename)
{
  PGLFile file = pglFileOpen(filename, "rb");
  if(file == NULL){
    pglLog(PGL_MODULE_PLATFORM, PGL_LOG_ERROR, "File not found %s", filename);
    return NULL;
  }
  long size = pglFileSize(file);
  size_t read;
  char * str = pglFileReadBytes(file, size, &read);
  pglFileClose(file);
  return str;
}