import "./game/graphics/quad3d" for QuadBatch, Quad3d, QuadOrientation
import "math" for Vec2

class BillboardProto {
  construct new(scale, source, zoffset, size){
    _scale = scale
    _source = source
    _zoffset = zoffset
    _size = size
  }

  instance(x,y){
    return Billboard.new(_scale, x,y, _source, _zoffset, _size)
  }
}

var BillboardId = 0

class Billboard{

  source { _source }
  quad { _quad }
  offset { _offset }
  id { _id }

  construct new(scale,x,y,source){
    init(scale,x,y,source,0,1)
  }

  construct new(scale,x,y,source,z){
    init(scale,x,y,source,z, 1)
  }

  construct new(scale,x,y,source,z,size){
    init(scale,x,y,source,z,size)
  }

  init(scale,x,y,source,z,size){
    _scale = scale
    _id = BillboardId
    BillboardId = BillboardId + 1
    _source = source
    _offset = [
      (x+0.5)*scale,
      z, 
      (y+0.5)*scale]
    _quad = Quad3d.new(-((scale*size)/2),-((scale*size)/2),scale*size,scale*size,QuadOrientation.Left)
  }

  offsetXY(x,y){
    _offset[0] = (x+0.5)*_scale
    _offset[2] = (y+0.5)*_scale
  }
}

class BillboardBatch {

  transform { _quads.transform }
  count { _quadCount }

  construct new(texture, size, billboardSize){
    _quads = QuadBatch.new(texture, size)
    _size = size
    _quadCount = 0
  }

  addBillboard(billboard, color){
    _quads.setSource(_quadCount,billboard.source)
    _quads.setColor(_quadCount,color) 
    _quads.setTarget(_quadCount, billboard.quad)
    _quads.setOffset(_quadCount, billboard.offset)
    _quadCount = _quadCount + 1
  }

  clear(){
    _quadCount = 0
  }

  update(yaw){
    _quads.transform.identity()
    _quads.transform.rotateY(-yaw)
  }

  draw(){
    _quads.draw(_quadCount)
  }
} 