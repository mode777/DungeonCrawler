foreign class File { 
  construct open(path, mode) {}
  foreign length()
  foreign read(bytes) 
  foreign close() 
  readToEnd(){
    return read(length())
  }
}