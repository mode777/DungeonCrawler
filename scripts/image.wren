foreign class Image {  
  construct new(width, height){
    allocate(width, height, 4)
  }
  construct new(width, height, channels){
    allocate(width, height, channels)
  }
  construct fromBuffer(buf){
    buffer(buf, 0, buf.size, 4)
  }
  construct fromBuffer(buf, channels){
    buffer(buf, 0, buf.size, channels)
  }
  construct fromBufferView(view){
    buffer(view.buffer, view.offset, view.size, 4)
  }
  construct fromBufferView(view, channels){
    buffer(view.buffer, view.offset, view.size, channels)
  }
  construct fromFile(path){
    load(path, 4)
  }

  width { getWidth() }
  height { getHeight() }

  //private 
  foreign load(path, channels)
  foreign buffer(buffer, offset, size, channels)
  foreign allocate(width, height, channels)

  // public
  foreign put(imgData, sx, sy, sw, sh, dx, dy)
  put(imgData){
    put(imgData, 0, 0, imgData.width, imgData.height)
  }
  put(imgData, dx, dy){
    put(imgData, 0, 0, imgData.width, imgData.height, dx, dy)
  }
  foreign setPixel(x, y, vec)
  foreign getPixel(x, y, vec)
  foreign getPixelInt(x,y)
  foreign save(filename)

  foreign getWidth()
  foreign getHeight()
}