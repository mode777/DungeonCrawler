#include "wrenapi.h"

static void pgl_wren_runtime_error(WrenVM* vm, const char * error){
  wrenSetSlotString(vm, 0, error); 
  wrenAbortFiber(vm, 0);
}

#include "math.inc.c"
#include "platform.inc.c"
#include "io.inc.c"
#include "renderer.inc.c"
#include "graphics.inc.c"
#include "json.inc.c"
#include "image.inc.c"
#include "memory.inc.c"

void pgl_wren_bind_api(){
  
  // platform
  pgl_wren_bind_method("platform.Keyboard.isDown(_)", Keyboard_isDown_1);  
  pgl_wren_bind_method("platform.Window.config(_,_,_)", Window_config_3);
  pgl_wren_bind_method("platform.Application.logLevel(_)", Application_logLevel_1);
  pgl_wren_bind_method("platform.Application.logLevel(_,_)", Application_logLevel_2);
  pgl_wren_bind_method("platform.Application.pollEvent(_)", Application_pollEvent_1);
  pgl_wren_bind_method("platform.Application.quit()", Application_quit_0);
  pgl_wren_bind_method("platform.Application.loadModuleInternal(_,_)", Application_loadModule_2);
  pgl_wren_bind_method("platform.Mouse.getPosition(_)", Mouse_getPosition_1);
  pgl_wren_bind_method("platform.Mouse.setPosition(_,_)", Mouse_setPosition_2);

  //io
  pgl_wren_bind_class("io.File", File_allocate, File_finalize);
  pgl_wren_bind_method("io.File.length()", File_length_0);
  pgl_wren_bind_method("io.File.close()", File_close_0);
  pgl_wren_bind_method("io.File.read(_)", File_read_1);
  pgl_wren_bind_method("io.File.readString(_)", File_readString_1);
  pgl_wren_bind_method("io.File.pos()", File_pos_0);
  pgl_wren_bind_method("io.File.readUByte()", File_readUByte_0);
  pgl_wren_bind_method("io.File.readByte()", File_readByte_0);
  pgl_wren_bind_method("io.File.readUShort()", File_readUShort_0);
  pgl_wren_bind_method("io.File.readShort()", File_readShort_0);
  pgl_wren_bind_method("io.File.readUInt()", File_readUint_0);
  pgl_wren_bind_method("io.File.readInt()", File_readInt_0);
  pgl_wren_bind_method("io.File.readFloat()", File_readFloat_0);
  pgl_wren_bind_method("io.File.readDouble()", File_readDouble_0);
  pgl_wren_bind_method("io.File.seek(_,_)", File_seek_2);


  //json
  pgl_wren_bind_class("json.JsonParser", JSONParser_allocate, JSONParser_finalize);
  pgl_wren_bind_method("json.JsonParser.getValue()", JSONParser_getValue_0);
  pgl_wren_bind_method("json.JsonParser.getToken()", JSONParser_getToken_0);
  pgl_wren_bind_method("json.JsonParser.nextToken()", JSONParser_nextToken_0);
  pgl_wren_bind_method("json.JsonParser.getChildren()", JSONParser_getChildren_0);
  
  //image
  pgl_wren_bind_class("image.Image", Image_allocate, Image_finalize);
  pgl_wren_bind_method("image.Image.load(_,_)", Image_load_2);
  pgl_wren_bind_method("image.Image.buffer(_,_,_,_)", Image_buffer_4);
  pgl_wren_bind_method("image.Image.allocate(_,_,_)", Image_allocate_3);
  pgl_wren_bind_method("image.Image.put(_,_,_,_,_,_,_)", Image_put_7);
  pgl_wren_bind_method("image.Image.setPixel(_,_,_)", Image_setPixel_3);
  pgl_wren_bind_method("image.Image.getPixel(_,_,_)", Image_getPixel_3);
  pgl_wren_bind_method("image.Image.getPixelInt(_,_)", Image_getPixelInt_2);
  pgl_wren_bind_method("image.Image.save(_)", Image_save_1);
  pgl_wren_bind_method("image.Image.getWidth()", Image_getWidth_0);
  pgl_wren_bind_method("image.Image.getHeight()", Image_getHeight_0);

  //math
  pgl_wren_bind_class("math.Mat4", Mat4_allocate, Mat4_finalize);
  pgl_wren_bind_method("math.Mat4.identity()", Mat4_identity_0);
  pgl_wren_bind_method("math.Mat4.translate(_,_,_)", Mat4_translate_3);
  pgl_wren_bind_method("math.Mat4.rotateX(_)", Mat4_rotateX_1);
  pgl_wren_bind_method("math.Mat4.rotateY(_)", Mat4_rotateY_1);
  pgl_wren_bind_method("math.Mat4.rotateZ(_)", Mat4_rotateZ_1);
  pgl_wren_bind_method("math.Mat4.rotateQuat(_,_,_,_)", Mat4_rotateQuat_4);
  pgl_wren_bind_method("math.Mat4.scale(_,_,_)", Mat4_scale_3);
  pgl_wren_bind_method("math.Mat4.copy(_)", Mat4_copy_1);
  pgl_wren_bind_method("math.Mat4.mul(_)", Mat4_mul_1);
  pgl_wren_bind_method("math.Mat4.mulVec3(_)", Mat4_mulVec_1);
  pgl_wren_bind_method("math.Mat4.project(_)", Mat4_project_1);
  pgl_wren_bind_method("math.Mat4.unproject(_)", Mat4_unproject_1);
  pgl_wren_bind_method("math.Mat4.perspective(_,_,_)", Mat4_perspective_3);
  pgl_wren_bind_method("math.Mat4.ortho()", Mat4_ortho_0);
  pgl_wren_bind_method("math.Mat4.lookAt(_,_,_)", Mat4_lookAt_3);
  pgl_wren_bind_method("math.Mat4.transpose()", Mat4_transpose_0);
  pgl_wren_bind_method("math.Mat4.invert()", Mat4_invert_0);
  pgl_wren_bind_method("math.Noise.perlin2d(_,_,_,_)",Noise_perlin2d_4);
  pgl_wren_bind_method("math.Noise.seed(_)",Noise_seed_1);

  //graphics
  pgl_wren_bind_class("graphics.Texture", Texture_allocate, Texture_finalize);
  pgl_wren_bind_method("graphics.Texture.image(_)", Texture_image_1);
  pgl_wren_bind_method("graphics.Texture.width()", Texture_width_0);
  pgl_wren_bind_method("graphics.Texture.height()", Texture_height_0);
  pgl_wren_bind_method("graphics.Texture.magFilter(_)", Texture_magFilter_1);
  pgl_wren_bind_method("graphics.Texture.minFilter(_)", Texture_minFilter_1);
  pgl_wren_bind_method("graphics.Texture.wrap(_,_)", Texture_wrap_2);
  pgl_wren_bind_method("graphics.Texture.createMipmaps()", Texture_createMipmaps_0);
  pgl_wren_bind_method("graphics.Texture.copyImage(_,_,_)", Texture_copyImage_3);
  pgl_wren_bind_class("graphics.GraphicsBuffer", GraphicsBuffer_allocate, GraphicsBuffer_finalize);
  pgl_wren_bind_method("graphics.GraphicsBuffer.init(_,_,_,_,_)", GraphicsBuffer_init_5);
  pgl_wren_bind_method("graphics.GraphicsBuffer.subData(_,_,_,_)", GraphicsBuffer_subData_4);
  pgl_wren_bind_class("graphics.InternalAttribute", InternalAttribute_allocate, InternalAttribute_finalize);
  pgl_wren_bind_class("graphics.InternalVertexIndices", InternalVertexIndices_allocate, InternalVertexIndices_finalize);
  pgl_wren_bind_method("graphics.Renderer.getErrors()", Renderer_getErrors_0);
  pgl_wren_bind_method("graphics.Renderer.setViewport(_,_,_,_)", Renderer_setViewport_4);
  pgl_wren_bind_method("graphics.Renderer.enableAttributeInternal(_)", Renderer_enableAttribute_1);
  pgl_wren_bind_method("graphics.Renderer.drawIndicesInternal(_)", Renderer_drawIndices_1);
  pgl_wren_bind_method("graphics.Renderer.drawIndicesInternal(_,_)", Renderer_drawIndices_2);
  pgl_wren_bind_method("graphics.Renderer.setUniformMat4(_,_)", Renderer_setUniformMat4_2);
  pgl_wren_bind_method("graphics.Renderer.setUniformVec3(_,_)", Renderer_setUniformVec3_2);
  pgl_wren_bind_method("graphics.Renderer.setUniformVec2(_,_)", Renderer_setUniformVec2_2);
  pgl_wren_bind_method("graphics.Renderer.setUniformFloat(_,_)", Renderer_setUniformFloat_2);
  pgl_wren_bind_method("graphics.Renderer.setShaderInternal(_)", Renderer_setProgram_1);
  pgl_wren_bind_method("graphics.Renderer.setUniformTexture(_,_,_)", Renderer_setUniformTexture_3);
  pgl_wren_bind_method("graphics.Renderer.setBackgroundColor(_,_,_)", Renderer_setBackgroundColor_3);
  pgl_wren_bind_method("graphics.Renderer.toggleFeature(_,_)", Renderer_toggleFeature_2);
  pgl_wren_bind_method("graphics.Renderer.blendFunc(_,_)", Renderer_blendFunc_2);
  pgl_wren_bind_class("graphics.InternalShader", InternalShader_allocate, InternalShader_finalize);
  pgl_wren_bind_method("graphics.InternalShader.bindAttribute(_,_)", InternalShader_bindAttribute_2);
  pgl_wren_bind_method("graphics.InternalShader.bindUniform(_,_)", InternalShader_bindUniform_2);

  //memory
  pgl_wren_bind_class("memory.Buffer", Buffer_allocate, Buffer_finalize);
  pgl_wren_bind_method("memory.Buffer.init_load(_)", Buffer_init_load_1);
  pgl_wren_bind_method("memory.Buffer.init_allocate(_)", Buffer_init_allocate_1);
  pgl_wren_bind_method("memory.Buffer.init_copy(_,_,_)", Buffer_init_copy_3);
  pgl_wren_bind_method("memory.Buffer.copyFrom(_,_,_,_)", Buffer_copyFrom_4);
  pgl_wren_bind_method("memory.Buffer.getSize()", Buffer_getSize_0);
  pgl_wren_bind_method("memory.Buffer.readByte(_)", Buffer_readByte_1);
  pgl_wren_bind_method("memory.Buffer.readShort(_)", Buffer_readShort_1);
  pgl_wren_bind_method("memory.Buffer.readInt(_)", Buffer_readInt_1);
  pgl_wren_bind_method("memory.Buffer.readUByte(_)", Buffer_readUByte_1);
  pgl_wren_bind_method("memory.Buffer.readUShort(_)", Buffer_readUShort_1);
  pgl_wren_bind_method("memory.Buffer.readUInt(_)", Buffer_readUInt_1);
  pgl_wren_bind_method("memory.Buffer.readFloat(_)", Buffer_readFloat_1);
  pgl_wren_bind_method("memory.Buffer.readDouble(_)", Buffer_readDouble_1);
  pgl_wren_bind_method("memory.Buffer.readByteVec(_,_)", Buffer_readByteVec_2);
  pgl_wren_bind_method("memory.Buffer.readShortVec(_,_)", Buffer_readShortVec_2);
  pgl_wren_bind_method("memory.Buffer.readIntVec(_,_)", Buffer_readIntVec_2);
  pgl_wren_bind_method("memory.Buffer.readUByteVec(_,_)", Buffer_readUByteVec_2);
  pgl_wren_bind_method("memory.Buffer.readUShortVec(_,_)", Buffer_readUShortVec_2);
  pgl_wren_bind_method("memory.Buffer.readUIntVec(_,_)", Buffer_readUIntVec_2);
  pgl_wren_bind_method("memory.Buffer.readFloatVec(_,_)", Buffer_readFloatVec_2);
  pgl_wren_bind_method("memory.Buffer.readDoubleVec(_,_)", Buffer_readDoubleVec_2);  
  pgl_wren_bind_method("memory.Buffer.readString(_,_)", Buffer_readString_2);
  pgl_wren_bind_method("memory.Buffer.writeByte(_,_)", Buffer_writeByte_2);
  pgl_wren_bind_method("memory.Buffer.writeShort(_,_)", Buffer_writeShort_2);
  pgl_wren_bind_method("memory.Buffer.writeInt(_,_)", Buffer_writeInt_2);
  pgl_wren_bind_method("memory.Buffer.writeUByte(_,_)", Buffer_writeUByte_2);
  pgl_wren_bind_method("memory.Buffer.writeUShort(_,_)", Buffer_writeUShort_2);
  pgl_wren_bind_method("memory.Buffer.writeUInt(_,_)", Buffer_writeUInt_2);
  pgl_wren_bind_method("memory.Buffer.writeFloat(_,_)", Buffer_writeFloat_2);
  pgl_wren_bind_method("memory.Buffer.writeDouble(_,_)", Buffer_writeDouble_2);
  pgl_wren_bind_method("memory.Buffer.writeByteVec(_,_)", Buffer_writeByteVec_2);
  pgl_wren_bind_method("memory.Buffer.writeShortVec(_,_)", Buffer_writeShortVec_2);
  pgl_wren_bind_method("memory.Buffer.writeIntVec(_,_)", Buffer_writeIntVec_2);
  pgl_wren_bind_method("memory.Buffer.writeUByteVec(_,_)", Buffer_writeUByteVec_2);
  pgl_wren_bind_method("memory.Buffer.writeUShortVec(_,_)", Buffer_writeUShortVec_2);
  pgl_wren_bind_method("memory.Buffer.writeUIntVec(_,_)", Buffer_writeUIntVec_2);
  pgl_wren_bind_method("memory.Buffer.writeFloatVec(_,_)", Buffer_writeFloatVec_2);
  pgl_wren_bind_method("memory.Buffer.writeDoubleVec(_,_)", Buffer_writeDoubleVec_2);
}