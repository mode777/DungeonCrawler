import "math" for Mat4, Noise, Vec3, Vec4, Math
import "image" for Image
import "2d" for Tileset, AbstractBatch, SpriteBatch, Quad
import "container" for GlobalContainer
import "graphics" for Colors

import "./game/map/random" for ProdGen
import "./game/map/map" for LevelMap, LevelElement
import "./game/map/entity" for Light, Enemy, Item
import "./game/map/graph" for Node, SplitDir, Connection

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
    var n = _root.leafAt(0,0)
    n.collectNeighbours(_root)
    System.print(n.neighbours)
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

