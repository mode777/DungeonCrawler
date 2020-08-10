import "math" for Vec2, Vec3

class PlayerCollisionComponent {
  construct new(){
  }

  start(playerState){
    _pos = playerState["position"]
    _heading = playerState["heading"]
    _target = playerState["target"]
    _delta = playerState["delta"]
    _forward = playerState["forward"]
    _lastPos = Vec3.zero()
    _pos2d = Vec2.zero()
    _delta2d = Vec2.zero()
    _posFloor = Vec2.zero()
    _a = Vec2.zero()
    _b = Vec2.zero()
    _c = Vec2.zero()
    _d = Vec2.zero()
    _offset = 0.25
    //_posFrac = Vec2.zero()
    _i = 0
    _v2inv = [-1,-1]
    _frac = Vec2.zero()
  }

  update(map){
    Vec2.set(_pos[0], _pos[2], _pos2d)
    //Vec2.set(_delta[0], _delta[2], _delta2d)
    //Vec2.add(_pos2d,_delta2d,_pos2d)

    Vec2.add(_pos2d, -_offset, -_offset, _a)
    Vec2.add(_pos2d, -_offset, _offset, _b)
    Vec2.add(_pos2d, _offset, _offset, _c)
    Vec2.add(_pos2d, _offset, -_offset, _d)

    var a = !map[_a[0].floor,_a[1].floor].isPassable
    var b = !map[_b[0].floor,_b[1].floor].isPassable
    var c = !map[_c[0].floor,_c[1].floor].isPassable
    var d = !map[_d[0].floor,_d[1].floor].isPassable

    // left
    if(a && b){
      _pos[0] = _a[0].ceil + _offset
    }
    // right
    if(c && d) {
      _pos[0] = _c[0].floor - _offset
    }
    // up
    if(a && d){
      _pos[2] = _a[1].ceil + _offset
    }
    // down
    if(b && c){
      _pos[2] = _b[1].floor - _offset
    }

    // corner cases


    // up-left
    if(a && !(b || c || d)){
      Vec2.frac(_a,_frac)
      _frac[0] = 1 - _frac[0]
      _frac[1] = 1 - _frac[1]
      // left      
      if(_frac[0] < _frac[1]){
        _pos[0] = _a[0].ceil + _offset
      // up
      } else {
        _pos[2] = _a[1].ceil + _offset
      }
    }

    // down-left
    if(b && !(a || c || d)){
      Vec2.frac(_b,_frac)
      _frac[0] = 1 - _frac[0]
      // left
      if(_frac[0] < _frac[1]){
        _pos[0] = _a[0].ceil + _offset
      // down
      } else {
        _pos[2] = _b[1].floor - _offset
      }
    }

    // down-right
    if(c && !(a || b || d)){
      Vec2.frac(_c,_frac)
      // right
      if(_frac[0] < _frac[1]){
        _pos[0] = _c[0].floor - _offset
      // down
      } else {
        _pos[2] = _b[1].floor - _offset
      }
    }

    // up-right
    if(d && !(a || b || c)){
      Vec2.frac(_d,_frac)
      _frac[1] = 1 - _frac[1]
      // right
      if(_frac[0] < _frac[1]){
        _pos[0] = _c[0].floor - _offset
      // up
      } else {
        _pos[2] = _a[1].ceil + _offset
      }
    }

    //Vec3.add(_pos, _forward, _target)
    // _delta[0] = _delta2d[0]
    // _delta[2] = _delta2d[1]

  }
}