static void File_allocate(WrenVM* vm){
  PGLFile* file = pgl_wren_new(vm, PGLFile); 
  const char* path = wrenGetSlotString(vm, 1); 
  const char* mode = wrenGetSlotString(vm, 2); 
  *file = pglFileOpen(path, mode);
  if(*file == NULL){
    pgl_wren_runtime_error(vm, "File does not exist");
    return;
  }
}

static void closeFile(PGLFile* file) 
{ 
  // Already closed.
  if (*file == NULL) return;

  fclose(*file); 
  *file = NULL; 
}

static void File_finalize(void* data){
  closeFile((PGLFile*) data);
}

static void File_length_0(WrenVM* vm){
  PGLFile* file = (PGLFile*)wrenGetSlotForeign(vm, 0);
  long size = pglFileSize(*file);
  wrenSetSlotDouble(vm, 0, (double)size);
}

static void File_close_0(WrenVM* vm){
  PGLFile* file = (PGLFile*)wrenGetSlotForeign(vm, 0);
  closeFile(file);
}

static void File_read_1(WrenVM* vm){
  PGLFile* file = (PGLFile*)wrenGetSlotForeign(vm, 0);
  long length = (long)wrenGetSlotDouble(vm, 1);
  size_t read;
  char* buffer = pglFileReadBytes(*file, length, &read);
  wrenSetSlotBytes(vm, 0, buffer, read);
  free(buffer);
}

static void File_readString_1(WrenVM* vm){
  PGLFile* file = (PGLFile*)wrenGetSlotForeign(vm, 0);
  long length = (long)wrenGetSlotDouble(vm, 1);
  size_t read;
  char* buffer = pglFileReadBytes(*file, length, &read);
  if(buffer[read-1] == 0) read--;
  wrenSetSlotBytes(vm, 0, buffer, read);
  free(buffer);
}

static void File_pos_0(WrenVM* vm){
  FILE* file = *(FILE**)wrenGetSlotForeign(vm, 0);
  long pos = ftell(file);
  wrenSetSlotDouble(vm, 0, (double)pos);
}

static void File_seek_2(WrenVM* vm){
  FILE* file = *(FILE**)wrenGetSlotForeign(vm, 0);
  long offset = wrenGetSlotDouble(vm, 1);
  int pos = wrenGetSlotDouble(vm, 2);
  fseek(file, offset, pos);
}

static void File_readUByte_0(WrenVM* vm){
  FILE* file = *(FILE**)wrenGetSlotForeign(vm, 0);
  unsigned char v;
  fread(&v, sizeof(unsigned char), 1, file);
  wrenSetSlotDouble(vm, 0, (double)v);
}

static void File_readByte_0(WrenVM* vm){
  FILE* file = *(FILE**)wrenGetSlotForeign(vm, 0);
  char v;
  fread(&v, sizeof(char), 1, file);
  wrenSetSlotDouble(vm, 0, (double)v);
}

static void File_readUShort_0(WrenVM* vm){
  FILE* file = *(FILE**)wrenGetSlotForeign(vm, 0);
  unsigned short v;
  fread(&v, sizeof(unsigned short), 1, file);
  wrenSetSlotDouble(vm, 0, (double)v);
}

static void File_readShort_0(WrenVM* vm){
  FILE* file = *(FILE**)wrenGetSlotForeign(vm, 0);
  short v;
  fread(&v, sizeof(short), 1, file);
  wrenSetSlotDouble(vm, 0, (double)v);
}

static void File_readUint_0(WrenVM* vm){
  FILE* file = *(FILE**)wrenGetSlotForeign(vm, 0);
  unsigned int v;
  fread(&v, sizeof(unsigned int), 1, file);
  wrenSetSlotDouble(vm, 0, (double)v);
}

static void File_readInt_0(WrenVM* vm){
  FILE* file = *(FILE**)wrenGetSlotForeign(vm, 0);
  int v;
  fread(&v, sizeof(int), 1, file);
  wrenSetSlotDouble(vm, 0, (double)v);
}

static void File_readFloat_0(WrenVM* vm){
  FILE* file = *(FILE**)wrenGetSlotForeign(vm, 0);
  float v;
  fread(&v, sizeof(float), 1, file);
  wrenSetSlotDouble(vm, 0, (double)v);
}

static void File_readDouble_0(WrenVM* vm){
  FILE* file = *(FILE**)wrenGetSlotForeign(vm, 0);
  double v;
  fread(&v, sizeof(double), 1, file);
  wrenSetSlotDouble(vm, 0, (double)v);
}