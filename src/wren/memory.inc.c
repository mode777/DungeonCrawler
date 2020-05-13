#include "wrenapi.h"
#include <modules/memory.h>
#include <modules/platform.h>

static void Buffer_allocate(WrenVM* vm){
  PGLBuffer** handle = pgl_wren_new(vm, PGLBuffer*);
  *handle = NULL;
  pglLog(PGL_MODULE_WREN, PGL_LOG_DEBUG, "Allocated Buffer %p", handle);  
}

static void Buffer_finalize(void* data){
  pglLog(PGL_MODULE_WREN, PGL_LOG_DEBUG, "Free Buffer %p", data);
  PGLBufferDelete(*(PGLBuffer**)data);
}

static void Buffer_init_load_1(WrenVM* vm){
  PGLBuffer** handle = (PGLBuffer**)wrenGetSlotForeign(vm, 0);
  
  const char* filename = wrenGetSlotString(vm, 1);
  PGLFile file = pglFileOpen(filename, "rb");
  if(file == NULL){
    pgl_wren_runtime_error(vm, "File not found");
  }
  size_t size = pglFileSize(file);
  size_t read = 0;
  
  PGLBuffer* buffer = PGLBufferFromData(pglFileReadBytes(file, size, &read), size);

  pglFileClose(file);

  *handle = buffer;
}

static void Buffer_init_allocate_1(WrenVM* vm){
  PGLBuffer** handle = (PGLBuffer**)wrenGetSlotForeign(vm, 0);
  size_t size = (size_t)wrenGetSlotDouble(vm, 1);
  PGLBuffer* buffer = PGLBufferCreate(size);
  *handle = buffer;
}

static void Buffer_init_copy_3(WrenVM* vm){
  PGLBuffer** handle = (PGLBuffer**)wrenGetSlotForeign(vm, 0);
  PGLBuffer* sourceBuffer = *(PGLBuffer**)wrenGetSlotForeign(vm, 1);
  size_t offset = (size_t)wrenGetSlotDouble(vm, 2);
  size_t size = (size_t)wrenGetSlotDouble(vm, 3);

  PGLBuffer* buffer = PGLBufferClone(sourceBuffer, offset, size);
  *handle = buffer;
}

static void Buffer_copyFrom_4(WrenVM* vm){
  PGLBuffer* dstBuffer = *(PGLBuffer**)wrenGetSlotForeign(vm, 0);
  PGLBuffer* sourceBuffer = *(PGLBuffer**)wrenGetSlotForeign(vm, 1);
  size_t offset = (size_t)wrenGetSlotDouble(vm, 2);
  size_t size = (size_t)wrenGetSlotDouble(vm, 3);
  size_t dstOffset = (size_t)wrenGetSlotDouble(vm, 4);

  memcpy(&dstBuffer->data[dstOffset], &sourceBuffer->data[offset], size);
}

static void Buffer_getSize_0(WrenVM* vm){
  PGLBuffer* buffer = *(PGLBuffer**)wrenGetSlotForeign(vm, 0);
  wrenSetSlotDouble(vm, 0, (double)buffer->size);
}

#define pgl_buffer_val(T, offset) ((T*)&((char*)buffer->data)[offset])
#define pgl_check_bounds(T, offset) if(offset+sizeof(T) > buffer->size) { pgl_wren_runtime_error(vm, "Buffer out of bounds"); return; }
#define pgl_check_bounds_vec(T, offset, numComp) if(offset+(sizeof(T)*numComp) > buffer->size) { pgl_wren_runtime_error(vm, "Buffer out of bounds"); return; }

static void Buffer_readByte_1(WrenVM* vm){
  PGLBuffer* buffer = *(PGLBuffer**)wrenGetSlotForeign(vm, 0);  
  int offset = (int)wrenGetSlotDouble(vm, 1);
  pgl_check_bounds(char,offset)
  wrenSetSlotDouble(vm, 0, (double)*pgl_buffer_val(char, offset));
}

static void Buffer_readShort_1(WrenVM* vm){
  PGLBuffer* buffer = *(PGLBuffer**)wrenGetSlotForeign(vm, 0);
  int offset = (int)wrenGetSlotDouble(vm, 1);
  pgl_check_bounds(short,offset)
  wrenSetSlotDouble(vm, 0, (double)*pgl_buffer_val(short, offset));
}

static void Buffer_readInt_1(WrenVM* vm){
  PGLBuffer* buffer = *(PGLBuffer**)wrenGetSlotForeign(vm, 0);
  int offset = (int)wrenGetSlotDouble(vm, 1);
  pgl_check_bounds(int,offset)
  wrenSetSlotDouble(vm, 0, (double)*pgl_buffer_val(int, offset));
}

static void Buffer_readUByte_1(WrenVM* vm){
  PGLBuffer* buffer = *(PGLBuffer**)wrenGetSlotForeign(vm, 0);
  int offset = (int)wrenGetSlotDouble(vm, 1);
  pgl_check_bounds(unsigned char,offset)
  wrenSetSlotDouble(vm, 0, (double)*pgl_buffer_val(unsigned char, offset));
}

static void Buffer_readUShort_1(WrenVM* vm){
  PGLBuffer* buffer = *(PGLBuffer**)wrenGetSlotForeign(vm, 0);
  int offset = (int)wrenGetSlotDouble(vm, 1);
  pgl_check_bounds(unsigned short,offset)
  wrenSetSlotDouble(vm, 0, (double)*pgl_buffer_val(unsigned short, offset));
}

static void Buffer_readUInt_1(WrenVM* vm){
  PGLBuffer* buffer = *(PGLBuffer**)wrenGetSlotForeign(vm, 0);
  int offset = (int)wrenGetSlotDouble(vm, 1);
  pgl_check_bounds(unsigned int,offset)
  wrenSetSlotDouble(vm, 0, (double)*pgl_buffer_val(unsigned int, offset));
}

static void Buffer_readFloat_1(WrenVM* vm){
  PGLBuffer* buffer = *(PGLBuffer**)wrenGetSlotForeign(vm, 0);
  int offset = (int)wrenGetSlotDouble(vm, 1);
  pgl_check_bounds(float,offset)
  wrenSetSlotDouble(vm, 0, (double)*pgl_buffer_val(float, offset));
}

static void Buffer_readDouble_1(WrenVM* vm){
  PGLBuffer* buffer = *(PGLBuffer**)wrenGetSlotForeign(vm, 0);
  int offset = (int)wrenGetSlotDouble(vm, 1);
  pgl_check_bounds(double,offset)
  wrenSetSlotDouble(vm, 0, (double)*pgl_buffer_val(double, offset));
}

static void Buffer_readByteVec_2(WrenVM* vm){
  PGLBuffer* buffer = *(PGLBuffer**)wrenGetSlotForeign(vm, 0);
  int offset = (int)wrenGetSlotDouble(vm, 1);
  int count = wrenGetListCount(vm, 2);
  pgl_check_bounds_vec(char,offset,count)
  char* vec = pgl_buffer_val(char, offset);
  for (int i = 0; i < count; i++)
  {
    wrenSetSlotDouble(vm, 0, (double)vec[i]);
    wrenSetListElement(vm, 2, i, 0);
  } 
}

static void Buffer_readShortVec_2(WrenVM* vm){
  PGLBuffer* buffer = *(PGLBuffer**)wrenGetSlotForeign(vm, 0);
  int offset = (int)wrenGetSlotDouble(vm, 1);
  int count = wrenGetListCount(vm, 2);
  pgl_check_bounds_vec(short,offset,count)
  short* vec = pgl_buffer_val(short, offset);
  for (int i = 0; i < count; i++)
  {
    wrenSetSlotDouble(vm, 0, (double)vec[i]);
    wrenSetListElement(vm, 2, i, 0);
  } 
}

static void Buffer_readIntVec_2(WrenVM* vm){
  PGLBuffer* buffer = *(PGLBuffer**)wrenGetSlotForeign(vm, 0);
  int offset = (int)wrenGetSlotDouble(vm, 1);
  int count = wrenGetListCount(vm, 2);
  pgl_check_bounds_vec(int,offset,count)
  int* vec = pgl_buffer_val(int, offset);
  for (int i = 0; i < count; i++)
  {
    wrenSetSlotDouble(vm, 0, (double)vec[i]);
    wrenSetListElement(vm, 2, i, 0);
  } 
}

static void Buffer_readUByteVec_2(WrenVM* vm){
  PGLBuffer* buffer = *(PGLBuffer**)wrenGetSlotForeign(vm, 0);
  int offset = (int)wrenGetSlotDouble(vm, 1);
  int count = wrenGetListCount(vm, 2);
  pgl_check_bounds_vec(unsigned char,offset,count)
  unsigned char* vec = pgl_buffer_val(unsigned char, offset);
  for (int i = 0; i < count; i++)
  {
    wrenSetSlotDouble(vm, 0, (double)vec[i]);
    wrenSetListElement(vm, 2, i, 0);
  } 
}

static void Buffer_readUShortVec_2(WrenVM* vm){
  PGLBuffer* buffer = *(PGLBuffer**)wrenGetSlotForeign(vm, 0);
  int offset = (int)wrenGetSlotDouble(vm, 1);
  int count = wrenGetListCount(vm, 2);
  pgl_check_bounds_vec(unsigned short,offset,count)
  unsigned short* vec = pgl_buffer_val(unsigned short, offset);
  for (int i = 0; i < count; i++)
  {
    wrenSetSlotDouble(vm, 0, (double)vec[i]);
    wrenSetListElement(vm, 2, i, 0);
  } 
}

static void Buffer_readUIntVec_2(WrenVM* vm){
  PGLBuffer* buffer = *(PGLBuffer**)wrenGetSlotForeign(vm, 0);
  int offset = (int)wrenGetSlotDouble(vm, 1);
  int count = wrenGetListCount(vm, 2);
  pgl_check_bounds_vec(unsigned int,offset,count)
  unsigned int* vec = pgl_buffer_val(unsigned int, offset);
  for (int i = 0; i < count; i++)
  {
    wrenSetSlotDouble(vm, 0, (double)vec[i]);
    wrenSetListElement(vm, 2, i, 0);
  } 
}

static void Buffer_readFloatVec_2(WrenVM* vm){
  PGLBuffer* buffer = *(PGLBuffer**)wrenGetSlotForeign(vm, 0);
  int offset = (int)wrenGetSlotDouble(vm, 1);
  int count = wrenGetListCount(vm, 2);
  pgl_check_bounds_vec(float,offset,count)
  float* vec = pgl_buffer_val(float, offset);
  for (int i = 0; i < count; i++)
  {
    wrenSetSlotDouble(vm, 0, (double)vec[i]);
    wrenSetListElement(vm, 2, i, 0);
  } 
}

static void Buffer_readDoubleVec_2(WrenVM* vm){
  PGLBuffer* buffer = *(PGLBuffer**)wrenGetSlotForeign(vm, 0);
  int offset = (int)wrenGetSlotDouble(vm, 1);
  int count = wrenGetListCount(vm, 2);
  pgl_check_bounds_vec(double,offset,count)
  double* vec = pgl_buffer_val(double, offset);
  for (int i = 0; i < count; i++)
  {
    wrenSetSlotDouble(vm, 0, (double)vec[i]);
    wrenSetListElement(vm, 2, i, 0);
  } 
}

static void Buffer_writeByte_2(WrenVM* vm){
  PGLBuffer* buffer = *(PGLBuffer**)wrenGetSlotForeign(vm, 0);
  int offset = (int)wrenGetSlotDouble(vm, 1);
  double val = wrenGetSlotDouble(vm, 2);
  pgl_check_bounds(char ,offset)
  *pgl_buffer_val(char, offset) = (char)val;
}

static void Buffer_writeShort_2(WrenVM* vm){
  PGLBuffer* buffer = *(PGLBuffer**)wrenGetSlotForeign(vm, 0);
  int offset = (int)wrenGetSlotDouble(vm, 1);
  double val = wrenGetSlotDouble(vm, 2);
  pgl_check_bounds(short ,offset)
  *pgl_buffer_val(short, offset) = (short)val;
}

static void Buffer_writeInt_2(WrenVM* vm){
  PGLBuffer* buffer = *(PGLBuffer**)wrenGetSlotForeign(vm, 0);
  int offset = (int)wrenGetSlotDouble(vm, 1);
  double val = wrenGetSlotDouble(vm, 2);
  pgl_check_bounds(int ,offset)
  *pgl_buffer_val(int, offset) = (int)val;
}

static void Buffer_writeUByte_2(WrenVM* vm){
  PGLBuffer* buffer = *(PGLBuffer**)wrenGetSlotForeign(vm, 0);
  int offset = (int)wrenGetSlotDouble(vm, 1);
  double val = wrenGetSlotDouble(vm, 2);
  pgl_check_bounds(unsigned char ,offset)
  *pgl_buffer_val(unsigned char, offset) = (unsigned char)val;
}

static void Buffer_writeUShort_2(WrenVM* vm){
  PGLBuffer* buffer = *(PGLBuffer**)wrenGetSlotForeign(vm, 0);
  int offset = (int)wrenGetSlotDouble(vm, 1);
  double val = wrenGetSlotDouble(vm, 2);
  pgl_check_bounds(unsigned short ,offset)
  *pgl_buffer_val(unsigned short, offset) = (unsigned short)val;
}

static void Buffer_writeUInt_2(WrenVM* vm){
  PGLBuffer* buffer = *(PGLBuffer**)wrenGetSlotForeign(vm, 0);
  int offset = (int)wrenGetSlotDouble(vm, 1);
  double val = wrenGetSlotDouble(vm, 2);
  pgl_check_bounds(unsigned int ,offset)
  *pgl_buffer_val(unsigned int, offset) = (unsigned int)val;
}

static void Buffer_writeFloat_2(WrenVM* vm){
  PGLBuffer* buffer = *(PGLBuffer**)wrenGetSlotForeign(vm, 0);
  int offset = (int)wrenGetSlotDouble(vm, 1);
  double val = wrenGetSlotDouble(vm, 2);
  pgl_check_bounds(float ,offset)
  *pgl_buffer_val(float, offset) = (float)val;
}

static void Buffer_writeDouble_2(WrenVM* vm){
  PGLBuffer* buffer = *(PGLBuffer**)wrenGetSlotForeign(vm, 0);
  int offset = (int)wrenGetSlotDouble(vm, 1);
  double val = wrenGetSlotDouble(vm, 2);
  pgl_check_bounds(double ,offset)
  *pgl_buffer_val(double, offset) = (double)val;
}

static void Buffer_writeByteVec_2(WrenVM* vm){
  PGLBuffer* buffer = *(PGLBuffer**)wrenGetSlotForeign(vm, 0);
  int offset = (int)wrenGetSlotDouble(vm, 1);
  int count = wrenGetListCount(vm, 2);
  pgl_check_bounds_vec(char,offset,count)
  char* vec = pgl_buffer_val(char, offset);
  for (int i = 0; i < count; i++)
  {
    wrenGetListElement(vm, 2, i, 0);
    vec[i] = (char)wrenGetSlotDouble(vm, 0);
  } 
}

static void Buffer_writeShortVec_2(WrenVM* vm){
  PGLBuffer* buffer = *(PGLBuffer**)wrenGetSlotForeign(vm, 0);
  int offset = (int)wrenGetSlotDouble(vm, 1);
  int count = wrenGetListCount(vm, 2);
  pgl_check_bounds_vec(short,offset,count)
  short* vec = pgl_buffer_val(short, offset);
  for (int i = 0; i < count; i++)
  {
    wrenGetListElement(vm, 2, i, 0);
    vec[i] = (short)wrenGetSlotDouble(vm, 0);
  } 
}

static void Buffer_writeIntVec_2(WrenVM* vm){
  PGLBuffer* buffer = *(PGLBuffer**)wrenGetSlotForeign(vm, 0);
  int offset = (int)wrenGetSlotDouble(vm, 1);
  int count = wrenGetListCount(vm, 2);
  pgl_check_bounds_vec(int,offset,count)
  int* vec = pgl_buffer_val(int, offset);
  for (int i = 0; i < count; i++)
  {
    wrenGetListElement(vm, 2, i, 0);
    vec[i] = (int)wrenGetSlotDouble(vm, 0);
  } 
}

static void Buffer_writeUByteVec_2(WrenVM* vm){
  PGLBuffer* buffer = *(PGLBuffer**)wrenGetSlotForeign(vm, 0);
  int offset = (int)wrenGetSlotDouble(vm, 1);
  int count = wrenGetListCount(vm, 2);
  pgl_check_bounds_vec(unsigned char,offset,count)
  unsigned char* vec = pgl_buffer_val(unsigned char, offset);
  for (int i = 0; i < count; i++)
  {
    wrenGetListElement(vm, 2, i, 0);
    vec[i] = (unsigned char)wrenGetSlotDouble(vm, 0);
  } 
}

static void Buffer_writeUShortVec_2(WrenVM* vm){
  PGLBuffer* buffer = *(PGLBuffer**)wrenGetSlotForeign(vm, 0);
  int offset = (int)wrenGetSlotDouble(vm, 1);
  int count = wrenGetListCount(vm, 2);
  pgl_check_bounds_vec(unsigned short,offset,count)
  unsigned short* vec = pgl_buffer_val(unsigned short, offset);
  for (int i = 0; i < count; i++)
  {
    wrenGetListElement(vm, 2, i, 0);
    vec[i] = (unsigned short)wrenGetSlotDouble(vm, 0);
  } 
}

static void Buffer_writeUIntVec_2(WrenVM* vm){
  PGLBuffer* buffer = *(PGLBuffer**)wrenGetSlotForeign(vm, 0);
  int offset = (int)wrenGetSlotDouble(vm, 1);
  int count = wrenGetListCount(vm, 2);
  pgl_check_bounds_vec(unsigned int,offset,count)
  unsigned int* vec = pgl_buffer_val(unsigned int, offset);
  for (int i = 0; i < count; i++)
  {
    wrenGetListElement(vm, 2, i, 0);
    vec[i] = (unsigned int)wrenGetSlotDouble(vm, 0);
  } 
}

static void Buffer_writeFloatVec_2(WrenVM* vm){
  PGLBuffer* buffer = *(PGLBuffer**)wrenGetSlotForeign(vm, 0);
  int offset = (int)wrenGetSlotDouble(vm, 1);
  int count = wrenGetListCount(vm, 2);
  pgl_check_bounds_vec(float,offset,count)
  float* vec = pgl_buffer_val(float, offset);
  for (int i = 0; i < count; i++)
  {
    wrenGetListElement(vm, 2, i, 0);
    float val = (float)wrenGetSlotDouble(vm, 0);
    vec[i] = val;
  } 
}

static void Buffer_writeDoubleVec_2(WrenVM* vm){
  PGLBuffer* buffer = *(PGLBuffer**)wrenGetSlotForeign(vm, 0);
  int offset = (int)wrenGetSlotDouble(vm, 1);
  int count = wrenGetListCount(vm, 2);
  pgl_check_bounds_vec(double,offset,count)
  double* vec = pgl_buffer_val(double, offset);
  for (int i = 0; i < count; i++)
  {
    wrenGetListElement(vm, 2, i, 0);
    vec[i] = (double)wrenGetSlotDouble(vm, 0);
  } 
}