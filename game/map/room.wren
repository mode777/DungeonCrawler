import "math" for Mat4, Noise, Vec3, Vec4, Math
import "image" for Image
import "2d" for Tileset, AbstractBatch, SpriteBatch, Quad
import "container" for GlobalContainer
import "graphics" for Colors

import "./game/map/random" for ProdGen
import "./game/map/map" for LevelMap, LevelElement
import "./game/map/entity" for Light, Enemy, Item
import "./game/map/graph" for Node, SplitDir, Connection

class RoomGenerator {
  construct new(pg, graph, map){
    _pg = pg
    _graph = graph
    _map = map
  }

  generate(n) {
    connect(n)
    fill(n)
    lights(n)
  }

  lights(n){
    var lights = []
    n["lights"] = lights
    var c = n.center()
    lights.add(Light.new(n.x+1, n.y+1, _pg.color(), 1))
    lights.add(Light.new(n.x+n.w-1, n.y+1, _pg.color(), 1))
    lights.add(Light.new(n.x+n.w-1, n.y+n.h-1, _pg.color(), 1))
    lights.add(Light.new(n.x+1, n.y+n.h-1, _pg.color(), 1))
  }

  isFree(x,y){
    var f = LevelElement.Floor
    return _map[x,y] == f && _map[x-1,y] == f && _map[x-1,y-1] == f && _map[x,y-1] == f && _map[x+1,y-1] == f && _map[x+1,y] == f && _map[x+1,y+1] == f && _map[x,y+1] == f && _map[x-1,y+1] == f
  }

  fill(n){
    var sx = n.x+1//n.x + _pg.size(n.w-1, 2)+1
    var sy = n.y+1//n.y + _pg.size(n.h-1, 2)+1
    for(y in sy...n.y+n.h){
      for(x in sx...n.x+n.w){
        _map[x,y] = LevelElement.Floor
      }
    }
    for(y in sy...n.y+n.h){
      for(x in sx...n.x+n.w){
        if(isFree(x,y) && _pg.roll(20)){
          _map[x,y] = LevelElement.Wall
        }
      }
    }

  }

  connect(n){
    _connLeft = []
    _connUp = []
    n.collectNeighbours(_graph)
    for(nl in n.neighboursLeft){
      var start = Math.max(nl.y, n.y)
      var end = Math.min(nl.y+nl.h, n.y+n.h)
      var coords = [n.x, start + _pg.size(end-start-1,1)+1]
      var conn = Connection.new(n, nl, coords)
      _map[conn.x,conn.y] = LevelElement.Door
      n.addConnection(conn)
      nl.addConnection(conn)
      _connLeft.add(coords)
    }      
    for(nu in n.neighboursUp){
      var start = Math.max(nu.x, n.x)
      var end = Math.min(nu.x+nu.w, n.x+n.w)
      var coords = [start + _pg.size(end-start-1,1)+1, n.y]
      var conn = Connection.new(n, nu, coords)
      _map[conn.x,conn.y] = LevelElement.Door
      n.addConnection(conn)
      nu.addConnection(conn)
      _connUp.add(coords)
    }
  }
}