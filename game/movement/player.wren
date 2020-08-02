import "math" for Mat4, Noise, Vec3, Vec4
import "container" for GlobalContainer
import "memory" for Grid

GlobalContainer.registerInstance("PLAYER", {})
GlobalContainer.registerFactory("PlayerComponent") {|c| PlayerComponent.new(c.resolve("INPUT"),c.resolve("PLAYER"))}

class PlayerComponent {
  construct new(input, player){
    _inputState = input
    _playerState = player

    _pos = Vec3.zero()
    _yaw = 0
    _forward = Vec3.zero()
    _right = Vec3.zero()
    _target = Vec3.zero()
    _delta = Vec3.zero()
    _tmp = Vec3.zero()

    _playerState["position"]= _pos
    _playerState["target"] = _target
    _playerState["heading"] = _forward
    _playerState["delta"] = _delta
    _playerState["forward"] = _forward
    _playerState["yaw"] = _yaw
  }

  start(){
    Vec3.set(2,0,2, _pos)
    updatePlayerPos()
  }

  update(){
    Vec3.zero(_delta)
    Vec3.zero(_tmp)

    if(_inputState["forward"]){
      Vec3.mulV(_forward, 0.05, _tmp)
      Vec3.add(_delta, _tmp, _delta)
    }
    if(_inputState["backward"]){
      Vec3.mulV(_forward, -0.05, _tmp)
      Vec3.add(_delta, _tmp, _delta)
    }
    if(_inputState["strafe_left"]){
      Vec3.mulV(_right, -0.05, _tmp)
      Vec3.add(_delta, _tmp, _delta)
    }
    if(_inputState["strafe_right"]){
      Vec3.mulV(_right, 0.05, _tmp)
      Vec3.add(_delta, _tmp, _delta)
    }
    if(_inputState["turn_left"]){
      _yaw = _yaw - 0.03
    }
    if(_inputState["turn_right"]){
      _yaw = _yaw + 0.03
    }

    updatePlayerPos()
  }

  updatePlayerPos(){
    Vec3.set(_yaw.cos, 0, _yaw.sin, _forward)
    Vec3.set(-_yaw.sin, 0, _yaw.cos, _right)
    Vec3.add(_delta,_pos,_pos)
    _playerState["yaw"] = _yaw
    Vec3.add(_pos, _forward, _target)
  }
}

class LevelMap is Grid {
  construct new(img){
    super(img.width, img.height, false)
    init(img)
  }

  init(img){
    var pixel = Vec4.zero()
    fill {|x,y|
      img.getPixel(x,y,pixel)
      return pixel[0] > 0
    }
  }
}