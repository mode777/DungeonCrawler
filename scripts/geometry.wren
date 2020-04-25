import "memory" for Buffer, BufferView, DataType, Accessor, ListUtil

class AttributeType {
  static Unknown { 0 }
  static Position { 1 }
  static Color { 2 }
  static Normal { 3 }
  static Tangent { 4 }
  static Texcoord0 { 5 }
  static Texcoord1 { 6 }
}

class GeometryData {
  
  static merge(seq){

    // Attributes
    var vBufferSize = seq.reduce(0) {|a,gd| a + gd.combinedVertexSize()}
    var vBuffer = Buffer.new(vBufferSize)
    var vView = BufferView.new(vBuffer)
    // TODO: Check that all GDs have matching attributes
    var refItem = seq.take(1).toList[0]
    var acc

    var newAccessors = {}
    var stride = refItem.vertexSize()
    var offset = 0

    for(attrType in refItem){
      acc = refItem[attrType]
      if(acc.numComponents == 1){
        var ctor = Accessor.constructorForType(acc.componentType)
        newAccessors[attrType] = ctor.fromBufferView(vView, stride, offset)
      } else {
        var ctor = Accessor.constructorForVecType(acc.componentType)
        newAccessors[attrType] = ctor.fromBufferView(vView, acc.numComponents, stride, offset)
      }
      offset = offset + (acc.numComponents * DataType.size(acc.componentType))

      var accessorOffset = 0
      for(gd in seq){
        var oldAcc = gd[attrType]
        var newAcc = newAccessors[attrType]

        for(i in 0...oldAcc.count){
          newAcc[accessorOffset+i] = oldAcc[i]
        }

        accessorOffset = accessorOffset + oldAcc.count
      }
    }
    
    // Indices
    var iBufferSize = seq.reduce(0) {|a,gd| a + gd.indexSize() }
    var iBuffer = Buffer.new(iBufferSize)
    var iView = BufferView.new(iBuffer)

    var indexOffset = 0
    var vertexOffset = 0
    var indices = Accessor.constructorForType(refItem.indices.componentType).fromBufferView(iView, 0, 0)
    for(gd in seq){
      for(i in 0...gd.indices.count){
        indices[indexOffset + i] = gd.indices[i] + vertexOffset
      }
      indexOffset = indexOffset + gd.indices.count
      vertexOffset = vertexOffset + acc.count
    }

    return GeometryData.new(newAccessors, indices)
  }

  indices { _indices }
  count { _attributes.count }
  
  construct new(attributes, indices){
    _attributes = attributes
    _indices = indices
  }

  construct clone(geoData){
    var visited = []
    var generated = []
    var newAttr = {}

    for(key in geoData){
      var oldAcc = geoData[key]
      var idx = ListUtil.indexOf(visited, oldAcc.bufferView)
      var view
      if(idx == -1){
        var buffer = Buffer.fromBufferView(oldAcc.bufferView)
        view = BufferView.new(buffer)
        generated.add(view)
        visited.add(oldAcc.bufferView)
      } else {
        view = generated[idx]
      }

      if(oldAcc.numComponents == 1){
        newAttr[key] = Accessor.constructorForType(oldAcc.componentType).fromBufferView(view, oldAcc.stride, oldAcc.offset)
      } else {
        newAttr[key] = Accessor.constructorForVecType(oldAcc.componentType).fromBufferView(view, oldAcc.numComponents, oldAcc.stride, oldAcc.offset)
      }
    }

    var iBuffer = Buffer.fromBufferView(geoData.indices.bufferView)
    var iView = BufferView.new(iBuffer)
    var indices = Accessor.constructorForType(geoData.indices.componentType).fromBufferView(iView, 0, 0)
    
    _attributes = newAttr
    _indices = indices
  }

  [acc] { _attributes[acc] }

  iterate(val) { _attributes.keys.iterate(val) }
  iteratorValue(val) { _attributes.keys.iteratorValue(val) }

  combinedVertexSize(){
    return _attributes.values.reduce(0) {|a,acc| a + acc.numComponents * DataType.size(acc.componentType) * acc.count}
  }

  vertexSize(){
    return _attributes.values.reduce(0) {|a,acc| a + acc.numComponents * DataType.size(acc.componentType) }
  }

  indexSize(){
    return _indices.count * DataType.size(_indices.componentType)
  }

  transform(attrKey, t){
    var a = _attributes[attrKey]
    if(a.numComponents != 3){
      Fiber.abort("Transform can only be applied to vec3")
    }
    var v3
    for(i in 0...a.count){
      v3 = a[i]
      t.transformVectors(v3)
      a[i] = v3
    }
  }
}

foreign class Transform {
  construct new(){}
  construct copy(transform){
    load(transform)
  }
  foreign translate(x, y, z)
  foreign rotate(x, y, z)
  foreign scale(x, y, z)
  foreign reset()
  foreign load(transform)
  foreign apply(transform)
  foreign transformVectors(vecs)
}