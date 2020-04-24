class Vec4 {
  static create(x,y,z,w){
    return [x,y,z,w]
  }

  static zero(dst){
    dst[0] = 0
    dst[1] = 0
    dst[2] = 0
    dst[3] = 0
  }

  static zero(){
    return [0,0,0,0]
  }
}

class Vec3 {
  static zero(dst){
    dst[0] = 0
    dst[1] = 0
    dst[2] = 0
  }

  static zero(){
    return [0,0,0]
  }

  static one(dst){
    dst[0] = 1
    dst[1] = 1
    dst[2] = 1
  }

  static create(x,y,z){
    return [x,y,z]
  }

  static set(x,y,z,dst){
    dst[0] = x
    dst[1] = y
    dst[2] = z
  }

  static copy(src,dst){
    dst[0] = src[0]
    dst[1] = src[1]
    dst[2] = src[2]
  }

  static add(v1,v2,dst){
    dst[0] = v1[0] + v2[0]
    dst[1] = v1[1] + v2[1]
    dst[2] = v1[2] + v2[2]
  }

  static add(v1,x,y,z,dst){
    dst[0] = v1[0] + x
    dst[1] = v1[1] + y
    dst[2] = v1[2] + z
  }

  static sub(v1, v2, dst){
    dst[0] = v1[0] + v2[0]
    dst[1] = v1[1] + v2[1]
    dst[2] = v1[2] + v2[2]
  }

  static extract(all, offset, dst){
    dst[0] = all[offset + 0]
    dst[1] = all[offset + 1]
    dst[2] = all[offset + 2]
  }

  static insert(src, offset, all){
    all[offset+0] = src[0]
    all[offset+1] = src[1]
    all[offset+2] = src[2]
  }
}