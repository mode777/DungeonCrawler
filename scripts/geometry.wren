foreign class Buffer {
  construct new(size){
    allocate(size)
  }
  construct fromBuffer(buffer, offset, size){
    copy(buffer, offset, size)
  }
  construct fromFile(path){
    load(path)
  }

  foreign load(path)
  foreign allocate(size)
  foreign copy(buffer, offset, size)

  foreign getSize()
  // foreign readByte(offset)
  // foreign readUByte(offset)
  // foreign readShort(offset)
  // foreign readUShort(offset)
  // foreign readInt(offset)
  // foreign readUInt(offset)
  // foreign readFloat(offset)
  // foreign readVec2(offset, vec2)
  // foreign readVec3(offset, vec3)
  // foreign readVec4(offset, vec4)
  // foreign readDouble(offset)
  // foreign getBytes(offset, size)
}

foreign class BufferView {
  construct new(buffer, offset, size){
    buffer(buffer, offset, size)
  }

  foreign buffer(buffer, offset, size)
  
  foreign getSize()
}

foreign class ImageData {  
  construct new(width, height, channels){
    allocate(width, height, channels)
  }
  construct fromBufferView(view){
    bufferView(view)
  }
  construct fromFile(path, channels){
    load(path, channels)
  }

  foreign load(path, channels)
  foreign bufferView(view)
  foreign allocate(width, height, channels)
  foreign put(imgData, x, y)

  foreign getWidth()
  foreign getHeight()
  foreign getChannels()
}

foreign class Texture {
  construct new(imgData){
    data(imgData)
  }

  foreign data(imgData)
}

class BufferView {
  construct new(buffer, offset, size){
    _buffer = buffer
  }
}

class Attribute {

}

class GeometryData {

}