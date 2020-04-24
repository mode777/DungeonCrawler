import "memory" for Buffer, BufferView

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
  
  indices { _indices }
  count { _attributes.count }
  
  construct new(attributes, indices){
    _attributes = attributes
    _indices = indices
  }

  [acc] { _attributes[acc] }

  iterate(val) { _attributes.keys.iterate(val) }
  iteratorValue(val) { _attributes.keys.iteratorValue(val) }
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