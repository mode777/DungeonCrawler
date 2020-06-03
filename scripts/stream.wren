class StreamReader {

  offset { _offset }

  construct new(stream){
    _stream = stream
    _offset = 0
  }

  readByte(){
    var v = _stream.readByte(_offset)
    seekRel(1)
    return v
  }

  readUByte(){
    var v = _stream.readUByte(_offset)
    seekRel(1)
    return v
  }

  readShort(){
    var v = _stream.readShort(_offset)
    seekRel(2)
    return v
  }

  readUShort(){
    var v = _stream.readUShort(_offset)
    seekRel(2)
    return v
  }

  readInt(){
    var v = _stream.readInt(_offset)
    seekRel(4)
    return v
  }

  readUInt(){
    var v = _stream.readUInt(_offset)
    seekRel(4)
    return v
  }

  readFloat(){
    var v = _stream.readFloat(_offset)
    seekRel(4)
    return v
  }

  readDouble(){
    var v = _stream.readDouble(_offset)
    seekRel(8)
    return v
  }

  readString(size){
    var v = _stream.readString(_offset, size)
    seekRel(size)
    return v
  }

  seekRel(o){
    _offset = _offset + o
  }

  seek(o){
    _offset = o
  }
}