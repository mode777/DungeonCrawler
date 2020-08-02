import "math" for Mat4, Noise, Vec3, Vec4
import "component" for Component
import "container" for GlobalContainer
import "graphics" for Renderer, UniformType
import "camera" for PointAtCamera

import "./game/graphics/gfx" for Gfx
import "./game/graphics/lightmap" for Lightmap
import "./game/graphics/quad3d" for Quad3d, EmptyQuad, QuadOrientation, QuadBatch
import "./game/graphics/gfx_db" for GfxDb
import "./game/graphics/billboard" for BillboardBatch
import "./game/graphics/cube" for CubeBatch

GlobalContainer.registerFactory("Gfx3dComponent") {|c| Gfx3dComponent.new(c.resolve("MAP"), c.resolve("PLAYER"))}

class Gfx3dComponent {
  construct new(map, player){
    _mapState = map
    _playerState = player
  }

  start(){
    _pos = Vec3.zero()
    _target = Vec3.zero()

    var map = _mapState["map"]
    _gfx = Gfx.fromFiles()

    _cam = PointAtCamera.new()
    _cam.far = 500

    _gfxDb = GfxDb.new("./assets/fantasy-tileset.png")
    
    var down = _gfxDb.tiles["panel_a"]
    var up = _gfxDb.tiles["floor_checker"]
    var wall = _gfxDb.tiles["wall_a"]
    var door = _gfxDb.tiles["door_c"]
    _cubes = CubeBatch.new(_gfxDb.texture, map.count, _gfxDb.scale)

    calculateLightsMap(map)
    _billboards = BillboardBatch.new(_gfxDb.texture, 4096, _gfxDb.scale)
    _items = BillboardBatch.new(_gfxDb.texture, 4096, _gfxDb.scale)

    map.forEachXY {|x,y,v|
      if(v.isPassable){
        var n = map.neighbours(x,y)
        var w = wall
        var l = _lights[x,y]

        _cubes.moveTo(x,y)
        _cubes.setColor(l)
        
        _cubes.addQuad(QuadOrientation.Up, up)
        _cubes.addQuad(QuadOrientation.Down, down)

        for(o in 0...4){
          var orientation = o + 2
          var offset = n[o].isDoor ? 2 : 1
          if(n[o].isSolid) _cubes.addQuad(orientation, _gfxDb.tiles[n[o].sprite], offset)
        }
      }
    }

    addEnemies(map)
    addItems(map)
  }

  update(){
    updateEnemies()

    Vec3.copy(_playerState["position"], _pos)
    //System.print(_pos)
    Vec3.mulV(_pos, _gfxDb.scale, _pos)
    Vec3.copy(_playerState["target"], _target)
    Vec3.mulV(_target, _gfxDb.scale, _target)
    _cam.setPosition(_pos)
    _cam.setTarget(_target)

    var yaw = _playerState["yaw"]
    _billboards.update(yaw)
    _items.update(yaw)

    _gfx.enable()
    _cam.enable()
    Renderer.setUniformVec3(UniformType.FogColor, [12,50,49])
    _cubes.draw()
    _billboards.draw()
    _items.draw()
  }

  calculateLightsMap(m){
    _lights = Lightmap.new(m)
    var lights = _mapState["lights"]
    for(l in lights){
      _lights.setLight(l.x,l.y,l.intensity,l.color)
    }
  }

  addEnemies(m){
    _enemies = _mapState["enemies"]
    for(e in _enemies){
      e["billboard"] = _gfxDb.billboards[e.type].instance(e.x,e.y)
    }
  }

  updateEnemies(){
    _billboards.clear()
    for(e in _enemies){
      var billboard = e["billboard"]
      billboard.offsetXY(e.x,e.y)
      _billboards.addBillboard(billboard,_lights[(e.x+0.5).floor,(e.y+0.5).floor])
    }
  }

  addItems(m){
    var items = _mapState["items"]
    for(e in items){
      _items.addBillboard(_gfxDb.billboards[e.type].instance(e.x,e.y),_lights[e.x,e.y])
    }
  }
}