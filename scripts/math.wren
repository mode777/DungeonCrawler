class Math {
  static rad(deg){ deg * 0.01745329252 }
  static deg(rad){ rad / 0.01745329252 }
}

class Vec2 {
  static copy(a,b){
    b[0] = a[0]
    b[1] = a[1] 
  }

  static add(a,b,dest){
    dest[0] = a[0] + b[0]
    dest[1] = a[1] + b[1]
  }

  static sub(a,b,dest){
    dest[0] = a[0] - b[0]
    dest[1] = a[1] - b[1]
  }
}

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

  static mul(a,b,dst){
    dst[0] = a[0] * b[0]
    dst[1] = a[1] * b[1]
    dst[2] = a[2] * b[2]
  }

  static mulV(a, v, dst){
    dst[0] = a[0] * v
    dst[1] = a[1] * v
    dst[2] = a[2] * v
  }

  static sub(v1, v2, dst){
    dst[0] = v1[0] - v2[0]
    dst[1] = v1[1] - v2[1]
    dst[2] = v1[2] - v2[2]
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

  static norm(v){
    return Vec3.norm2(v).sqrt
  }

  static cross(a,b,dest){
    var a0 = a[0]
    var a1 = a[1]
    var a2 = a[2]
    var b0 = b[0]
    var b1 = b[1]
    var b2 = b[2]
    dest[0] = a1 * b2 - a2 * b1
    dest[1] = a2 * b0 - a0 * b2
    dest[2] = a0 * b1 - a1 * b0
  }

  static crossn(a,b,dest){
    cross(a,b,dest)
    normalize(dest,dest)
  }

  static norm2(v){
    return Vec3.dot(v,v)
  }

  static normalize(v, d) {
    var norm = Vec3.norm(v)

    if (norm == 0.0) {
      d[0] = 0
      d[1] = 0
      d[2] = 0
      return
    }

    Vec3.scale(v, 1.0 / norm, d)
  }

  static scale(v,s,d){
    d[0] = v[0] * s 
    d[1] = v[1] * s 
    d[2] = v[2] * s 
  }

  static dot(a,b){
    return a[0] * b[0] + a[1] * b[1] + a[2] * b[2]
  }
}

foreign class Mat4 {
  construct new(){
    identity()
  }
  construct clone(m){
    copy(m)
  }
  foreign identity()
  foreign translate(x,y,z)
  foreign rotateX(v)
  foreign rotateY(v)
  foreign rotateZ(v)
  foreign rotateQuat(a,b,c,d)
  foreign scale(x,y,z)
  foreign copy(m)
  foreign mul(m)
  foreign mulVec3(v3)
  foreign project(v3)
  foreign unproject(v3)
  foreign lookAt(eye, target, up)
  foreign invert()
  foreign transpose()
  foreign perspective(fov, near, far)
}

class Noise {
  foreign static seed(seed)
  foreign static perlin2d(x,y,freq,depth)
}