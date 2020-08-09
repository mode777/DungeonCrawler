import "container" for GlobalContainer

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
import "./game/infrastructure" for EventQueue, GameEvent

var queue = GlobalContainer.resolve(EventQueue)

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
var mapState
var playerState
var enemies

var buildGeometry = Fn.new{
  var down = gfxDb.tiles["panela"]
  var up = gfxDb.tiles["floorchecker"]
  var wall = gfxDb.tiles["walla"]
  var door = gfxDb.tiles["doorc"]

  map.forEachXY {|x,y,v|
    if(v.isPassable){
      var n = map.neighbours(x,y)
      var w = wall
      var l = lights[x,y]

      cubes.moveTo(x,y)
      cubes.setColor(l)
      
      cubes.addQuad(QuadOrientation.Up, up)
      cubes.addQuad(QuadOrientation.Down, down)

      for(o in 0...4){
        var orientation = o + 2
        var offset = n[o].isDoor ? 2 : 1
        if(n[o].isSolid) cubes.addQuad(orientation, gfxDb.tiles[n[o].sprite], offset)
      }
    }
  }
}

var calculateLightsMap = Fn.new {
  lights = Lightmap.new(map)
  var lightsList = mapState["lights"]
  for(l in lightsList){
    lights.setLight(l.x,l.y,l.intensity,l.color)
  }
}

var addEnemies = Fn.new{
  enemies = mapState["enemies"]
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
  var itemsList = mapState["items"]
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

queue.subscribe(MapEvents.Load){|ev|
  map = ev.payload["map"]
  mapState = ev.payload
  cubes = CubeBatch.new(gfxDb.texture, map.count, gfxDb.scale)
  billboards = BillboardBatch.new(gfxDb.texture, 4096, gfxDb.scale)
  items = BillboardBatch.new(gfxDb.texture, 4096, gfxDb.scale)
  calculateLightsMap.call()
  buildGeometry.call()
  addEnemies.call()
  addItems.call()
}

queue.subscribe(PlayerEvents.Init){|ev| playerState = ev.payload }

queue.subscribe(SystemEvents.Draw){|ev|
  if(!playerState || !map) return

  updateEnemies.call()
  Vec3.copy(playerState["position"], pos)
  //System.print(pos)
  Vec3.mulV(pos, gfxDb.scale, pos)
  Vec3.copy(playerState["target"], target)
  Vec3.mulV(target, gfxDb.scale, target)
  cam.setPosition(pos)
  cam.setTarget(target)

  var yaw = playerState["yaw"]
  billboards.update(yaw)
  items.update(yaw)

  gfx.enable()
  cam.enable()
  Renderer.setUniformVec3(UniformType.FogColor, [12,50,49])
  cubes.draw()
  billboards.draw()
  items.draw()
}