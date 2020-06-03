class GeoTransform {
  construct new(mesh){
    _gd = mesh.geometryData
    _image = mesh.material.diffuse.source
    _pixelCoord = [0,0]
    _pixel = [0,0,0,0]
    _colors = UByteVecAccessor.new(_gd.positions.count,4)
    _colors.normalized = true
  }

  createGd(){
    for(i in 0..._gd.texcoords.count){
      var uv = _gd.texcoords[i]
      denormalizeUV(uv)
      _image.getPixel(_pixelCoord[0],_pixelCoord[1],_pixel)
      _colors[i] = _pixel
    }

    _gdNew = GeometryData.new({
      AttributeType.Position: _gd.positions,
      AttributeType.Color: _colors
    }, _gd.indices)
  }

  getMesh(transform){
    createGd()
    shadeFlat()
    return Mesh.new(Geometry.new(_gdNew), null, transform)
  }

  shadeFlat(){
    var indices = _gd.indices
    var pixel = [0,0,0,0]
    var black = [0,0,0,255]
    for(i in 0...(indices.count/3)){
      Vec4.zero(pixel)
      var div = 0
      var vi = i*3
      var ai = indices[vi]
      var bi = indices[vi+1]
      var ci = indices[vi+2]
      if(!Vec4.equals(_colors[ai], black)){        
        Vec4.add(pixel,_colors[ai], pixel)
        div = div + 1
      }
      if(!Vec4.equals(_colors[bi], black)){        
        Vec4.add(pixel,_colors[bi], pixel)
        div = div + 1
      }
      if(!Vec4.equals(_colors[ci], black)){        
        Vec4.add(pixel,_colors[ci], pixel)
        div = div + 1
      }
      if(div > 0){
        Vec4.divV(pixel, div, pixel)
        _colors[ai] = pixel
        _colors[bi] = pixel
        _colors[ci] = pixel
      }
    }
  }

  denormalizeUV(uv) {
    _pixelCoord[0] = (_image.width*uv[0]).floor
    _pixelCoord[1] = (uv[1]*_image.height).floor
  }
}