import "json" for JSON

class Game {  
  static onUpdate(callback){
    __update = callback
  }

  static onInit(callback){
    __init = callback
  }

  static onLoad(callback){
    __load = callback
  }

  static update(delta) { 
    if(__update != null){
      __update.call(delta)
    }    
  }

  static init(){
    if(__init != null){
      __init.call()
    }
  }

  static load(){
    if(__load != null){
      __load.call()
    }
  }
}

class Configuration {
  construct load(filename){
    var file = File.new(filename, "rb")
    var content = file.read(file.length())
    _json = JSON.parse(content)
  }
}

class Window {
  foreign static config(w,h,title)
}

class Camera {
  foreign static orbit(rad, g)
  foreign static setTransform(t)
}

class Renderer {
  foreign static render(primitive)
  foreign static setTransform(transform)
}

class Keyboard {
  foreign static isDown(key)
}

foreign class File { 
  construct new(path, mode) {}
  foreign length()
  foreign read(bytes) 
  foreign close() 
}

foreign class Transform {
  construct new(){}
  foreign translate(x, y, z)
  foreign rotate(x, y, z)
  foreign scale(x, y, z)
  foreign reset()
}

foreign class Image {
  construct new(path, channels){}
}

class Scene {
  construct new(name, nodes){
    _name = name
    _nodes = nodes
  }

  name { _name }
  nodes { _nodes }
}

class Node {
  construct new(name, mesh, transformation, children){
    _name = name
    _mesh = mesh
    _transformation = transformation
    _children = children
  }

  name { _name }
  mesh { _mesh }
  transformation { _transformation }
  children { _children }
}

class Mesh {
  construct new(name, primitives){
    _name = name
    _primitives = primitives
  }

  name { _name }
  primitives { _primitives }

  render(){
    for (prim in _primitives) {
      Renderer.render(prim)
    }
  }
}

foreign class Buffer {
  construct new(path){}
}

foreign class GeometryBuffer {
  construct new (buffer, offset, size, stride, areIndices){}
}

class AttributeType {
  Unknown { 0 }
  Position { 1 }
  Color { 2 }
  Normal { 3 }
  Tangent { 4 }
  Texcoord0 { 5 }
  Texcoord1 { 6 }
}

foreign class Attribute {
  construct new(geometryBuffer, attributeType, componentType, componentCount, offset, normalized, count){
    // keep reference for garbage collector
    //_geometryBuffer = geometryBuffer
  }
}

foreign class Primitive {
  construct new(indexAttribute, attributeList, material){}
}

foreign class Texture {
  construct new(image){}
}

foreign class Material {
  construct new(diffuseTexture){}
}

// foreign class Geometry {
//   construct new(mode){}
//   foreign indices(buffer, count, type)
//   foreign 
// }