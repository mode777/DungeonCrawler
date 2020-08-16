import "2d" for Quad
import "./game/map/entity" for Entity

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

class Node is Entity {
  
  isLeaf { !_a && !_b }
  quad { _q }
  left { _a }
  right { _b }
  w { _q.w }
  h { _q.h }
  // x { _q.x }
  // y { _q.y }
  splitDir { _d }
  connections { _connections }
  neighboursLeft { _nLeft }
  neighboursRight { _nRight }
  neighboursUp { _nUp }
  neighboursDown { _nDown }
  neighbours { _nLeft + _nRight + _nUp + _nDown }
  
  construct new(q){
    super(q.x, q.y)
    _q = q
    _connections = []
  }

  split(pg, threshold){
    if(_q.w >= _q.h){
      _a = Node.new(Quad.new(_q.x,_q.y,pg.size(_q.w, threshold), _q.h))
      _b = Node.new(Quad.new(_q.x+_a.w,_q.y,_q.w-_a.w,_q.h))
      _d = SplitDir.H
    } else {
      _a = Node.new(Quad.new(_q.x,_q.y,_q.w, pg.size(_q.h, threshold)))
      _b = Node.new(Quad.new(_q.x,_q.y+_a.h,_q.w,_q.h-_a.h))
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

  collectDown(graph, cx, cy, coll){
    while(cy < (y+h)){
      var n = graph.leafAt(cx, cy)
      if(n == null) break
      cy = n.y + n.h
      coll.add(n)
    }
  }

  collectRight(graph, cx, cy, coll){
    while(cx < (x+w)){
      var n = graph.leafAt(cx, cy)
      if(n == null) break
      cx = n.x + n.w
      coll.add(n)
    }
  }

  collectNeighbours(graph){
    _nLeft = []
    _nRight = []
    _nUp = []
    _nDown = []
    collectDown(graph,x-1,y, _nLeft)
    collectDown(graph,x+w,y, _nRight)
    collectRight(graph,x, y-1, _nUp)
    collectRight(graph,x, y+h, _nDown)
  } 

  isInside(x,y){x >= this.x && x < (this.x + this.w) && y >= this.y && y < (this.y + this.h)}

  center(){
    return [_q.x+(_q.w/2), _q.y+(_q.h/2)]
  }

  getLeaves(){
    if(isLeaf) return [this]
    return _a.getLeaves() + _b.getLeaves()
  }

  toString {
    return "%(isLeaf ? "Leaf" : "Tree") at %(x),%(y) (%(w),%(h))"
  }
}