
import "math" for Math, Mat4, Vec3
import "graphics" for Renderer, UniformType

class Camera {
  enable() {
    Renderer.setUniformMat4(UniformType.Projection, getProjection())
    Renderer.setUniformMat4(UniformType.View, getView())
  }
}

class PerspectiveCamera is Camera {
  
  fov { Math.deg(_fov) }
  fov=(v) { 
    _pDirty = true
    _fov = Math.rad(v) 
  }

  near { _near }
  near=(v) { 
    _pDirty = true
    _near = v 
  }

  far { _far }
  far=(v) {
    _pDirty = textures
    _far = v
  }

  construct new(){
    _projection = Mat4.new()
    _fov = Math.rad(45)
    _near = 0.1
    _far = 100
    _pDirty = true
  }
  
  getProjection(){
    if(_pDirty){
      _projection.perspective(_fov, _near, _far)
      _pDirty = false
    }
    return _projection
  }

  zoom(v){
    _fov = _fov + Math.rad(v)
    _pDirty = true
  }
}

class PointAtCamera is PerspectiveCamera {
  construct new(){
    super()
    _position = [0,1,2]
    _target = [0,0,0]
    _up = [0,1,0]
    _viewDirty = true
    _view = Mat4.new()
  }

  getTarget(v3){
    Vec3.copy(_target, v3)
  }

  setTarget(x,y,z){
    Vec3.set(x,y,z,_target)
    _viewDirty = true
  }

  setTarget(v3){
    Vec3.copy(v3,_target)
    _viewDirty = true
  }

  moveTarget(x,y,z){
    Vec3.add(_target, x,y,z,_target)
    _viewDirty = true
  }

  moveTarget(v3){
    Vec3.add(_target, v3 ,_target)
    _viewDirty = true
  }

  getPosition(v3){
    Vec3.copy(_position, v3)
  }

  setPosition(x,y,z){
    Vec3.set(x,y,z,_position)
    _viewDirty = true
  }

  setPosition(v3){
    Vec3.copy(v3,_position)
    _viewDirty = true
  }

  movePosition(x,y,z){
    Vec3.add(_position, x,y,z,_position)
    _viewDirty = true
  }

  movePosition(v3){
    Vec3.add(_position, v3,_position)
    _viewDirty = true
  }

  setUp(x,y,z){
    Vec3.set(x,y,z,_up)
    _viewDirty = true
  }

  setUp(v3){
    Vec3.copy(v3,_up)
    _viewDirty = true
  }

  getView(){
    if(_viewDirty){
      _view.lookAt(_position, _target, _up)
      _viewDirty = false
    }
    return _view
  }
}

class OrbitCamera is PointAtCamera {
  
  phi { Math.deg(_phi) }
  phi=(v) { 
    _phi = Math.rad(v)
    _dirty = true
  }
  theta { Math.deg(_theta) }
  theta=(v) { 
    _theta = Math.rad(v) 
    _dirty = true
  }
  radius { _rad }
  radius=(v) { 
    _rad = v
    _dirty = true 
  }

  construct new(){
    super()
    _dirty = true
    _position = [0,0,0]
    _target = [0,0,0]
    _phi = Math.rad(90)
    _theta = 0
    _rad = 1
  }
  
  getView(){
    if(_dirty){
      super.getTarget(_target)
      _position[0] = _rad * _phi.sin * _theta.cos
      _position[1] = _rad * _phi.cos
      _position[2] = _rad * _phi.sin * _theta.sin
      Vec3.add(_position,_target,_position)
      super.setPosition(_position)
      _dirty = false
    }
    return super.getView()
  }

  phi(v){
    _phi = _phi + Math.rad(v)
    _dirty = true
  }

  theta(v){
    _theta = _theta + Math.rad(v)
    _dirty = true
  }

  radius(v){
    _rad = _rad + v
    _dirty = true
  }

}

class FlyCamera is PointAtCamera {

  yaw { Math.deg(_yaw) }
  pitch { Math.deg(_pitch) }
  yaw=(v) { 
    _yaw = Math.rad(v)
    _dirty = true 
  }
  pitch=(v) { 
    if(v > 89.9) { 
      _pitch = Math.rad(89.9) 
    } else if(v < -89.9) { 
      _pitch = Math.rad(-89.9) 
    } else { 
      _pitch = Math.rad(v) 
    } 
    _dirty = true
  }

  construct new(){
    super()
    _worldUp = [0,1,0]
    _yaw = Math.rad(270)
    _pitch = Math.rad(-45)

    _front = Vec3.zero()
    _right = Vec3.zero()
    _tmp = Vec3.zero()
    _dirty = true
  }

  moveForward(amnt){
    Vec3.mulV(_front, amnt, _tmp)
    super.movePosition(_tmp)
    super.moveTarget(_tmp)
  }

  pitch(p){
    _pitch = _pitch + Math.rad(p)
    _dirty = true
  }

  yaw(y){
    _yaw = _yaw + Math.rad(y)
    _dirty = true
  }

  moveRight(amnt){
    Vec3.mulV(_right, amnt, _tmp)
    super.movePosition(_tmp)
    super.moveTarget(_tmp)
  }

  getView(){
    if(_dirty){
      _front[0] = _yaw.cos * _pitch.cos
      _front[1] = _pitch.sin
      _front[2] = _yaw.sin * _pitch.cos
      
      Vec3.normalize(_front, _front)
      super.getPosition(_tmp)
      Vec3.add(_tmp, _front, _tmp)
      super.setTarget(_tmp)

      Vec3.crossn(_front, _worldUp, _right)    
      Vec3.crossn(_right, _front, _tmp)
      super.setUp(_tmp)
      _dirty = false
    }
    return super.getView()
  }
}