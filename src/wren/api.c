#include "wrenapi.h"

#include "platform.inc.c"
#include "io.inc.c"
#include "renderer.inc.c"
#include "gl.inc.c"
#include "json.inc.c"
#include "image.inc.c"

void pgl_wren_bind_api(){
  
  // platform
  pgl_wren_bind_method("pgl.Keyboard.isDown(_)", Keyboard_isDown_1);  
  pgl_wren_bind_method("pgl.Window.config(_,_,_)", Window_config_3);
  
  //io
  pgl_wren_bind_class("pgl.File", File_allocate, File_finalize);
  pgl_wren_bind_method("pgl.File.length()", File_length_0);
  pgl_wren_bind_method("pgl.File.close()", File_close_0);
  pgl_wren_bind_method("pgl.File.read(_)", File_read_1);

  //json
  pgl_wren_bind_class("json.JSONParser", JSONParser_allocate, JSONParser_finalize);
  pgl_wren_bind_method("json.JSONParser.getValue()", JSONParser_getValue_0);
  pgl_wren_bind_method("json.JSONParser.getToken()", JSONParser_getToken_0);
  pgl_wren_bind_method("json.JSONParser.nextToken()", JSONParser_nextToken_0);
  pgl_wren_bind_method("json.JSONParser.getChildren()", JSONParser_getChildren_0);
  
  //image
  pgl_wren_bind_class("pgl.Image", Image_allocate, Image_finalize);
  
  //gl
  pgl_wren_bind_class("pgl.Buffer", Buffer_allocate, Buffer_finalize);
  pgl_wren_bind_class("pgl.GeometryBuffer", GeometryBuffer_allocate, GeometryBuffer_finalize);
  pgl_wren_bind_class("pgl.Attribute", Attribute_allocate, Attribute_finalize);
  pgl_wren_bind_class("pgl.Primitive", Primitive_allocate, Primitive_finalize);
  pgl_wren_bind_class("pgl.Texture", Texture_allocate, Texture_finalize);
  pgl_wren_bind_class("pgl.Material", Material_allocate, Material_finalize);

  //renderer
  pgl_wren_bind_class("pgl.Transform", Transform_allocate, Transform_finalize);
  pgl_wren_bind_method("pgl.Transform.translate(_,_,_)", Transform_translate_3);
  pgl_wren_bind_method("pgl.Transform.rotate(_,_,_)", Transform_rotate_3);
  pgl_wren_bind_method("pgl.Transform.scale(_,_,_)", Transform_scale_3);
  pgl_wren_bind_method("pgl.Transform.reset()", Transform_reset_0);
  pgl_wren_bind_method("pgl.Transform.load(_)", Transform_load_1);
  pgl_wren_bind_method("pgl.Transform.apply(_)", Transform_apply_1);
  pgl_wren_bind_method("pgl.Transform.transformVectors(_)", Transform_transformVectors_1);
  pgl_wren_bind_method("pgl.Renderer.render(_)", Renderer_render_1);
  pgl_wren_bind_method("pgl.Renderer.setTransform(_)", Renderer_setTransform_1);
  pgl_wren_bind_method("pgl.Renderer.setCameraCoords(_,_,_,_,_,_,_,_,_)", Renderer_setCamera_9);
}