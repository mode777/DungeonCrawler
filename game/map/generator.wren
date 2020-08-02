import "math" for Mat4, Noise, Vec3, Vec4, Math
import "image" for Image
import "2d" for Tileset, AbstractBatch, SpriteBatch, Quad
import "random" for Random
import "container" for GlobalContainer
import "graphics" for Colors
import "memory" for Grid

GlobalContainer.registerInstance("MAP", {"map": null, "lights": []})
GlobalContainer.registerFactory("GeneratorComponent"){|c| GeneratorComponent.new(c.resolve("MAP")) }

class GeneratorComponent {
  construct new(map){
    _mapState = map
  }

  start(){
    _gen = MapGen.new(32,32, 5)
    _mapState["lights"] = _gen.lights
    _mapState["enemies"] = _gen.enemies
    _mapState["items"] = _gen.items
    _mapState["map"] = _gen.map
    _mapState["img"] = _gen.image
  }

  update(){}

}

class ProdGen {
  construct new(seed){
    _random = Random.new(seed)
  }

  construct new(){
    _random = Random.new()
  }

  size(s, threshold){ _random.int(s-threshold*2) + threshold }
  range(a,b,threshold){ a + size(b-a, threshold) }
  color(){ [_random.int(255),_random.int(255),_random.int(255),255] }
  float(s,e){ _random.float(s,e) }
  select(list){ list[_random.int(list.count)] }
}

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

  center(){
    return [_q.x+(_q.w/2).floor, _q.y+(_q.h/2).floor]
  }

  getLeaves(){
    if(isLeaf) return [this]
    return _a.getLeaves + _b.getLeaves
  }
}

class MapGen {

  map { _map }
  image { _img }
  lights { _lights }
  enemies { _enemies }
  items { _items }

  construct new(w,h, threshold){
    _w = w
    _h = h
    _img = Image.new(w,h)
    _map = LevelMap.new(w,h)
    _root = Node.new(Quad.new(0,0,_w,_h))
    _threshold = threshold
    _pg = ProdGen.new()
    _lights = []
    _enemies = []
    _items = []
    _enemyList = [
      "goblin",
      "zombie",
      "skeleton",
      "ork",
      "cyclop",
      "cheetaman",
      "golem",
      "demon",
      "blobs",
      "blob",
      "scorpion",
      "octopus",
      "vampire",
      "mummy",
      "ghost",
      "beholder",
    ]
    _itemList = [
      "chest"
    ]
    generate()
  }

  generate(){
    split(_root)
    connect(_root)
    paint(_root)
  }

  connect(n){
    if(n.isLeaf) return

    if(n.left.isLeaf && n.right.isLeaf) {
      connectAdjacent(n)
      return
    }    

    var left =  n.findLeavesLeft()
    var right = n.findLeavesRight()
    
    for(rl in left){
      for(rr in right){
        if(n.splitDir == SplitDir.H){
          var start = Math.max(rl.y, rr.y) + 1
          var end = Math.min(rl.y+rl.h, rr.y+rr.h)
          var size = end-start
          if(size > 0){
            var y = start + _pg.size(size, 1)
            var x = rr.x
            var con = Connection.new(rl, rr, [x,y])
            rl.addConnection(con)
            rr.addConnection(con)
          }
        } else {
          var start = Math.max(rl.x, rr.x) + 1
          var end = Math.min(rl.x+rl.w, rr.x+rr.w)
          var size = end-start
          if(size > 0){
            var x = start + _pg.size(size, 1)
            var y = rr.y
            var con = Connection.new(rl, rr, [x,y])
            rl.addConnection(con)
            rr.addConnection(con)
          }
        }
      }
    }

    connect(n.left)
    connect(n.right)
  }

  connectAdjacent(n){
    var pos
    if(n.splitDir == SplitDir.H){
      pos = [n.right.x, n.right.y+_pg.size(n.right.h, 2)]
    } else {
      pos = [n.right.x+_pg.size(n.right.w, 2), n.right.y]        
    }
    var con = Connection.new(n.left, n.right, pos)
    n.left.addConnection(con)
    n.right.addConnection(con)
  }

  paint(n){
    if(n.isLeaf){    
      
      addLights(n)
      addEnemies(n)
      addItems(n)
      
      addRoom(n.quad)
      for(c in n.connections){
        addDoor(c.x, c.y)
      }
    } else {
      paint(n.left)
      paint(n.right)
    }
  }

  addLights(n){
    var amounts = (n.w*n.h / 10).floor
    for(i in 0...amounts){
      var l = Light.new(_pg.range(n.x+1,n.x+n.w,0),_pg.range(n.y+1,n.y+n.h,0), _pg.color(), _pg.float(0.1,1))
      _lights.add(l)  
    }
  }

  addEnemies(n){
    var amounts = (n.w*n.h / 15).floor
    for(i in 0...amounts){
      var e = Enemy.new(
        _pg.range(n.x+1,n.x+n.w,0),
        _pg.range(n.y+1,n.y+n.h,0), 
        _pg.select(_enemyList))
      _enemies.add(e)  
    }
  }

  addItems(n){
    var amounts = (n.w*n.h / 30).floor
    for(i in 0...amounts){
      var e = Item.new(
        _pg.range(n.x+1,n.x+n.w,0),
        _pg.range(n.y+1,n.y+n.h,0), 
        _pg.select(_itemList))
      _items.add(e)  
    }
  }

  split(n){
    if(n.w * n.h > (_threshold * _threshold * 2)){
      n.split(_pg, _threshold)
      split(n.left)
      split(n.right)
    }
  }

  addDoor(x,y){
    _img.setPixel(x, y, Colors.Red)
    _map[x,y] = LevelElement.Door
  }

  addRoom(q){
    var c = Colors.White
    for(y in q.y+1...q.y+q.h){
      for(x in q.x+1...q.x+q.w){
        _img.setPixel(x,y,c)
        _map[x,y] = LevelElement.Floor
      }
    }
  }  
}

var Wall_
var Floor_
var Door_

class LevelElement {

  static Wall { Wall_ }
  static Floor { Floor_ }
  static Door { Door_ }

  sprite { _sprite }
  isSolid { _flags & SOLID > 0 }
  isPassable { _flags & PASSABLE > 0 }
  isDoor { _flags & DOOR > 0 }
  flags { _flags }
  offset { _offset }
  
  construct new(flags, sprite){
    _flags = flags
    _sprite = sprite
    _offset = 0
  }

  construct new(flags, sprite, offset){
    _flags = flags
    _sprite = sprite
    _offset = offset
  }
}

var NONE = 0
var SOLID = 1 << 0
var PASSABLE = 1 << 1
var DOOR = 1 << 2

Wall_ = LevelElement.new(SOLID, "wall_a")
Floor_ = LevelElement.new(PASSABLE, "floor_checker")
Door_ = LevelElement.new(SOLID | PASSABLE | DOOR, "door_a", 0.1)

class LevelMap is Grid {
  construct new(w,h){
    super(w, h, LevelElement.Wall, LevelElement.Wall)
  }

}

class Entity {

  x { _x }
  y { _y }

  construct new(x,y){
    _x = x
    _y = y
    _tags = {}
  }

  [key] {
    return _tags[key]
  }

  [key]=(v) {
    _tags[key] = v
  }

  move(x,y){
    _x = _x + x
    _y = _y + y
  }

  pos(x,y){
    _x = x
    _y = y
  }
}

class Light is Entity {

  color { _color }
  intensity { _intensity }

  construct new(x,y,color,intensity){
    super(x,y)
    _color = color
    _intensity = intensity
  }
}

class Enemy is Entity {

  type { _type }

  construct new(x,y,type){
    super(x,y)
    _type = type
  }
}

class Item is Entity {

  type { _type }

  construct new(x,y,type){
    super(x,y)
    _type = type
  }
}