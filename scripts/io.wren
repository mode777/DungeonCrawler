class Path {
  static getFolder(filename){
    filename = filename.replace("\\","/")
    var frags = filename.split("/")
    frags.removeAt(-1)
    return frags.join("/")
  }
}

class SeekOrigin {
  static Start { 0 }
  static Current { 1 }
  static End { 2 }
}

foreign class File { 
  construct open(path, mode) {}
  foreign length()
  foreign close() 
  foreign read(size)
  foreign readString(size)
  foreign pos()
  foreign readUByte() 
  foreign readByte() 
  foreign readUShort()
  foreign readShort()
  foreign readUInt()
  foreign readInt()
  foreign readFloat()
  foreign readDouble()
  foreign seek(offset, origin)
  readToEnd(){
    return read(length())
  }
}