#include <modules/gltf.h>
#include <modules/image.h>
#include <modules/renderer3d.h>


#pragma GCC diagnostic push 
#pragma GCC diagnostic ignored "-Wunused-variable"
#define CGLTF_IMPLEMENTATION
#include <cgltf/cgltf.h>
#pragma GCC diagnostic pop

static const char * getErrorString(cgltf_result res){
  switch(res){
    case cgltf_result_data_too_short:
      return "Data too short";
    case cgltf_result_file_not_found:
      return "File not found";
    case cgltf_result_invalid_gltf:
      return "Invalid GLTF";
    case cgltf_result_invalid_json:
      return "Invalid JSON";
    case cgltf_result_invalid_options:
      return "Invalid options";
    case cgltf_result_io_error:
      return "IO error";
    case cgltf_result_legacy_gltf:
      return "Legacy GLTF";
    case cgltf_result_out_of_memory:
      return "Out of memory";
    case cgltf_result_unknown_format:
      return "Unknown format";
    case cgltf_result_success:
      return "Success";
  }
  return "Invalid enum";
}

static GLuint loadBuffer(cgltf_buffer_view* view, GLenum target){
  GLuint buffer;

  if(view->tag == NULL){
    glGenBuffers(1, &buffer);
    glBindBuffer(GL_ARRAY_BUFFER, buffer);
    void * ptr = ((char*)view->buffer->data) + view->offset;
    glBufferData(GL_ARRAY_BUFFER, view->size, ptr, GL_STATIC_DRAW);
    view->tag == (void*)buffer;
  }
  else {
    buffer = (GLuint)view->buffer;
  }
  
  return buffer;
}

static GLuint loadTexture(cgltf_texture* texture, const char * file){
  GLuint glTexture;

  if(texture->image->tag == NULL){
    glGenTextures(1, &glTexture);
    int len = strlen(texture->image->uri) * strlen(file);
    char* textureFile = (char*)malloc(len);
    cgltf_combine_paths(textureFile, file, texture->image->uri);        
    
    // TODO: Samplers
    PGLImage* img = pglImageLoad(textureFile, 4);
    free(textureFile);

    glBindTexture(GL_TEXTURE_2D, glTexture);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, img->width, img->height, 0, GL_RGBA, GL_UNSIGNED_BYTE, img->pixels);
    glGenerateMipmap(GL_TEXTURE_2D);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);

    pglImageDestroy(img);
    texture->image->tag = (void*)glTexture;
  }
  else {
    glTexture = (GLuint)texture->image->tag;
  }
    
  return glTexture;
}

static int componentsForType(cgltf_type type){
  switch(type){
    case cgltf_type_scalar: return 1;
    case cgltf_type_vec2: return 2;
    case cgltf_type_vec3: return 3;
    case cgltf_type_vec4: return 4;
    case cgltf_type_mat2: return 4;
    case cgltf_type_mat3: return 9;
    case cgltf_type_mat4: return 16;
    default: return 1;
  }
}

static GLenum getGLType(cgltf_component_type type){
  switch (type) {
    case cgltf_component_type_r_8:
      return GL_BYTE;
    case cgltf_component_type_r_8u:
      return GL_UNSIGNED_BYTE;
    case cgltf_component_type_r_16:
      return GL_SHORT;
    case cgltf_component_type_r_16u:
      return GL_UNSIGNED_SHORT;
    case cgltf_component_type_r_32u:
      return GL_UNSIGNED_INT;
    case cgltf_component_type_r_32f:
      return GL_FLOAT;
    default:
      return GL_FLOAT;
  }
}

static GLenum getPrimitiveType(cgltf_primitive_type type){
  switch(type){
    case cgltf_primitive_type_points: return GL_POINTS;
    case cgltf_primitive_type_lines: return GL_LINES;
    case cgltf_primitive_type_line_loop: return GL_LINE_LOOP;
    case cgltf_primitive_type_line_strip: return GL_LINE_STRIP;
    case cgltf_primitive_type_triangles: return GL_TRIANGLES;
    case cgltf_primitive_type_triangle_strip: return GL_TRIANGLE_STRIP;
    case cgltf_primitive_type_triangle_fan: return GL_TRIANGLE_FAN;
    default: return GL_TRIANGLES;
  }
}

static PGLAttributeInfo* createAttributeInfo(cgltf_accessor* accessor){
  // TODO: Handle interleaved buffers!!!
  PGLAttributeInfo* inst = calloc(1, sizeof(PGLAttributeInfo));

  inst->buffer = loadBuffer(accessor->buffer_view, GL_ARRAY_BUFFER);
  inst->normalized = accessor->normalized;
  inst->numComponents = componentsForType(accessor->type);
  inst->offset = accessor->offset;
  inst->stride = accessor->buffer_view->stride;
  inst->type = getGLType(accessor->component_type);
  
  return inst;
}

static PGLMaterial* createMaterial(cgltf_material* material, const char * file){
  //TODO: A lot, actually!
  PGLMaterial* inst = calloc(1, sizeof(PGLMaterial));

  inst->diffuse = loadTexture(material->pbr_metallic_roughness.base_color_texture.texture, file);

  return inst;
}

static PGLGeometry* createGeometry(cgltf_primitive* primitive, const char * file){
  PGLGeometry* inst = calloc(1, sizeof(PGLGeometry));
  inst->mode = getPrimitiveType(primitive->type);

  inst->indices.buffer = loadBuffer(primitive->indices->buffer_view, GL_ELEMENT_ARRAY_BUFFER);
  inst->indices.type = getGLType(primitive->indices->component_type);
  if(inst->indices.type != GL_UNSIGNED_BYTE && inst->indices.type != GL_UNSIGNED_SHORT){
    //pglLog("[GLTF] WARNING: Geometry has unsupported index type. Must be ushort or ubyte\n");
  }
  inst->indices.count = primitive->indices->count;

  for (size_t i = 0; i < primitive->attributes_count; i++)
  {
    cgltf_attribute attr = primitive->attributes[i];
    
    if(!strcmp(attr.name, "TEXCOORD_0")){
      inst->attributes[PGL_ATTR3D_TEXCOORD0] = createAttributeInfo(attr.data);
    } 
    else if(!strcmp(attr.name, "TEXCOORD_1")){
      inst->attributes[PGL_ATTR3D_TEXCOORD1] = createAttributeInfo(attr.data);
    }
    else if(!strcmp(attr.name, "NORMAL")){
      inst->attributes[PGL_ATTR3D_NORMAL] = createAttributeInfo(attr.data);
    }
    else if(!strcmp(attr.name, "TANGENT")){
      inst->attributes[PGL_ATTR3D_TANGENT] = createAttributeInfo(attr.data);
    }
    else if(!strcmp(attr.name, "POSITION")){
      inst->attributes[PGL_ATTR3D_POSITION] = createAttributeInfo(attr.data);
    }
  } 

  inst->material.diffuse = loadTexture(primitive->material->pbr_metallic_roughness.base_color_texture.texture, file);//createMaterial(primitive->material, file);

  //pglLog(PGL_MODULE_GLTF, PGL_LOG_DEBUG, Loaded geometry (%i vertices)\n, primitive->indices->count);

  return inst;
}

// TODO: Can be reduced to list of geometry??
static PGLMesh* createMesh(cgltf_mesh* mesh, const char * file){
  PGLMesh* inst = calloc(1, sizeof(PGLMesh));
  PGLGeometry* last = NULL;

  for (size_t i = 0; i < mesh->primitives_count; i++)
  {
    PGLGeometry* newGeo = createGeometry(&mesh->primitives[i], file);

    if(last == NULL){
      inst->geometry = newGeo;
    }
    else {
      last->next = newGeo;
    }

    last = newGeo;
  } 

  pglCheckGlError();
  //pglLog(PGL_MODULE_GLTF, PGL_LOG_DEBUG, Loaded mesh: %s\n, mesh->name);
  return inst;
}

static PGLNode* createNodeList(cgltf_node** nodes, int n_nodes, const char * file);

static PGLNode* createNode(cgltf_node* node, const char * file){
  PGLNode* inst = calloc(1, sizeof(PGLNode));
  
  // TODO: Parse transformation
  inst->matrix = NULL;

  if(node->mesh != NULL){
    inst->mesh = createMesh(node->mesh, file);
  }
  else {
    inst->mesh = NULL;
  }

  inst->child = createNodeList(node->children, node->children_count, file);
  
  return inst;
}

static PGLNode* createNodeList(cgltf_node** nodes, int n_nodes, const char * file){
  PGLNode* node = NULL;
  PGLNode* head = NULL;
  for (size_t i = 0; i < n_nodes; i++)
  {
    PGLNode* newNode = createNode(nodes[i], file);
    if(node != NULL){
      node->next = newNode;
    }
    else {
      head = newNode;
    }
    
    node = newNode;
  }

  return head;
}

PGLNode* pglLoadGltf(const char * file){
  cgltf_options options = {0};
  cgltf_data* data = NULL;
  cgltf_result result = cgltf_parse_file(&options, file, &data);

  if (result == cgltf_result_success)
  {
    result = cgltf_load_buffers(&options, data, file);
    if(result == cgltf_result_success){
      //pglLog(PGL_MODULE_GLTF, PGL_LOG_DEBUG, Loaded %s\n, file);

      cgltf_scene scene = data->scenes[0];
      PGLNode* nodes = createNodeList(scene.nodes, scene.nodes_count, file);
      return nodes;
      //printf("%s \n", data->materials[0].pbr_metallic_roughness.base_color_texture.texture->image->uri);
      /* TODO make awesome stuff */
    }
    else {
      //pglLog(PGL_MODULE_GLTF, PGL_LOG_DEBUG, Unable to load buffers in file: %s. Cause: %s.\n, file, getErrorString(result));
    }
    cgltf_free(data);
  }
  else {
    //pglLog(PGL_MODULE_GLTF, PGL_LOG_DEBUG, Unable to load file: %s. Cause: %s.\n, file, getErrorString(result));
  }
}