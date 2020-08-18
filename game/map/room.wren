import "math" for Mat4, Noise, Vec3, Vec4, Math
import "image" for Image
import "2d" for Tileset, AbstractBatch, SpriteBatch, Quad
import "container" for GlobalContainer
import "graphics" for Colors
import "data" for Ringbuffer

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
    //fill(n)
    n["lights"] = []
    populate(n)
    lights(n)
  }

  populate(n){
    
    var targets = []
    var path = []
    var ox = n.x+1
    var oy = n.y+1
    var grid = _map.subGrid(ox,oy,n.w-1, n.h-1)
    var hFirst = _pg.roll(50)

    //add connections to targets
    for(c in n.connections){
      if(c.x == n.x){
        targets.add(grid.id(c.x+1-ox,c.y-oy))
      }
      if(c.y == n.y){
        targets.add(grid.id(c.x-ox,c.y+1-oy))
      }
      if(c.y == n.y+n.h){
        targets.add(grid.id(c.x-ox,c.y-1-oy))
      }
      if(c.x == n.x+n.w){
        targets.add(grid.id(c.x-1-ox,c.y-oy))
      }      
    }

    var first = targets[0]
    for(t in targets.skip(1)){
      var target = [0,0]
      var current = [0,0]
      grid.coords(t, target)
      grid.coords(first, current)
      
      var c1 = current[0] == 0 || current[0] == grid.width-1 ? 0 : 1
      var c2 = c1 == 1 ? 0 : 1
      var dirC1 = target[c1] > current[c1] ? 1 : -1
      var dirC2 = target[c2] > current[c2] ? 1 : -1

      while(current[c1] != target[c1]){
        current[c1] = current[c1] + dirC1
        path.add(grid.id(current))
      }
      while(current[c2] != target[c2]){
        current[c2] = current[c2] + dirC2
        path.add(grid.id(current))
      }
    }


    for(id in path){
      grid[id] = LevelElement.Floor
    }

    //var x = _pg.size(grid.width, grid.width/2).floor
    //var y = _pg.size(grid.height, grid.height/2).floor

    var lights = n["lights"]
    for(id in targets){
      var co = [0,0]
      grid.coords(id,co)

      lights.add(Light.new(co[0]+ox, co[1]+oy, _pg.color(), 1))

      var w = _pg.size(grid.width, grid.width/3).floor
      var h = _pg.size(grid.height, grid.height/3).floor
      grid.fill(co[0]-(w/2).floor,co[1]-(h/2).floor,w,h) {|ox,oy| LevelElement.Floor }
      grid[id] = LevelElement.Floor
    }  	

    _map.putGrid(grid, ox, oy)

  }



  lights(n){
    // var lights = []
    // n["lights"] = lights
    // var c = n.center()
    // lights.add(Light.new(n.x+1, n.y+1, _pg.color(), 1))
    // lights.add(Light.new(n.x+n.w-1, n.y+1, _pg.color(), 1))
    // lights.add(Light.new(n.x+n.w-1, n.y+n.h-1, _pg.color(), 1))
    // lights.add(Light.new(n.x+1, n.y+n.h-1, _pg.color(), 1))
  }

  isFree(x,y, w,h){
    var f = LevelElement.Floor
    for(cy in y...y+h){
      for(cx in x...x+w){
        if(_map[cx,cy] != f) return false
      }
    }
    return true
  }

  hasNeighbour(x,y,e){
    for(n in _map.neighbours(x,y)){
      if(n == e){
        return true
      }
    }
    return false
  }

  hash(x,y){
    return (y << 16) | x
  }

  fill(x,y,w,h, e){
    for(cy in y...y+h){
      for(cx in x...x+w){
        _map[cx,cy] = e
      }
    }
  }

  fill(n){
    var sx = n.x+1//n.x + _pg.size(n.w-1, 2)+1
    var sy = n.y+1//n.y + _pg.size(n.h-1, 2)+1
    for(y in sy...n.y+n.h){
      for(x in sx...n.x+n.w){
        _map[x,y] = LevelElement.Floor
      }
    }

    // for(y in sy...n.y+n.h){
    //   for(x in sx...n.x+n.w){
    //     if(isFree(x-1,y-1,4,4) && _pg.roll(20)){
    //       fill(x,y,2,2, LevelElement.Wall)
    //     }
    //   }
    // }

  }

  connect(n){
    _connLeft = []
    _connUp = []
    n.collectNeighbours(_graph)
    for(nl in n.neighboursLeft){
      var start = Math.max(nl.y+1, n.y+1)
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