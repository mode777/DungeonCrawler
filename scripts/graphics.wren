import "image" for Image
import "geometry" for Transform
import "vector" for Vec3

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
  foreign enable()
}

class Attribute {
  construct new(graphicsBuffer, attrType, numComp, dataType, normalized, stride, offset){
    _graphicsBuffer = graphicsBuffer
    _internal = InternalAttribute.new(graphicsBuffer, attrType, numComp, dataType, normalized, stride, offset)
  }

  construct fromAccessor(accessor, attrType, normalized, gBuffer){
    _graphicsBuffer = gBuffer
    _internal = InternalAttribute.new(gBuffer, attrType, accessor.numComponents, accessor.componentType, normalized, accessor.stride, accessor.offset) 
  }

  enable() {
    _internal.enable()
  }
}

foreign class InternalVertexIndices {
  construct new(graphicsBuffer, count, componentType){}
  foreign draw()
}

class VertexIndices {
  construct new(graphicsBuffer, count, componentType){
    _internal = InternalVertexIndices.new(graphicsBuffer, count, componentType)
    _buffer = graphicsBuffer
  }
  draw(){
    _internal.draw()
  }
}

class Renderer {
  //foreign static render(primitive)
  foreign static setTransform(transform)
  foreign static setCameraCoords(eye_x, eye_y, eye_z, target_x, target_y, target_z, up_x, up_y, up_z)
  static setCamera(camera) {
    Renderer.setCameraCoords(camera.eye[0], camera.eye[1], camera.eye[2], camera.target[0], camera.target[1], camera.target[2], camera.up[0], camera.up[1], camera.up[2])
  }
  foreign static getErrors()
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
      var attribute = Attribute.fromAccessor(accessor, key, /*TODO*/false, gBuffer)
      _attributes.add(attribute)
    }  

    var indexAccessor = geometryData.indices
    var indexBuffer = GraphicsBuffer.forIndices(indexAccessor.bufferView)
    
    _index = VertexIndices.new(indexBuffer, indexAccessor.count, indexAccessor.componentType)
  }

  draw(){
    for(a in _attributes){
      a.enable()
    }
    _index.draw()
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

class Mesh {
  construct new(geometryList){
    _geometry = geometryList
  }

  draw(){
    for(geo in _geometry){
      geo.draw()
    }
  }
}

// class Mesh {

//   construct new(geoData, material){
//     _attributes = []
//     loadGeoData(geoData)
//   }

//   loadGeoData(geoData){
//     var gBuffers = {}
//     for(accessor in geoData){
//       var gBuffer = gBuffers[accessor.bufferView]      
//       if(!gBuffer){
//         gBuffer = GraphicsBuffer.forVertices(accessor.bufferView)
//         gBuffers[accessor.bufferView] = gBuffer
//       }
      
//       _attributes[]
//     }
//   }

// }