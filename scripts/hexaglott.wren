import "graphics" for Shader, UniformType, Colors
import "geometry" for AttributeType, GeometryData, GeometryWriter
import "memory" for DataType, Buffer, BufferView, FloatVecAccessor, UByteVecAccessor, UShortAccessor
import "math" for Vec3, Math

class HexData is GeometryData {
  
  positions { _positions }
  colors { _colors }
  
  construct new(count, hexSize){
    var vertexSize = DataType.size(DataType.Float) * 6 + DataType.size(DataType.UByte) * 4
    var hexagonSize = vertexSize * (6+6*4+1)
    var buffer = Buffer.new(hexagonSize * count)
    var view = BufferView.new(buffer)
    var accessors = {
      AttributeType.Position: FloatVecAccessor.fromBufferView(view, 3, vertexSize,0),
      AttributeType.Normal: FloatVecAccessor.fromBufferView(view, 3, vertexSize, DataType.size(DataType.Float) * 3),
      AttributeType.Color: UByteVecAccessor.fromBufferView(view, 4, vertexSize, DataType.size(DataType.Float) * 6)
    }

    var hexagonIndices = 6*3+6*2*3
    var indices = UShortAccessor.new(hexagonIndices*count)

    super(accessors, indices)
    
    _positions = this[AttributeType.Position]
    _colors = this[AttributeType.Color]
    _colors.normalized = true
    _normals = this[AttributeType.Normal]
    
    _w = 2 * hexSize
    _h = 3.sqrt * hexSize
    _size = hexSize
    _position = [0,0,0]
    _normal = [0,0,0]
    _vs = [_position, Colors.White, _normal]
    _writer = GeometryWriter.new([_positions, _colors, _normals], indices)
  }

  flatHexCorner(i){
    var angle = Math.rad(60*i)
    _position[0] = _size * angle.cos
    _position[2] = _size * angle.sin
  }

  sideNormal(i){
    var angle = Math.rad((60*i)+30)
    _normal[0] = angle.cos
    _normal[1] = 0
    _normal[2] = angle.sin
  }

  writeVertex(){
    _writer.vertex(_vs)
  }

  writeTri(a,b,c){
    _writer.tri(a,b,c)
  }

  writeCap(x,z,height){
    // normal
    Vec3.set(0,1,0,_normal)
    // center
    Vec3.set(x,height,z, _position)
    writeVertex()
    // cap
    for(i in 1..6){
      flatHexCorner(6-i)
      Vec3.add(_position, x, 0, z, _position)
      writeVertex()
      writeTri(_o,_o+i,_o+(i%6)+1)
    }
  }

  setColor(color){
    _vs[1] = color
  }

  writeSide(i){
    sideNormal(6-i)
    
    var a = _writer.vertexOffset
    Vec3.copy(positions[_o+i], _position)
    writeVertex()

    var b = _writer.vertexOffset
    _position[1] = 0
    writeVertex()
    
    var c = _writer.vertexOffset
    Vec3.copy(positions[_o+(i%6)+1], _position)
    writeVertex()
    
    var d = _writer.vertexOffset
    _position[1] = 0
    //vs[1] = Colors.DarkGrey
    writeVertex()

    writeTri(a,b,c)
    writeTri(b,d,c) 
  }

  addHexagon(x,z,height, color){
    z = z*_h + (x%2 == 1 ? _h/2 : 0)
    x = x * (0.75*_w)
    var v3 = _vs[0]
    var writer = _writer
    var vs = _vs

    setColor(color)
    _o = _writer.vertexOffset
    writeCap(x,z,height)

    if(height == 0) return
    
    // sides
    for(i in 1..6){
      writeSide(i)
    }
  }
}

class Hexaglott {
  static createShader(){
    var mapping = {
      "attributes": {
        "vPosition": AttributeType.Position,
        "vColor": AttributeType.Color,
        "vNormal": AttributeType.Normal
      },
      "uniforms": {
        "uProjection": UniformType.Projection,
        "uModel": UniformType.Model,
        "uView": UniformType.View,
        "uLight": UniformType.Light0
      }
    }
    
    return Shader.fromFiles("./shaders/hexaglott.vertex.glsl","./shaders/hexaglott.fragment.glsl", mapping)
  }
  static createMaterial(){
    return HexaglottMaterial.new()
  }
}

class HexaglottMaterial {
  construct new(){}
  use(){}
}

