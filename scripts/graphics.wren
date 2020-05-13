import "image" for Image
import "math" for Vec3, Mat4, Math
import "io" for File
import "geometry" for AttributeType

class Colors {
  static init() {
    __white = [255,255,255,255]
    __grey = [128,128,128,255]
    __darkgrey = [64,64,64,255]
    __red = [255,0,0,255]
    __green = [0,255,0,255]
    __blue = [0,0,255,255]
  }
  static White {__white}
  static Grey {__grey}
  static DarkGrey {__darkgrey}
  static Red {__red}
  static Green {__green}
  static Blue {__blue}
}

class UniformType {
  static Model { 0 }
  static View { 1 }
  static Projection { 2 }
  static Normal { 3 }
  static Texture0 { 5 }
  // reserved
  static Light0 { 12 }
  // reserved
}

foreign class Texture {
  construct fromImage(img){
    image(img)
  }

  construct fromFile(path){
    var img = Image.fromFile(path)
    image(img)
  }

  // private
  foreign image(img)
}

foreign class GraphicsBuffer {
  construct forVertices(view){
    init(view.buffer, view.offset, view.size, false)
  }

  construct forIndices(view){
    init(view.buffer, view.offset, view.size, true)
  }

  //private
  foreign init(buffer, offset, size, areIndices)
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

class Renderer {
  static shader{ __shader }
  foreign static getErrors()
  foreign static setViewport(x,y,w,h)
  foreign static enableAttributeInternal(attr)
  static enableAttribute(attr) { 
    Renderer.enableAttributeInternal(attr.internal) 
  }
  foreign static drawIndicesInternal(indices)
  static drawIndices(indices) { 
    Renderer.drawIndicesInternal(indices.internal) 
  }
  foreign static setUniformMat4(type, mat4)
  foreign static setShaderInternal(shaderInt)
  static setShader(shader) { 
    __shader = shader
    Renderer.setShaderInternal(shader.internal) 
  }
  foreign static setUniformTexture(type, unit, texture)
  foreign static setUniformVec3(type, vec3)

  static checkErrors(){
    var errors = Renderer.getErrors()
    if(errors.count > 0){
      Fiber.abort(errors.join(", "))
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

class Mesh {

  transform { _transform }

  construct new(geometry, material){
    _geometry = geometry
    _material = material
    _transform = Mat4.new()
  }

  draw(){
    Renderer.setUniformMat4(UniformType.Model, _transform)
    _material.use()
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

  static default3d {
    if(!__default3d){
      var mapping = {
        "attributes": {
          "vPosition": AttributeType.Position,
          "vTexcoord": AttributeType.Texcoord0,
          "vNormal": AttributeType.Normal
        },
        "uniforms": {
          "uProjection": UniformType.Projection,
          "uModel": UniformType.Model,
          "uView": UniformType.View,
          "uTexture": UniformType.Texture0,
          "uLight0": UniformType.Light0,
          "uNormal": UniformType.Normal
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

}





