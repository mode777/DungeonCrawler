
class MapUtil {
  static merge(from, to){
    for(k in from.keys){
      if(!to.containsKey(k)){
        to[k] = from[k]
      }
    }
    return to
  }
}

class ListUtil {
  static indexOf(list, item) {
    for(i in 0...list.count){
      if(list[i] == item){
        return i
      }
    }
    return -1
  }

  static selectMany(list,fn){
    return list.reduce([]) {|p,c|
      var l =fn.call(c).toList
      p = p + l
      return p 
    }
  }

  static first(list, fn){
    for(e in list){
      if(fn.call(e)) return e
    }
  }

  static filter(list, fn){
    var l = []
    for(e in list){
      if(fn.call(e)){
        l.add(e)
      }
    }
    return l
  }

  static mapUnique(list, fn){
    var visited = []
    var generated = []
    var out = []
    
    for(el in visited){
      var index = ListUtil.indexOf(visited,el)
      if(index == -1){
        var newItem = fn.call(el)
        generated.add(newItem)
        visited.add(el)
        out.add(newItem)
      } else {
        out.add(generated[index])
      }
    }

    return out
  }
}

class Grid {

  width { _w }
  height { _h }
  count { _data.count }

  construct new(w,h, def, seed){
    init(w,h,def,seed)
  }

  construct new(w,h, def){
    init(w,h,def,null)
  }

  construct new(w,h){
    init(w,h,null, null)
  }

  init(w,h,default,seed){
    _w = w
    _h = h
    _default = default
    _seed = seed
    _neighbours = List.filled(4, null)
    clear()
  }

  clear(){
    _data = List.filled(_w*_h, _seed)
  }

  [i] {
    return _data[i]
  }

  [i]=(v) {
    _data[i] = v
  }

  [x,y] {
    if(isOutOfBounds(x,y)) return _default
    return _data[y*_w+x]
  }

  [x,y]=(v) {
    if(isOutOfBounds(x,y)) return
    _data[y*_w+x] = v
  }

  isOutOfBounds(x,y){
    return y < 0 || y >= _h || x < 0 || x >= _w
  }

  neighbours(x,y){
    //if((x<0||x>=_w)||(y<0||y>=_h)) Fiber.abort("Argument out of range")
    //up
    _neighbours[0] = this[x+1,y] 
    _neighbours[1] = this[x-1,y]
    _neighbours[2] = this[x,y-1] 
    _neighbours[3] = this[x,y+1] 
    return _neighbours 
  }

  iterate(val) { _data.iterate(val)  }
  iteratorValue(val) { _data.iteratorValue(val) }

  fill(fn) {
    for(y in 0..._h){
      for(x in 0..._w){
        this[x,y] = fn.call(x,y)
      }
    }
  }

  forEachXY(fn){
    for(y in 0..._h){
      for(x in 0..._w){
        fn.call(x,y,this[x,y])
      }
    }
  }

  subGrid(x,y,w,h){
    var grid = Grid.new(w,h,_default,_seed)
    this.forEachXY {|ox,oy,v|
      grid[ox+x,oy+y] = v
    }
    return grid
  }
}

class BufferView {

  buffer { _buffer }
  offset { _offset }
  size { _size }

  construct fromBufferView(view, offset, size){
    _buffer = view.buffer
    offset = offset + view.offset
    if(_buffer.size < offset+size){
      Fiber.abort("View outside buffer bounds")
    }
    _offset = offset
    _size = size
  }

  construct new(buffer, offset, size){
    _buffer = buffer
    if(_buffer.size < offset+size){
      Fiber.abort("View outside buffer bounds")
    }
    _offset = offset
    _size = size
  }
  construct new(buffer){
    _buffer = buffer
    _offset = 0
    _size = buffer.size
  }
}

class Float32Array is BufferView {

  length { _length }
  count { _length }
  
  [i] { buffer.readFloat(offset+i*4) }
  [i]=(val) { buffer.writeFloat(offset+i*4, val) }

  construct new(length){
    var buffer = Buffer.new(length*4)
    super(buffer)
    _length = length
  }
  construct new(buffer, offset, size){
    if(size%4 != 0){
      Fiber.abort("Size must be aligned")
    }
    super(buffer, offset, size)
    _length = size/4
  }

  iterate(val) { val == null ? 0 : ( val >= _length-1 ? false : val+1)  }
  iteratorValue(val) { buffer.readFloat(offset+val*4) }
}

foreign class Buffer {
  construct new(size){
    init_allocate(size)
  }
  construct fromBuffer(buffer){
    init_copy(buffer, 0, buffer.size)
  }
  construct fromBufferView(view){
    init_copy(view.buffer, view.offset, view.size)
  }

  construct fromFile(path){
    init_load(path)
  }

  size { getSize() }

  foreign init_load(path)
  foreign init_allocate(size)
  foreign init_copy(buffer, offset, size)

  foreign getSize()

  foreign copyFrom(buffer, srcOffset, srcSize, dstOffset)
  foreign readString(offset, size)
  foreign readByte(offset)
  foreign readShort(offset)
  foreign readInt(offset)
  foreign readUByte(offset)
  foreign readUShort(offset)
  foreign readUInt(offset)
  foreign readFloat(offset)
  foreign readDouble(offset)
  foreign readByteVec(offset, v)
  foreign readShortVec(offset, v)
  foreign readIntVec(offset, v)
  foreign readUByteVec(offset, v)
  foreign readUShortVec(offset, v)
  foreign readUIntVec(offset, v)
  foreign readFloatVec(offset, v)
  foreign readDoubleVec(offset, v)

  foreign writeByte(offset, v)
  foreign writeShort(offset, v)
  foreign writeInt(offset, v)
  foreign writeUByte(offset, v)
  foreign writeUShort(offset, v)
  foreign writeUInt(offset, v)
  foreign writeFloat(offset, v)
  foreign writeDouble(offset, v)
  foreign writeByteVec(offset, v)
  foreign writeShortVec(offset, v)
  foreign writeIntVec(offset, v)
  foreign writeUByteVec(offset, v)
  foreign writeUShortVec(offset, v)
  foreign writeUIntVec(offset, v)
  foreign writeFloatVec(offset, v)
  foreign writeDoubleVec(offset, v)
}

class DataType {
  
  static Byte { 0x1400 }
  static UByte { 0x1401 }
  static Short { 0x1402 }
  static UShort { 0x1403 }
  static Int { 0x1404 }
  static UInt { 0x1405 }
  static Float { 0x1406 }
  static Double { 0x14FF }

  static size(type){
    if(type == DataType.Byte || type == DataType.UByte) return 1
    if(type == DataType.Short || type == DataType.UShort) return 2
    if(type == DataType.Int || type == DataType.UInt || type == DataType.Float) return 4
    if(type == DataType.Double) return 8
  }
}

class Accessor {

  static constructorForVecType(type){
    if(type == DataType.Byte) return ByteVecAccessor
    if(type == DataType.UByte) return UByteVecAccessor
    if(type == DataType.Short) return ShortVecAccessor
    if(type == DataType.UShort) return UShortVecAccessor
    if(type == DataType.Int) return IntVecAccessor
    if(type == DataType.UInt) return UIntVecAccessor
    if(type == DataType.Float) return FloatVecAccessor
  }

  static constructorForType(type){
    if(type == DataType.Byte) return ByteAccessor
    if(type == DataType.UByte) return UByteAccessor
    if(type == DataType.Short) return ShortAccessor
    if(type == DataType.UShort) return UShortAccessor
    if(type == DataType.Int) return IntAccessor
    if(type == DataType.UInt) return UIntAccessor
    if(type == DataType.Float) return FloatAccessor
  }


  bufferView { _bufferView }
  count { _count }
  componentType { _componentType }
  numComponents { _numComponents }
  stride { _stride }
  offset { _offset }
  normalized { _normalized }
  normalized=(v) { _normalized = v }
  

  construct fromBufferView(bufferView, numComponents, stride, offset, dataType) {
    init(bufferView, dataType, numComponents, stride, offset)
  }

  construct new(count, numComponents, dataType){
    var b = Buffer.new(DataType.size(dataType)*numComponents*count)
    var v = BufferView.new(b)
    init(v, dataType, numComponents, 0, 0)
  }

  init(bufferView, componentType, numComponents, stride, offset){
    _normalized = false
    _bufferView = bufferView
    _componentType = componentType
    _numComponents = numComponents
    _stride = stride == 0 ? numComponents * DataType.size(componentType) : stride
    if(bufferView.size % _stride != 0){
      Fiber.abort("BufferView size is not aligned with stride")
    }
    _count = bufferView.size / _stride
    _offset = offset
    _value = []
    for(i in 0..._numComponents){
      _value.add(0)
    }
  }

  [i] { getVal(_bufferView.buffer, elementOffset(i), _value) }
  [i]=(v) { setVal(_bufferView.buffer, elementOffset(i), v) }

  iterate(val) { val == null ? 0 : ( val >= _count-1 ? false : val+1)  }
  iteratorValue(val) { getVal(_bufferView.buffer, elementOffset(val), _value) }

  elementOffset(i){
    return _bufferView.offset + (_stride * i) + _offset
  }
}

class ByteAccessor is Accessor {
  construct new(count){ super(count, 1, DataType.Byte) }
  construct fromBufferView(bufferView, stride, offset) { super(bufferView, 1, stride, offset, DataType.Byte) }
  getVal(b,o,v) { 
    return b.readByte(o) 
  }
  setVal(b,o,v) { b.writeByte(o,v) }
}

class UByteAccessor is Accessor {
  construct new(count){ super(count, 1, DataType.UByte) }
  construct fromBufferView(bufferView, stride, offset) { super(bufferView, 1, stride, offset, DataType.UByte) }
  getVal(b,o,v) { 
    return b.readUByte(o) 
  }
  setVal(b,o,v) { b.writeUByte(o,v) }
}

class ShortAccessor is Accessor {
  construct new(count){ super(count, 1, DataType.Short) }
  construct fromBufferView(bufferView, stride, offset) { super(bufferView, 1, stride, offset, DataType.Short) }
  getVal(b,o,v) { 
    return b.readShort(o) 
  }
  setVal(b,o,v) { b.writeShort(o,v) }
}

class UShortAccessor is Accessor {
  construct new(count){ super(count, 1, DataType.UShort) }
  construct fromBufferView(bufferView, stride, offset) { super(bufferView, 1, stride, offset, DataType.UShort) }
  getVal(b,o,v) { 
    return b.readUShort(o) 
  }
  setVal(b,o,v) { b.writeUShort(o,v) }
}

class IntAccessor is Accessor {
  construct new(count){ super(count, 1, DataType.Int) }
  construct fromBufferView(bufferView, stride, offset) { super(bufferView, 1, stride, offset, DataType.Int) }
  getVal(b,o,v) { 
    return b.readInt(o) 
  }
  setVal(b,o,v) { b.writeInt(o,v) }
}

class UIntAccessor is Accessor {
  construct new(count){ super(count, 1, DataType.UInt) }
  construct fromBufferView(bufferView, stride, offset) { super(bufferView, 1, stride, offset, DataType.UInt) }
  getVal(b,o,v) { 
    return b.readUInt(o) 
  }
  setVal(b,o,v) { b.writeUInt(o,v) }
}

class FloatAccessor is Accessor {
  construct new(count){ super(count, 1, DataType.Float) }
  construct fromBufferView(bufferView, stride, offset) { super(bufferView, 1, stride, offset, DataType.Float) }
  getVal(b,o,v) { 
    return b.readFloat(o) 
  }
  setVal(b,o,v) { b.writeFloat(o,v) }
}

class ByteVecAccessor is Accessor {
  construct new(count, numComponents){ super(count, numComponents, DataType.Byte) }
  construct fromBufferView(bufferView, numComponents, stride, offset) { super(bufferView, numComponents, stride, offset, DataType.Byte) }
  getVal(b,o,v) { 
    b.readByteVec(o,v)
    return v 
  }
  setVal(b,o,v) { b.writeByteVec(o,v) }
}

class UByteVecAccessor is Accessor {
  construct new(count, numComponents){ super(count, numComponents, DataType.UByte) }
  construct fromBufferView(bufferView, numComponents, stride, offset) { super(bufferView, numComponents, stride, offset, DataType.UByte) }
  getVal(b,o,v) { 
    b.readUByteVec(o,v)
    return v 
  }
  setVal(b,o,v) { b.writeUByteVec(o,v) }
}

class ShortVecAccessor is Accessor {
  construct new(count, numComponents){ super(count, numComponents, DataType.Short) }
  construct fromBufferView(bufferView, numComponents, stride, offset) { super(bufferView, numComponents, stride, offset, DataType.Short) }
  getVal(b,o,v) { 
    b.readShortVec(o,v)
    return v 
  }
  setVal(b,o,v) { b.writeShortVec(o,v) }
}

class UShortVecAccessor is Accessor {
  construct new(count, numComponents){ super(count, numComponents, DataType.UShort) }
  construct fromBufferView(bufferView, numComponents, stride, offset) { super(bufferView, numComponents, stride, offset, DataType.UShort) }
  getVal(b,o,v) { 
    b.readUShortVec(o,v)
    return v 
  }
  setVal(b,o,v) { b.writeUShortVec(o,v) }
}

class IntVecAccessor is Accessor {
  construct new(count, numComponents){ super(count, numComponents, DataType.Int) }
  construct fromBufferView(bufferView, numComponents, stride, offset) { super(bufferView, numComponents, stride, offset, DataType.Int) }
  getVal(b,o,v) { 
    b.readIntVec(o,v)
    return v 
  }
  setVal(b,o,v) { b.writeIntVec(o,v) }
}

class UIntVecAccessor is Accessor {
  construct new(count, numComponents){ super(count, numComponents, DataType.UInt) }
  construct fromBufferView(bufferView, numComponents, stride, offset) { super(bufferView, numComponents, stride, offset, DataType.UInt) }
  getVal(b,o,v) { 
    b.readUIntVec(o,v)
    return v 
  }
  setVal(b,o,v) { b.writeUIntVec(o,v) }
}

class FloatVecAccessor is Accessor {
  construct new(count, numComponents){ super(count, numComponents, DataType.Float) }
  construct fromBufferView(bufferView, numComponents, stride, offset) { super(bufferView, numComponents, stride, offset, DataType.Float) }
  getVal(b,o,v) { 
    b.readFloatVec(o,v)
    return v 
  }
  setVal(b,o,v) { b.writeFloatVec(o,v) }
}
