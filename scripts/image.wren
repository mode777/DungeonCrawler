foreign class Image {  
  construct new(width, height){
    allocate(width, height)
  }
  construct fromBuffer(buf){
    buffer(buf, 0, buffer.size)
  }
  construct fromBufferView(view){
    buffer(view.buffer, view.offset, view.size)
  }
  construct fromFile(path){
    load(path)
  }

  width { getWidth() }
  height { getHeight() }

  //private 
  foreign load(path)
  foreign buffer(buffer, offset, size)
  foreign allocate(width, height)

  // public
  foreign put(imgData, sx, sy, sw, sh, dx, dy)
  put(imgData){
    put(imgData, 0, 0, imgData.width, imgData.height)
  }
  put(imgData, dx, dy){
    put(imgData, 0, 0, imgData.width, imgData.height, dx, dy)
  }
  foreign setPixel(x, y, r, g, b, a)
  foreign setPixel(x, y, vec4)
  foreign getPixel(x, y, vec4)
  foreign getPixelInt(x,y)
  foreign save(filename)

  foreign getWidth()
  foreign getHeight()
}