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

class Area {

  geometry { _geo }
  items { _items }

  construct new(geometry, items){
    _geo = geometry
    _items = items
  }
}


class AreaBuilder {
  
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

  generateItems(node){
    var list = node["items"]
    var items = BillboardBatch.new(_gfxDb.texture, list.count, _gfxDb.scale)
    var lights = node["lightmap"]

    for(e in list){
      var type = _gfxDb.billboards[e.type]
      var inst = type.instance(e.x,e.y)
      var l = lights[e.x-node.x,e.y-node.y]
      //System.print([inst, l])
      items.addBillboard(inst, l)
    }
    return items
  }

  generateArea(node){
    generateLights(node)
    var items = generateItems(node)
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

    return Area.new(cubes, items)
  }

}


GameSystem.attach("main"){|s|
  var queue = s.queue
  var pos = Vec3.zero()
  var target = Vec3.zero()
  var gfx
  var gfxDb
  var cam
  var currentArea
  var billboards
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

  

  queue.subscribe(SystemEvents.Init){|ev|
    gfx = Gfx.fromFiles()
    cam = PointAtCamera.new()
    cam.far = 500
    gfxDb = GfxDb.instance
  }

  queue.subscribeCombined([MapEvents.Load,PlayerEvents.Init]){|evs|
    mapState = evs[0].payload
    playerState = evs[1].payload
    map = mapState.map
    
    billboards = BillboardBatch.new(gfxDb.texture, 4096, gfxDb.scale)

    var geoGen = AreaBuilder.new(map, gfxDb)

    for(r in mapState.rooms){
      r["area"] = geoGen.generateArea(r)
    }
    currentArea = mapState.startRoom["area"]
    currentRoom = mapState.startRoom

    addEnemies.call()
    //addItems.call()
    updateEnemies.call()

    queue.subscribe(PlayerEvents.Room){|ev|
      currentArea = ev.payload["area"]
      currentRoom = ev.payload
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
      currentArea.items.update(yaw)     
    }

    queue.subscribe(SystemEvents.Draw1){|ev|
      gfx.enable()
      cam.enable()
      Renderer.setUniformVec3(UniformType.FogColor, [12,50,49])
      currentArea.geometry.draw()
      currentArea.items.draw()
      if(currentRoom["projectile-billboards"]){
        currentRoom["projectile-billboards"].draw()
      }
      billboards.draw()
    }

  }
}


