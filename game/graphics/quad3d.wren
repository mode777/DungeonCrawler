import "math" for Vec3, Vec2, Vec4
import "2d" for AbstractBatch
import "memory" for UByteVecAccessor, FloatVecAccessor
import "geometry" for AttributeType
import "graphics" for GraphicsBuffer, BufferUsage, Attribute, Renderer, UniformType

class QuadOrientation {
  static Up { 0 }
  static Down { 1 }
  static Left { 2 }
  static Right { 3 }
  static Front { 4 }
  static Back { 5 }
}

class Quad3d {

  Empty { EmptyQuad }

  a { _a }
  b { _b }
  c { _c }
  d { _d }

  construct new(x,y,w,h,o){
    init()
    set(x,y,w,h,o)
  }

  construct clone(q){
    init()
    copy(q)
  }

  copy(q){
    Vec3.copy(q.a,_a)
    Vec3.copy(q.b,_b)
    Vec3.copy(q.c,_c)
    Vec3.copy(q.d,_d)
  }

  transform(m){
    m.mulVec3(_a)
    m.mulVec3(_b)
    m.mulVec3(_c)
    m.mulVec3(_d)
  }

  print(){
    System.print([_a,_b,_c,_d])
  }

  construct new(){
    init()
  }

  init(){
    _a = Vec3.zero()
    _b = Vec3.zero()
    _c = Vec3.zero()
    _d = Vec3.zero()
  }

  set(x,y,w,h,o){
    if(o == QuadOrientation.Up){
      Vec3.set(x,0,y,_a)
      Vec3.set(x,0,y+h,_b)
      Vec3.set(x+w,0,y+h,_c)
      Vec3.set(x+w,0,y,_d)
    }
    if(o == QuadOrientation.Down){
      Vec3.set(x+w,0,y,_a)
      Vec3.set(x+w,0,y+h,_b)
      Vec3.set(x,0,y+h,_c)
      Vec3.set(x,0,y,_d)
    }
    if(o == QuadOrientation.Left){
      Vec3.set(0,x+w,y,_a)
      Vec3.set(0,x,y,_b)
      Vec3.set(0,x,y+h,_c)
      Vec3.set(0,x+w,y+h,_d)
    }
    if(o == QuadOrientation.Right){
      Vec3.set(0,x+w,y+h,_a)
      Vec3.set(0,x,y+h,_b)
      Vec3.set(0,x,y,_c)
      Vec3.set(0,x+w,y,_d)
    }
    if(o == QuadOrientation.Front){
      Vec3.set(x,y+h,0,_a)
      Vec3.set(x,y,0,_b)
      Vec3.set(x+w,y,0,_c)
      Vec3.set(x+w,y+h,0,_d)
    }
    if(o == QuadOrientation.Back){
      Vec3.set(x+w,y+h,0,_a)
      Vec3.set(x+w,y,0,_b)
      Vec3.set(x,y,0,_c)
      Vec3.set(x,y+h,0,_d)
    }
    return this
  }

  offset(v3){
    Vec3.add(_a, v3, _a)
    Vec3.add(_b, v3, _b)
    Vec3.add(_c, v3, _c)
    Vec3.add(_d, v3, _d)
    return this
  }
}

var EmptyQuad = Quad3d.new(0,0,0,0,0)

class QuadBatch is AbstractBatch {

  construct new(texture, size){
    super(texture, size, 3)
    _colors = UByteVecAccessor.new(4*size, 4)
    _colorsGBuffer = GraphicsBuffer.forVertices(_colors.bufferView, BufferUsage.Dynamic)
    _colorsAttribute = Attribute.fromAccessor(_colors, AttributeType.Color, true, _colorsGBuffer)
    
    _offsets = FloatVecAccessor.new(4*size, 3)
    _offsetsGBuffer = GraphicsBuffer.forVertices(_offsets.bufferView, BufferUsage.Dynamic)
    _offsetsAttribute = Attribute.fromAccessor(_offsets, AttributeType.Offset, false, _offsetsGBuffer)

    _dirty = true
    _color = [0,0,0,0]
  }

  setUniforms(){
    super.setUniforms()
    Renderer.setUniformVec2(UniformType.TextureSize, [texture.width,texture.height])
  }

  enableAttributes(){
    super.enableAttributes()
    Renderer.enableAttribute(_colorsAttribute)
    Renderer.enableAttribute(_offsetsAttribute)
  }

  setColor(n,c){
    var vo = 4 * n
    _colors[vo+0] = c
    _colors[vo+1] = c
    _colors[vo+2] = c
    _colors[vo+3] = c
    _dirty = true
  }

  setIntensity(n,v){
    Vec4.set(255*v,255*v,255*v,255,_color)
    setColor(n,_color)
  }

  setOffset(n,v){
    var vo = 4 * n
    _offsets[vo+0] = v
    _offsets[vo+1] = v
    _offsets[vo+2] = v
    _offsets[vo+3] = v
    _dirty = true
  }

  update(){
    super.update()
    if(_dirty){
      _colorsGBuffer.subDataView(_colors.bufferView)
      _offsetsGBuffer.subDataView(_offsets.bufferView)
      _dirty = false
    }
  }
}