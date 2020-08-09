import "2d" for Quad
import "./game/map/map" for Room

class SplitDir {
  static H { 0 }
  static V { 1 }
}

class Connection {

  x { _pos[0] }
  y { _pos[1] }
  a { _r1 }
  b { _r2 }

  construct new(r1, r2, pos){
    _r1 = r1
    _r2 = r2
    _pos = pos
  }
}

class Node {
  
  isLeaf { !_a && !_b }
  quad { _q }
  left { _a }
  right { _b }
  w { _q.w }
  h { _q.h }
  x { _q.x }
  y { _q.y }
  splitDir { _d }
  connections { _connections }
  neighbours { _neighbours }
  room { _room }
  
  construct root(q){
    _q = q
    _root = this
  }

  construct new(q, root){
    _q = q
    _root = root
    _connections = []
  }

  split(pg, threshold){
    if(_q.w >= _q.h){
      _a = Node.new(Quad.new(_q.x,_q.y,pg.size(_q.w, threshold), _q.h), _root)
      _b = Node.new(Quad.new(_q.x+_a.w,_q.y,_q.w-_a.w,_q.h), _root)
      _d = SplitDir.H
    } else {
      _a = Node.new(Quad.new(_q.x,_q.y,_q.w, pg.size(_q.h, threshold)), _root)
      _b = Node.new(Quad.new(_q.x,_q.y+_a.h,_q.w,_q.h-_a.h), _root)
      _d = SplitDir.V
    }
  }

  addConnection(c){
    _connections.add(c)
  }

  leafAt(x,y){
    if(!isInside(x,y)) {
      return null
    }
    if(isLeaf) return this

    if(_d == SplitDir.H){
      if(x < (_b.x)) {
        return _a.leafAt(x,y)
      } else {
        return _b.leafAt(x,y)
      }
    } else {
      if(y < (_b.y)) {
        return _a.leafAt(x,y)
      } else {
        return _b.leafAt(x,y)
      } 
    }
  }

  collectDown(cx, cy){
    while(cy < (y+h)){
      var n = _root.leafAt(cx, cy)
      System.print([cx,cy])
      if(n == null) break
      cy = n.y + n.h
      _neighbours.add(n)
    }
  }

  collectRight(cx, cy){
    while(cx < (x+w)){
      var n = _root.leafAt(cx, cy)
      if(n == null) break
      cx = n.x + n.w
      _neighbours.add(n)
    }
  }

  collectNeighbours(){
    _neighbours = []
    collectDown(x-1,y)
    collectDown(x+w,y)
    collectRight(x, y-1)
    collectRight(x, y+h)
  } 

  isInside(x,y){x >= this.x && x < (this.x + this.w) && y >= this.y && y < (this.y + this.h)}

  center(){
    return [_q.x+(_q.w/2).floor, _q.y+(_q.h/2).floor]
  }

  getLeaves(){
    if(isLeaf) return [this]
    return _a.getLeaves() + _b.getLeaves()
  }

  toString {
    return "%(isLeaf ? "Leaf" : "Tree") at %(x),%(y) (%(w),%(h))"
  }

  createRoom(){
    _room = Room.new(this)
    return _room
  }
}