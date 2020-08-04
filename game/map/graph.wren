import "2d" for Quad

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
  
  construct new(q){
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

  findLeavesLeft(){
    if(_d == SplitDir.H){
      return findLeavesLeft(_b.x, _d)
    } else {
      return findLeavesLeft(_b.y, _d)
    }    
  }

  findLeavesLeft(coord, dir){
    if(isLeaf){
      if(dir == SplitDir.H && _q.x+_q.w == coord){
        return [this]
      } else if(dir == SplitDir.V && _q.y+_q.h == coord) {
        return [this]
      } else {
        return []
      }
    } else {
      return _a.findLeavesLeft(coord,dir) + _b.findLeavesLeft(coord,dir)
    }
  }

  findLeavesRight(){
    if(_d == SplitDir.H){
      return findLeavesRight(_b.x, _d)
    } else {
      return findLeavesRight(_b.y, _d)
    }
  }

  findLeavesRight(coord, dir){
    if(isLeaf){
      if(dir == SplitDir.H && _q.x == coord){
        return [this]
      } else if(dir == SplitDir.V && _q.y == coord) {
        return [this]
      } else {
        return []
      }
    } else {
      return _a.findLeavesRight(coord,dir) + _b.findLeavesRight(coord,dir)
    }
  }

  leafAt(x,y){
    if(!isInside(x,y)) return null
    if(isLeaf) return this

    if(_d == SplitDir.H){
      if(x < (this.x + this.w)) {
        return _a.leafAt(x,y)
      } else {
        return _b.leafAt(x,y)
      }
    } else {
      if(y < (this.y + this.h)) {
        return _a.leafAt(x,y)
      } else {
        return _b.leafAt(x,y)
      } 
    }
  }

  collectDown(graph, cx, cy){
    while(cy < (y+h)){
      var n = graph.leafAt(cx, cy)
      System.print([cx,cy])
      if(n == null) break
      cy = n.y + n.h
      _neighbours.add(n)
    }
  }

  collectRight(graph, cx, cy){
    while(cx < (x+w)){
      var n = graph.leafAt(cx, cy)
      if(n == null) break
      cx = n.x + n.w
      _neighbours.add(n)
    }
  }

  collectNeighbours(graph){
    _neighbours = []
    System.print([x,y,w,h])
    collectDown(graph,x-1,y)
    collectDown(graph,x+w,y)
    collectRight(graph,x, y-1)
    collectRight(graph,x, y+h)
  } 

  isInside(x,y){x >= this.x && x < (this.x + this.w) && y >= this.y && y < (this.y + this.h)}

  center(){
    return [_q.x+(_q.w/2).floor, _q.y+(_q.h/2).floor]
  }

  getLeaves(){
    if(isLeaf) return [this]
    return _a.getLeaves() + _b.getLeaves()
  }
}