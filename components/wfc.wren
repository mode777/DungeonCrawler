import "platform" for Application, Keyboard, Window, Severity, Mouse, Event
import "graphics" for Renderer, Geometry, Mesh, UniformType, Shader, DiffuseMaterial, Colors, Texture, TextureFilters, BufferUsage, GraphicsBuffer, Attribute, VertexIndices
import "geometry" for AttributeType, GeometryData, GeometryWriter
import "math" for Mat4, Vec2, Math, Vec3, Vec4, Noise
import "camera" for PointAtCamera, FlyCamera, OrbitCamera, OrthograficCamera
import "hexaglott" for Hexaglott, HexData
import "memory" for FloatVecAccessor, UShortAccessor, UByteVecAccessor, Buffer, BufferView, DataType, ListUtil, Grid
import "image" for Image
import "helpers" for CameraHelpers
import "2d" for Quad, SpriteBatch, Tileset, Tilemap


class WfcMap{
  construct new(w,h,tiles){
    _grid = Grid.new(w,h)
    _tiles = tiles
  }

  setTile(x,y,tile){
    _grid[x,y] = tile
  }

  getPossible(x,y){
    var ns = _grid.neighbours(x,y)
    return ListUtil.filter(_tiles) {|t|
      return (ns[0] == null ? true : t.connectsTop(ns[0])) && (ns[1] == null ? true : t.connectsRight(ns[1])) && (ns[2] == null ? true : t.connectsBottom(ns[2])) && (ns[3] == null ? true : t.connectsLeft(ns[3])) 
    }
  }
}

class WfcTile {

  ul { _ul }
  u { _u }
  ur { _ur }
  r { _r }
  br { _br }
  b { _b }
  bl { _bl }
  l { _l }

  quad { _quad }
  id { _id }

  construct new(img, quad, id){
    _quad = quad
    _id = id

    _ul = Vec4.zero()
    img.getPixel(quad.a[0],quad.a[1], _ul)

    _u = Vec4.zero()
    img.getPixel(quad.a[0]+1,quad.a[1], _u)
    
    _ur = Vec4.zero()
    img.getPixel(quad.d[0]-1,quad.d[1], _ur)
    
    _r = Vec4.zero()
    img.getPixel(quad.c[0]-1,quad.c[1]-2, _r)

    _br = Vec4.zero()
    img.getPixel(quad.c[0]-1,quad.c[1]-1, _br)
    
    _b = Vec4.zero()
    img.getPixel(quad.c[0]-2,quad.c[1]-1, _b)

    _bl = Vec4.zero()
    img.getPixel(quad.b[0],quad.b[1]-1, _bl)
    
    _l = Vec4.zero()
    img.getPixel(quad.a[0],quad.a[1]+1, _l)
  }

  connectsTop(tile){
    return Vec4.equals(_ul, tile.bl) && Vec4.equals(_u, tile.b) && Vec4.equals(_ur, tile.br)
  }

  connectsBottom(tile){
    return Vec4.equals(_bl, tile.ul) && Vec4.equals(_b, tile.u) && Vec4.equals(_br, tile.ur)
  }

  connectsLeft(tile){
    return Vec4.equals(_ul, tile.ur) && Vec4.equals(_l, tile.r) && Vec4.equals(_bl, tile.br)
  }

  connectsRight(tile){
    return Vec4.equals(_ur, tile.ul) && Vec4.equals(_r, tile.l) && Vec4.equals(_br, tile.bl)
  }
}

class Cursor {

  position { _pos }

  construct new(tilemap, cursorTile){
    _tilemap = tilemap
    _pos = [0,0]
    _cursorTiles = Tilemap.new(tilemap.texture, 1,1,_tilemap.tileWidth,_tilemap.tileHeight)
    _cursorTiles.transform.copy(_tilemap.transform)
    _cursorTiles[0,0] = cursorTile
    setActive(true)
  }  

  setActive(b){
    if(b) _cursorTiles.setColor(0, [255,0,0,200])
    if(!b) _cursorTiles.setColor(0, [255,255,255,200])
  }

  move(x,y){    
    _pos[0] = Math.clamp(0,_tilemap.width-1,_pos[0]+x)
    _pos[1] = Math.clamp(0,_tilemap.height-1,_pos[1]+y)
    _cursorTiles.transform.copy(_tilemap.transform)
    _cursorTiles.transform.translate(3*_pos[0],3*_pos[1],0)
  }

  draw(){
    _cursorTiles.draw()
  }
}

class Wfc {
  construct new(){
    _camera = OrthograficCamera.new()
    _img = Image.fromFile("./assets/tileset.png")
    setupTileset()
    setupTilemap()
    setupCursors()
    setupSpecial()
    _mode = "map"
  }

  setupCursors(){
    Application.on(Event.Keydown){|args|
      if(!args[2]) input(args[1])
    }
    _setCursor = Cursor.new(_tilesetMap, _tileset[6,6]) 
    _mapCursor = Cursor.new(_tilemap, _tileset[6,6])
    _setCursor.setActive(false)
    _cursor = _mapCursor
  }

  setupTileset(){
    _tileset = Tileset.new(_img.width/3, _img.height/3, 3, 3)
    
    _txt = Texture.fromImage(_img, {"mipmaps": false, "magFilter": TextureFilters.Nearest, "minFilter": TextureFilters.Nearest})

    _tilesetMap = Tilemap.new(_txt, 4,8,3,3)
    _tilesetMap.transform.scale(16,16,1)
    _tilesetMap.transform.translate(1280/16-_tilesetMap.pixelWidth,0,0)
  }

  setupSpecial(){
    _wfcMap = WfcMap.new(16,16,[
      WfcTile.new(_img, _tileset[4,6],"1010"), 
      WfcTile.new(_img, _tileset[1,0],"0101"), 
      WfcTile.new(_img, _tileset[2,0],"1001"), 
      WfcTile.new(_img, _tileset[3,0],"1100"), 
      WfcTile.new(_img, _tileset[4,0],"0110"),
      WfcTile.new(_img, _tileset[5,0],"0011"),
      WfcTile.new(_img, _tileset[3,6],"0000")
    ])
    // for(i in 0..._tilemap.count){
    //   _tilemap[i] = Quad.empty
    // }
    updateTileset(_mapCursor.position[0],_mapCursor.position[1])
  }

  updateTileset(x,y){
    _special = _wfcMap.getPossible(x,y)
    for(i in 0..._tilesetMap.count){
      _tilesetMap[i] = i < _special.count ? _special[i].quad : Quad.empty
    }
  }

  setupTilemap(){
    _tilemap = Tilemap.new(_txt, 16,16, 3,3)
    _tilemap.transform.scale(16,16,1)
  }

  switchModes(){
    if(_mode == "map"){
      _mode = "set"
      _setCursor.setActive(true)
      _mapCursor.setActive(false)
      _cursor = _setCursor
    } else {
      _mode = "map"
      _setCursor.setActive(false)
      _mapCursor.setActive(true)
      _cursor = _mapCursor
    }
  }

  draw(){
    _camera.enable()
    //setUniforms()
    _tilesetMap.draw()
    _tilemap.draw()
    _setCursor.draw()
    _mapCursor.draw()
  }

  input(key){
    if(key == "Up") _cursor.move(0,-1) 
    if(key == "Down") _cursor.move(0,1)
    if(key == "Left") _cursor.move(-1,0)
    if(key == "Right") _cursor.move(1,0)
    if(key == "Return") {
      if(_mode == "set"){
        var setPos = _setCursor.position
        var mapPos = _mapCursor.position
        var offset = setPos[1]*_tilesetMap.width+setPos[0]
        if(offset >= _special.count){
          _tilemap[mapPos[0],mapPos[1]] = Quad.empty
          _wfcMap.setTile(mapPos[0],mapPos[1], null)
          Application.dispatchEvent("[wfc]set",[mapPos[0],mapPos[1],null])
        } else {
          Application.dispatchEvent("[wfc]set",[mapPos[0],mapPos[1],_special[offset].id])
          _tilemap[mapPos[0],mapPos[1]] = _special[offset].quad
          _wfcMap.setTile(mapPos[0],mapPos[1], _special[offset])
        }
      }
      switchModes()
    }
    if(_mode == "map"){
      updateTileset(_mapCursor.position[0],_mapCursor.position[1])
    }
    Application.dispatchEvent("[wfc]pos",_mapCursor.position)
  }
}

var wfc

Application.on(Event.Load){|args|
  wfc = Wfc.new()
}

Application.on(Event.Update){|args|
  Renderer.set2d()
  wfc.draw()
}