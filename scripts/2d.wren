import "graphics" for Renderer, Geometry, Mesh, UniformType, Shader, DiffuseMaterial, Colors, Texture, TextureFilters, BufferUsage, GraphicsBuffer, Attribute, VertexIndices
import "memory" for FloatVecAccessor, UShortAccessor, UByteVecAccessor, Buffer, BufferView, DataType, ListUtil
import "geometry" for AttributeType, GeometryData, GeometryWriter
import "math" for Vec2, Mat4

class Quad {

  static empty { EmptyQuad }

  a { _a }
  b { _b }
  c { _c }
  d { _d }
  w { _c[0] - _a[0] }
  h { _c[1] - _a[1] }
  x { _a[0] }
  y { _a[1] }

  construct new(x,y,w,h){
    _a = [x,y]
    _b = [x,y+h]
    _c = [x+w,y+h]
    _d = [x+w,y]
  }
  construct clone(q){
    _a = Vec2.clone(q.a)
    _b = Vec2.clone(q.b)
    _c = Vec2.clone(q.c)
    _d = Vec2.clone(q.d)
  } 

  set(x,y,w,h){
    Vec2.set(x,y,_a)
    Vec2.set(x,y+h,_b)
    Vec2.set(x+w,y+h,_c)
    Vec2.set(x+w,y,_d)
  }

  offset(x,y){
    var os = [x,y]
    Vec2.add(_a,os,_a)
    Vec2.add(_b,os,_b)
    Vec2.add(_c,os,_c)
    Vec2.add(_d,os,_d)
  }

  toString(){
    return [x,y,w,h]
  }
}

var EmptyQuad = Quad.new(0,0,0,0)

class AbstractBatch {
  
  transform { _transform }
  count { _size }
  positions { _positions }
  texcoords { _texcoords }
  texture { _texture }

  construct new(texture, size, positionComponents){
    _transform = Mat4.new()
    _texture = texture
    _size = size
    _positions = FloatVecAccessor.new(4*size,positionComponents)
    _texcoords = FloatVecAccessor.new(4*size,2)
    _indices = UShortAccessor.new(6*size)
    
    _texcoordsGBuffer = GraphicsBuffer.forVertices(_texcoords.bufferView, BufferUsage.Dynamic) 
    _positionsGBuffer = GraphicsBuffer.forVertices(_positions.bufferView, BufferUsage.Dynamic)
    _indicesGBuffer = GraphicsBuffer.forIndices(_indices.bufferView, BufferUsage.Dynamic)
    
    _positionAttribute = Attribute.fromAccessor(_positions, AttributeType.Position, false, _positionsGBuffer) 
    _texcoordsAttribute = Attribute.fromAccessor(_texcoords, AttributeType.Texcoord0, false, _texcoordsGBuffer) 
    _vertexIndices = VertexIndices.new(_indicesGBuffer, _indices.count, DataType.UShort)

    calculateIndices()
  }

  calculateIndices(){
    for(i in 0..._size){
      var vo = 4 * i
      var io = 6 * i
      _indices[io+0] = vo+0
      _indices[io+1] = vo+1
      _indices[io+2] = vo+2

      _indices[io+3] = vo+0
      _indices[io+4] = vo+2
      _indices[io+5] = vo+3
    }
    _dirty = true
  }

  setSource(n,s){
    s = s || Quad.empty
    var vo = 4 * n
    _texcoords[vo+0] = s.a
    _texcoords[vo+1] = s.b
    _texcoords[vo+2] = s.c
    _texcoords[vo+3] = s.d
    _dirty = true
  }

  setTarget(n,t){
    t = t || Quad.empty
    var vo = 4 * n
    _positions[vo+0] = t.a
    _positions[vo+1] = t.b
    _positions[vo+2] = t.c
    _positions[vo+3] = t.d
    _dirty = true
  }

  update(){
    if(_dirty){
      _positionsGBuffer.subDataView(_positions.bufferView)
      _texcoordsGBuffer.subDataView(_texcoords.bufferView)
      _indicesGBuffer.subDataView(_indices.bufferView)
      _dirty = false
    }
  }

  draw(){
    draw(_size)
  }

  setUniforms(){
    Renderer.setUniformTexture(UniformType.Texture0, 0, _texture)
    Renderer.setUniformMat4(UniformType.Model, _transform)
  }

  enableAttributes(){
    Renderer.enableAttribute(_positionAttribute)
    Renderer.enableAttribute(_texcoordsAttribute)
  }

  draw(amnt){
    update()
    setUniforms()
    enableAttributes()
    Renderer.drawIndices(_vertexIndices, amnt*6)
  }

}

class SpriteBatch is AbstractBatch {

  construct new(texture, size){
    super(texture, size, 2)
    _colors = UByteVecAccessor.new(4*size,4)
    _colorsGBuffer = GraphicsBuffer.forVertices(_colors.bufferView, BufferUsage.Dynamic)
    _colorsAttribute = Attribute.fromAccessor(_colors, AttributeType.Color, true, _colorsGBuffer) 
    _dirty = false
  }

  setSprite(n, s, t){
    setTarget(n,t)
    setSource(n,s)
    setColor(n, Colors.White)
  }

  setSprite(n, s, t, c){
    setTarget(n,t)
    setSource(n,s)
    setColor(n, c)
  }

  setColor(n,c){
    c = c || Colors.Transparent
    var vo = 4 * n
    _colors[vo+0] = c
    _colors[vo+1] = c
    _colors[vo+2] = c
    _colors[vo+3] = c
    _dirty = true
  }

  setOpacity(n,o){
    var vo = 4 * n
    var c = _colors[vo+0]
    c[3] = o
    _colors[vo+0] = c
    _colors[vo+1] = c
    _colors[vo+2] = c
    _colors[vo+3] = c
  }
  
  update(){
    super.update()
    if(_dirty){
      _colorsGBuffer.subDataView(_colors.bufferView)
      _dirty = false
    }
  }

  setUniforms(){
    super.setUniforms()
    Renderer.setUniformVec2(UniformType.TextureSize, [texture.width,texture.height])
  }

  enableAttributes(){
    super.enableAttributes()
    Renderer.enableAttribute(_colorsAttribute)
  }

}

class Tileset{
  
  tileWidth { _tw }
  tileHeight { _th }

  construct new(w,h,tw,th){
    _w = w.floor
    _h = h.floor
    System.print([_w,_h])
    _tw = tw.floor
    _th = th.floor
    calculateQuads()
  }

  calculateQuads(){
    _quads = []
    for(y in 0..._h){
      for(x in 0..._w){
        _quads.add(Quad.new(x*_tw,y*_th,_tw, _th))
      }
    }
  }

  [x,y] {
    return _quads[y*_w+x]
  }

  [i] {
    return _quads[i]
  } 
}

class Tilemap is SpriteBatch {

  width {_w}
  height {_h}
  pixelWidth {_w*_tw}
  pixelHeight {_h*_th}
  tileWidth {_tw}
  tileHeight {_th}
  texture {_texture}

  construct new(texture,w,h,tw,th){
    super(texture,w.floor*h.floor)
    _texture = texture
    _w = w.floor
    _h = h.floor
    _tw = tw
    _th = th
    var q = Quad.new(0,0,0,0)
    for(y in 0..._h){
      for(x in 0..._w){
        q.set(x*tw, y*th, tw, th)
        super.setTarget(y*_w+x,q)
      }
    }
  }

  [x,y]=(quad) {
    super.setSource(y*_w+x,quad)
    super.setColor(y*_w+x,Colors.White)
  }

  [i]=(quad) {
    super.setSource(i,quad)
    super.setColor(i,Colors.White)
  }

  fill(fn){
    for(y in 0..._h){
      for(x in 0..._w){
        super.setSource(y*_w+x,fn.call(x,y))
      }
    }
  }
}