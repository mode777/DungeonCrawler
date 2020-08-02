import "math" for Vec3
import "./game/graphics/quad3d" for QuadBatch, Quad3d

class CubeBatch {
  construct new(texture, size, cubeSize){
    _quads = QuadBatch.new(texture, size*6)
    _size = cubeSize
    _sizeH = cubeSize / 2
    _quadCount = 0
    _quad = Quad3d.new()
    _offset = Vec3.zero()
    _position = Vec3.zero()
    _dirOffsets = [
      [0,-_sizeH,0],
      [0, _sizeH, 0],
      [_sizeH, 0, 0],
      [-_sizeH, 0, 0],
      [0, 0, -_sizeH],
      [0, 0, _sizeH],
    ]
  }

  moveTo(x,y){
    Vec3.set(x * _size + _sizeH, 0, y * _size + _sizeH, _position)
  }

  addQuad(orientation, tile){
    addQuad(orientation, tile, 1)
  }

  addQuad(orientation, tile, offset){
    Vec3.mulV(_dirOffsets[orientation], offset, _offset)
    Vec3.add(_position, _offset, _offset)
    _quad.set(-_sizeH, -_sizeH, _size, _size, orientation).offset(_offset)
    _quads.setTarget(_quadCount, _quad)
    _quads.setSource(_quadCount,tile) 
    _quads.setColor(_quadCount,_color)
    _quadCount = _quadCount + 1
  }

  setColor(c){
    _color = c
  }

  draw(){
    _quads.draw(_quadCount)
  }
}