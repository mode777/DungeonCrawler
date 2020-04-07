void File_allocate(WrenVM* vm){
  PGLFile* file = pgl_wren_new(vm, PGLFile); 
  const char* path = wrenGetSlotString(vm, 1); 
  const char* mode = wrenGetSlotString(vm, 2); 
  *file = pglFileOpen(path, mode);
}

static void closeFile(PGLFile* file) 
{ 
  // Already closed.
  if (*file == NULL) return;

  fclose(*file); 
  *file = NULL; 
}

void File_finalize(void* data){
  closeFile((PGLFile*) data);
}

void File_length_0(WrenVM* vm){
  PGLFile* file = (PGLFile*)wrenGetSlotForeign(vm, 0);
  if(*file == NULL){
    pgl_wren_runtime_error(vm, "File does not exist");
    return;
  }

  long size = pglFileSize(*file);
  wrenSetSlotDouble(vm, 0, (double)size);
}

void File_close_0(WrenVM* vm){
  PGLFile* file = (PGLFile*)wrenGetSlotForeign(vm, 0);
  closeFile(file);
}

void File_read_1(WrenVM* vm){
  PGLFile* file = (PGLFile*)wrenGetSlotForeign(vm, 0);
  long length = (long)wrenGetSlotDouble(vm, 1);
  if(*file == NULL){
    pgl_wren_runtime_error(vm, "File does not exist");
    return;
  }
  size_t read;
  char* buffer = pglFileReadBytes(*file, length, &read);
  wrenSetSlotBytes(vm, 0, buffer, read);
  free(buffer);
}