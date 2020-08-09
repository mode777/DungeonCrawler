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
    _mapState["areas"] = _gen.areas
    _mapState["graph"] = _gen.graph
  }

  update(){}

}

class MapGen {

  map { _map }
  image { _img }
  lights { _lights }
  enemies { _enemies }
  items { _items }
  areas { _areas }
  rooms { _rooms }
  graph { _root }

  construct new(w,h, threshold){
    _w = w
    _h = h
    _img = Image.new(w,h)
    _root = Node.root(Quad.new(0,0,_w,_h))
    _map = LevelMap.new(_root)
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
    _areas = []
    _rooms = []
    generate()
  }

  generate(){
    split(_root)
    _areas = _root.getLeaves()
    for(a in _areas){
      a.collectNeighbours()
      _rooms.add(a.createRoom())
    }
    connect()
    paint(_root)
  }

  connect(){
    var ls = _areas
    for(l in ls){
      for(n in l.neighbours){
        if(n.x == l.x+l.w){
          var start = Math.max(l.y, n.y) + 1
          var end = Math.min(l.y+l.h, n.y+n.h)
          var size = end-start
          if(size > 0){
            var y = start + _pg.size(size, 1)
            var x = l.x
            var con = Connection.new(l, n, [x,y])
            l.addConnection(con)
            n.addConnection(con)
          }
        }
        if(l.x == n.x+n.w){

        }

      }
    }
  }

  paint(n){
    if(n.isLeaf){    
      
      addLights(n)
      addEnemies(n)
      addItems(n)
      
      //addRoom(n.quad)
      n.room.fillMap(_map)
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

