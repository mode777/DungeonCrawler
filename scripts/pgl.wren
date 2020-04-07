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

class Renderer {
  foreign static render(primitive)
  foreign static setTransform(transform)
  foreign static setCameraCoords(eye_x, eye_y, eye_z, target_x, target_y, target_z, up_x, up_y, up_z)
  static setCamera(camera) {
    Renderer.setCameraCoords(camera.eye[0], camera.eye[1], camera.eye[2], camera.target[0], camera.target[1], camera.target[2], camera.up[0], camera.up[1], camera.up[2])
  }
}

class Vec3 {
  static zero(dst){
    dst[0] = 0
    dst[1] = 0
    dst[2] = 0
  }

  static one(dst){
    dst[0] = 1
    dst[1] = 1
    dst[2] = 1
  }

  static create(x,y,z){
    return [x,y,z]
  }

  static set(x,y,z,dst){
    dst[0] = x
    dst[1] = y
    dst[2] = z
  }

  static copy(src,dst){
    dst[0] = src[0]
    dst[1] = src[1]
    dst[2] = src[2]
  }

  static add(v1,v2,dst){
    dst[0] = v1[0] + v2[0]
    dst[1] = v1[1] + v2[1]
    dst[2] = v1[2] + v2[2]
  }

  static add(v1,x,y,z,dst){
    dst[0] = v1[0] + x
    dst[1] = v1[1] + y
    dst[2] = v1[2] + z
  }

  static sub(v1, v2, dst){
    dst[0] = v1[0] + v2[0]
    dst[1] = v1[1] + v2[1]
    dst[2] = v1[2] + v2[2]
  }

  static extract(all, offset, dst){
    dst[0] = all[offset + 0]
    dst[1] = all[offset + 1]
    dst[2] = all[offset + 2]
  }

  static insert(src, offset, all){
    all[offset+0] = src[0]
    all[offset+1] = src[1]
    all[offset+2] = src[2]
  }
}

class Camera {

  eye { 
    update()
    return _eye 
  }
  
  target { 
    update()
    return _target 
  }
  
  up { 
    update()
    return _up 
  }

  construct new(){
    _eye = [0,0,0]
    _target = [1,0,0]
    _up = [0,1,0]
    _rotate = [0,0,0]
    _movement = [0,0,0]
    _dirty = false
    _transform = Transform.new()
    _combined = _eye + _target
    _position = [0,0,0]
    _tmp = [0,0,0]
  }

  update(){
    if(_dirty){
      _combined[0] = 0
      _combined[1] = 0
      _combined[2] = 0

      _combined[3] = 1
      _combined[4] = 0
      _combined[5] = 0

      _transform.reset()
      _transform.rotate(0,_rotate[1], 0)
      _transform.rotate(0, 0, _rotate[2])
      _transform.rotate(_rotate[0], 0, 0)
      
      Vec3.set(0,1,0, _up)
      _transform.transformVectors(_up)
      
      _transform.translate(_movement[0], _movement[1], _movement[2])

      _transform.transformVectors(_combined)

      Vec3.extract(_combined, 0, _eye)
      Vec3.extract(_combined, 3, _target)

      Vec3.add(_position, _eye, _eye)
      Vec3.add(_position, _target, _target)
      
      Vec3.copy(_eye,_position)

      Vec3.zero(_movement)

      _dirty = false
    }
  }

  rotate(x,y,z){
    Vec3.add(_rotate, x, y, z, _rotate)
    _dirty = true
  }

  move(x, y, z){
    Vec3.add(_movement, x, y, z, _movement)
    _dirty = true
  }
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
  construct copy(transform){
    load(transform)
  }
  foreign translate(x, y, z)
  foreign rotate(x, y, z)
  foreign scale(x, y, z)
  foreign reset()
  foreign load(transform)
  foreign apply(transform)
  foreign transformVectors(vecs)
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