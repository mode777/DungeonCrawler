import "math" for Mat4, Noise, Vec3, Vec4
import "component" for Component
import "graphics" for Renderer, UniformType
import "camera" for PointAtCamera

import "./game/graphics/gfx" for Gfx
import "./game/graphics/lightmap" for Lightmap
import "./game/graphics/quad3d" for Quad3d, EmptyQuad, QuadOrientation, QuadBatch
import "./game/graphics/gfx_db" for GfxDb
import "./game/graphics/billboard" for BillboardBatch
import "./game/graphics/cube" for CubeBatch

import "./game/events" for SystemEvents, MapEvents, PlayerEvents
import "./game/infrastructure" for EventQueue, GameEvent, GameSystem

class GeometryBuilder {
  
  construct new(map, gfxDb){
    _map = map
    _gfxDb = gfxDb
  }

  generateLights(node){
    var lightmap = Lightmap.new(_map.subGrid(node.x, node.y, node.w, node.h))
    node["lightmap"] = lightmap
    var lights = node["lights"]
    for(l in lights){
      lightmap.setLight(l.x-node.x,l.y-node.y,l.intensity,l.color)
    }
  }

  generateArea(node){
    generateLights(node)
    var lightmap = node["lightmap"]

    var cubes = CubeBatch.new(_gfxDb.texture, node.w * node.h, _gfxDb.scale)

    for(y in node.y...node.y+node.h){
      for(x in node.x...node.x+node.w){
        var v = _map[x,y]
        if(v.isPassable){
          var n = _map.neighbours(x,y)
          var l = lightmap[x-node.x,y-node.y]

          cubes.moveTo(x,y)
          cubes.setColor(l)
          
          cubes.addQuad(QuadOrientation.Up, _gfxDb.tiles[v.spriteUp])
          cubes.addQuad(QuadOrientation.Down, _gfxDb.tiles[v.spriteDown])

          for(o in 0...4){
            var orientation = o + 2
            var offset = 1
            if((orientation == QuadOrientation.Right || orientation == QuadOrientation.Front) && n[o].isDoor) offset = 3
            if(n[o].isSolid) cubes.addQuad(orientation, _gfxDb.tiles[n[o].sprite], offset)
          }
        }
      }
    }

    return cubes
  }

}


GameSystem.attach("main"){|s|
  var queue = s.queue
  var pos = Vec3.zero()
  var target = Vec3.zero()
  var gfx
  var gfxDb
  var cam
  var cubes
  var billboards
  var items
  var lights
  var map
  var enemies
  var mapState
  var playerState  
  var rooms
  var currentRoom

  var addEnemies = Fn.new{
    enemies = mapState.enemies
    for(e in enemies){
      e["billboard"] = gfxDb.billboards[e.type].instance(e.x,e.y)
    }
  }

  var updateEnemies = Fn.new{
    billboards.clear()
    for(e in enemies){
      var billboard = e["billboard"]
      billboard.offsetXY(e.x,e.y)
      billboards.addBillboard(billboard,lights[(e.x+0.5).floor,(e.y+0.5).floor])
    }
  }

  var addItems = Fn.new{
    var itemsList = mapState.items
    for(e in itemsList){
      items.addBillboard(gfxDb.billboards[e.type].instance(e.x,e.y),lights[e.x,e.y])
    }
  }

  queue.subscribe(SystemEvents.Init){|ev|
    gfx = Gfx.fromFiles()
    cam = PointAtCamera.new()
    cam.far = 500
    gfxDb = GfxDb.new("./assets/fantasy-tileset.png")
  }

  queue.subscribeCombined([MapEvents.Load,PlayerEvents.Init]){|evs|
    mapState = evs[0].payload
    playerState = evs[1].payload
    map = mapState.map
    
    billboards = BillboardBatch.new(gfxDb.texture, 4096, gfxDb.scale)
    items = BillboardBatch.new(gfxDb.texture, 4096, gfxDb.scale)

    var geoGen = GeometryBuilder.new(map, gfxDb)

    for(r in mapState.rooms){
      r["geometry"] = geoGen.generateArea(r)
    }
    cubes = mapState.startRoom["geometry"]

    addEnemies.call()
    addItems.call()
    updateEnemies.call()

    queue.subscribe(PlayerEvents.Room){|ev|
      cubes = ev.payload["geometry"]
      System.print("Room changed")
    }

    queue.subscribe(SystemEvents.Update){|ev|
      Vec3.copy(playerState["position"], pos)
      //updateEnemies.call()
      //System.print(pos)
      Vec3.mulV(pos, gfxDb.scale, pos)
      Vec3.copy(playerState["target"], target)
      Vec3.mulV(target, gfxDb.scale, target)
      cam.setPosition(pos)
      cam.setTarget(target)

      var yaw = playerState["yaw"]
      billboards.update(yaw)
      items.update(yaw)     
    }

    queue.subscribe(SystemEvents.Draw1){|ev|
      gfx.enable()
      cam.enable()
      Renderer.setUniformVec3(UniformType.FogColor, [12,50,49])
      cubes.draw()
      billboards.draw()
      items.draw()
    }

  }
}


