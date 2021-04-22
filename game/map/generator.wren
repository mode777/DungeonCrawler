import "math" for Mat4, Noise, Vec3, Vec4, Math
import "image" for Image
import "2d" for Tileset, AbstractBatch, SpriteBatch, Quad
import "container" for GlobalContainer
import "graphics" for Colors


import "./game/map/random" for ProdGen
import "./game/map/map" for LevelMap, LevelElement
import "./game/map/entity" for Light, Enemy, Item
import "./game/map/graph" for Node, SplitDir, Connection
import "./game/map/room" for RoomGenerator

class MapGen {

  map { _map }
  image { _img }
  lights { _lights }
  enemies { _enemies }
  items { _items }
  rooms { _rooms }
  startRoom { _startRoom }
  graph { _root }

  construct new(w,h, threshold){
    _w = w
    _h = h
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
    
    generate()
  }

  generate(){
    split(_root)
        
    _rooms = _root.getLeaves()
    _startRoom = _pg.select(_rooms)
    var roomGen = RoomGenerator.new(_pg, _root, _map) 
    for(r in _rooms){
      roomGen.connect(r)
    }
    for(r in _rooms){
      roomGen.generate(r)
    }
    _img = _map.toImage()
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

  // addItems(n){
  //   var amounts = (n.w*n.h / 30).floor
  //   for(i in 0...amounts){
  //     var e = Item.new(
  //       _pg.range(n.x+1,n.x+n.w,0),
  //       _pg.range(n.y+1,n.y+n.h,0), 
  //       _pg.select(_itemList))
  //     _items.add(e)  
  //   }
  // }

  split(n){
    if(n.w * n.h > (_threshold * _threshold * 5)){
      n.split(_pg, _threshold)
      split(n.left)
      split(n.right)
    }
  }

}

