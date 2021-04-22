import "image" for Image
import "math" for Vec3, Mat4, Math
import "io" for File
import "geometry" for AttributeType
import "memory" for MapUtil

class Color {
  static new(r,g,b,a){
    return [r,g,b,a]
  }

  static new(r,g,b){
    return Color.new(r,g,b,255)
  }
}

class Colors {
 
  static init() {
    __transparent = [0,0,0,0]
    __white = [255,255,255,255]
    __grey = [128,128,128,255]
    __darkgrey = [64,64,64,255]
    __red = [255,0,0,255]
    __green = [0,255,0,255]
    __blue = [0,0,255,255]
    __black = [0,0,0,255]
  }
  static White {__white}
  static Grey {__grey}
  static DarkGrey {__darkgrey}
  static Red {__red}
  static Green {__green}
  static Blue {__blue}
  static Transparent { __transparent }
  static Black { __black }
}

class UniformType {
  static Model { 0 }
  static View { 1 }
  static Projection { 2 }
  static Normal { 3 }
  static Texture0 { 5 }
  static Texture1 { 6 }
  static Texture2 { 7 }
  // reserved
  static Light0 { 12 }
  // reserved
  static Time { 16 }
  static TextureSize { 17 }
  static FogColor { 18 }
}

class TextureFilters {
  static Nearest { 0x2600 }
  static Linear { 0x2601 }
  static NearestMipmapNearest { 0x2700 }
  static LinearMipmapNearest { 0x2701 }
  static NearestMipmapLinear { 0x2702 }
  static LinearMipmapLinear { 0x2703 }
}

class TextureWrap {
  static Repeat { 0x2901 }
  static Clamp { 0x812F }
  static Mirrored { 0x8370 }
}

var DefaultTextureOptions = {
  "mipmaps": true,
  "minFilter": TextureFilters.LinearMipmapLinear,
  "magFilter": TextureFilters.Linear,
  "wrapS": TextureWrap.Repeat,
  "wrapT": TextureWrap.Repeat
}

foreign class Texture {

  width { width() }
  height { height() }

  construct fromImage(img){
    image(img)
    init(DefaultTextureOptions)
  }

  construct fromImage(img, options){
    image(img)
    init(MapUtil.merge(DefaultTextureOptions, options))
  }

  construct fromFile(path){
    var img = Image.fromFile(path)
    image(img)
    init(DefaultTextureOptions)
  }

    construct fromFile(path, options){
    var img = Image.fromFile(path)
    image(img)
    init(MapUtil.merge(DefaultTextureOptions, options))
  }

  init(options){
    magFilter(options["magFilter"])
    minFilter(options["minFilter"])
    wrap(options["wrapS"], options["wrapT"])
    if(options["mipmaps"]){
      createMipmaps()
      minFilter(TextureFilters.LinearMipmapLinear)
    }
  }

  foreign magFilter(filter)
  foreign minFilter(filter)
  foreign wrap(s,t)
  foreign createMipmaps()
  foreign width()
  foreign height()
  foreign copyImage(img, x, y)

  // private
  foreign image(img)
}

class BufferUsage {
  static Static { 0x88E4 }
  static Dynamic { 0x88E8 }
  static Stream { 0x88E0 }
}

foreign class GraphicsBuffer {
  construct forVertices(view){
    init(view.buffer, view.offset, view.size, false, BufferUsage.Static)
  }

  construct forVertices(view, usage){
    init(view.buffer, view.offset, view.size, false, usage)
  }

  construct forIndices(view){
    init(view.buffer, view.offset, view.size, true, BufferUsage.Static)
  }

  construct forIndices(view, usage){
    init(view.buffer, view.offset, view.size, true, usage)
  }

  //private
  foreign init(buffer, offset, size, isIndexBuffer, usage)
  foreign subData(buffer, offset, size, targetOffset)
  subDataView(view){
    subData(view.buffer, view.offset, view.size, 0)
  }

}

foreign class InternalAttribute {
  construct new(graphicsBuffer, attrType, numComp, dataType, normalized, stride, offset){}
}

class Attribute {

  internal { _internal }

  construct new(graphicsBuffer, attrType, numComp, dataType, normalized, stride, offset){
    _graphicsBuffer = graphicsBuffer
    _internal = InternalAttribute.new(graphicsBuffer, attrType, numComp, dataType, normalized, stride, offset)
  }

  construct fromAccessor(accessor, attrType, normalized, gBuffer){
    _graphicsBuffer = gBuffer
    _internal = InternalAttribute.new(gBuffer, attrType, accessor.numComponents, accessor.componentType, normalized, accessor.stride, accessor.offset) 
  }
}

foreign class InternalVertexIndices {
  construct new(graphicsBuffer, count, componentType){}
}

class VertexIndices {

  internal { _internal }

  construct new(graphicsBuffer, count, componentType){
    _internal = InternalVertexIndices.new(graphicsBuffer, count, componentType)
    _buffer = graphicsBuffer
  }
}

//Regex
// Find: #define GL_([A-Z,_,2]+)\s+(.+)
// Replace: static $1 { $2 }

class RendererFeature {
  static Texture2d { 0x0DE1 }
  static CullFace { 0x0B44 }
  static Blend { 0x0BE2 }
  static Dither { 0x0BD0 }
  static StencilTest { 0x0B90 }
  static DepthTest { 0x0B71 }
  static ScissorTest { 0x0C11 }
  static PolygonOffsetFill { 0x8037 }
  static SampleAlphaToCoverage { 0x809E }
  static SampleCoverage { 0x80A0 }
}

class RendererBlendFunc {
  static Zero { 0 }
  static One { 1 }
  static SrcColor { 0x0300 }
  static OneMinusSrcColor { 0x0301 }
  static SrcAlpha { 0x0302 }
  static OneMinusSrcAlpha { 0x0303 }
  static DstAlpha { 0x0304 }
  static OneMinusDstAlpha { 0x0305 }
  static DstColor { 0x0306 }
  static OneMinusDstColor { 0x0307 }
  static SrcAlphaSaturate { 0x0308 }
}

class Renderer {
  static shader{ __shader }
  foreign static getErrors()
  foreign static setViewport(x,y,w,h)
  foreign static setBackgroundColor(r,g,b)
  foreign static enableAttributeInternal(attr)
  static enableAttribute(attr) { 
    if(attr == null) Fiber.abort("Attribute is null")
    Renderer.enableAttributeInternal(attr.internal) 
  }
  foreign static drawIndicesInternal(indices)
  foreign static drawIndicesInternal(indices, count)
  static drawIndices(indices) { 
    if(indices == null) Fiber.abort("Indices are null")
    Renderer.drawIndicesInternal(indices.internal) 
  }
  static drawIndices(indices,count) { 
    if(indices == null) Fiber.abort("Indices are null")
    Renderer.drawIndicesInternal(indices.internal, count) 
  }
  foreign static setUniformMat4(type, mat4)
  foreign static setShaderInternal(shaderInt)
  static setShader(shader) { 
    __shader = shader
    Renderer.setShaderInternal(shader.internal) 
  }
  foreign static setUniformTexture(type, unit, texture)
  foreign static setUniformVec3(type, vec3)
  foreign static setUniformVec2(type, vec2)
  foreign static setUniformFloat(type, f)

  foreign static toggleFeature(feature,bool)
  foreign static blendFunc(src, dst)

  static checkErrors(){
    var errors = Renderer.getErrors()
    if(errors.count > 0){
      Fiber.abort(errors.join(", "))
    }
  }

  static set2d(){
    if(__shader != Shader.default2d){
      Renderer.toggleFeature(RendererFeature.Blend, true)
      Renderer.toggleFeature(RendererFeature.CullFace, false)
      Renderer.toggleFeature(RendererFeature.DepthTest, false)
      Renderer.setShader(Shader.default2d)
      __shader = Shader.default2d
    }
  }

  static set3d(){
    if(__shader != Shader.default3d){
      Renderer.toggleFeature(RendererFeature.Blend, false)
      Renderer.toggleFeature(RendererFeature.CullFace, true)
      Renderer.toggleFeature(RendererFeature.DepthTest, true)
      Renderer.setShader(Shader.default3d)
      __shader = Shader.default3d
    }
  }
}

class Geometry { 
  
  construct new(geometryData){
    var views = []
    var buffers = []
    _attributes = []
    
    var indexOf = Fn.new {|list,item|
      for(i in 0...list.count){
        if(list[i] == item){
          return i
        }
      }
      return -1
    }

    for(key in geometryData){
      var accessor = geometryData[key]
      var gBuffer
      var view = accessor.bufferView
      var index = indexOf.call(views,view) 
      if(index != -1){
        gBuffer = buffers[index] 
      } else {
        gBuffer = GraphicsBuffer.forVertices(view)
        buffers.add(gBuffer)
        views.add(view)
      }
      var attribute = Attribute.fromAccessor(accessor, key, accessor.normalized, gBuffer)
      _attributes.add(attribute)
    }  

    var indexAccessor = geometryData.indices
    var indexBuffer = GraphicsBuffer.forIndices(indexAccessor.bufferView)
    _index = VertexIndices.new(indexBuffer, indexAccessor.count, indexAccessor.componentType)
  }

  draw(){
    for(a in _attributes){
      Renderer.enableAttribute(a)
    }
    Renderer.drawIndices(_index)
  }
}

class Node {

  mesh { _mesh }
  mesh=(v) { _mesh = v }
  transform { _transform }

  construct new(mesh, transform){
    _mesh = mesh
    _transform = transform
  }

  draw(){
    Renderer.setUniformMat4(UniformType.Model, _transform)
    if(_mesh) _mesh.draw()
  }
}

class Mesh {

  geometry { _geometry }

  construct new(geometry, material){
    _geometry = geometry
    _material = material
  }

  draw(){
    if(_material) _material.use()
    _geometry.draw()
  }
}

class DiffuseMaterial {
  construct new(texture){
    _texture = texture
  }

  use(){
    Renderer.setUniformTexture(UniformType.Texture0, 0, _texture)
  }
}

foreign class InternalShader {
  construct new(vertexSrc, fragmentSrc){}
  foreign bindAttribute(type, name)
  foreign bindUniform(type, name)
}

class Shader {

  static default2d {
    if(!__default2d){
      var mapping = {
        "attributes": {
          "vPosition": AttributeType.Position,
          "vTexcoord": AttributeType.Texcoord0,
          "vColor": AttributeType.Color
        },
        "uniforms": {
          "uTexture": UniformType.Texture0,
          "uProjection": UniformType.Projection,
          "uModel": UniformType.Model,
          "uView": UniformType.View,
          "uTextureSize": UniformType.TextureSize
        }
      }
      __default2d = Shader.fromFiles("./shaders/2d.vertex.glsl","./shaders/2d.fragment.glsl", mapping)
    }
    return __default2d
  }

  static default3d {
    if(!__default3d){
      var mapping = {
        "attributes": {
          "vPosition": AttributeType.Position,
          "vColor": AttributeType.Color,
          "vTexcoord": AttributeType.Texcoord0,
          "vNormal": AttributeType.Normal
        },
        "uniforms": {
          "uProjection": UniformType.Projection,
          "uModel": UniformType.Model,
          "uView": UniformType.View,
          "uTexture": UniformType.Texture0,
          "uLight0": UniformType.Light0,
          "uNormal": UniformType.Normal,
          "t": UniformType.Time
        }
      } 
      __default3d = Shader.fromFiles("./shaders/3d.vertex.glsl","./shaders/3d.fragment.glsl", mapping)
    }
    return __default3d
  }

  internal { _internal }

  construct new(vertexSrc, fragmentSrc, mapping){
    _internal = InternalShader.new(vertexSrc, fragmentSrc)
    init(mapping)
  }

  construct fromFiles(vertexPath, fragmentPath, mapping){
    var vsrc = File.open(vertexPath, "rb").readToEnd()
    var fsrc = File.open(fragmentPath, "rb").readToEnd()

    _internal = InternalShader.new(vsrc, fsrc)
    init(mapping)
  }

  init(mapping){

    if(mapping.containsKey("attributes")){
      for(key in mapping["attributes"].keys){
        _internal.bindAttribute(mapping["attributes"][key], key)
      }
    }
    if(mapping.containsKey("uniforms")){
      for(key in mapping["uniforms"].keys){
        _internal.bindUniform(mapping["uniforms"][key], key)
      }
    }
  }

  enable(){
    Renderer.setShader(this)
  }

}





