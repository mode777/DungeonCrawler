class Math {
  static rad(deg){ deg * 0.01745329252 }
  static deg(rad){ rad / 0.01745329252 }
  static min(a,b) { a < b ? a : b }
  static max(a,b) { a < b ? b : a }
  static clamp(low,high,val) { Math.min(Math.max(val, low), high) }
}

class Vec2 {

  static zero(dst){
    dst[0] = 0
    dst[1] = 0
  }

  static zero(){
    return [0,0]
  }

  static copy(a,b){
    b[0] = a[0]
    b[1] = a[1] 
  }

  static clone(a){
    return [a[0],a[1]]
  }

  static add(a,b,dest){
    dest[0] = a[0] + b[0]
    dest[1] = a[1] + b[1]
  }

  static add(a,x,y,dest){
    dest[0] = a[0] + x
    dest[1] = a[1] + y
  }

  static addV(a,v,dest){
    dest[0] = a[0] + v
    dest[1] = a[1] + v
  }

  static sub(a,b,dest){
    dest[0] = a[0] - b[0]
    dest[1] = a[1] - b[1]
  }

  static set(x,y, dest){
    dest[0] = x
    dest[1] = y
  }

  static floor(src,dst){
    dst[0] = src[0].floor
    dst[1] = src[1].floor
  }

  static frac(src,dst){
    dst[0] = src[0] - src[0].floor
    dst[1] = src[1] - src[1].floor
  }

  static mul(a,b,dst){
    dst[0] = a[0] * b[0]
    dst[1] = a[1] * b[1]
  }

  static mulV(a,v,dst){
    dst[0] = a[0] * v
    dst[1] = a[1] * v
  }

  static sign(src,dst){
    dst[0] = src[0] > 0 ? 1 : (src[0] < 0 ? -1 : 0)
    dst[1] = src[1] > 0 ? 1 : (src[1] < 0 ? -1 : 0)
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

  static copy(src, dst){
    dst[0] = src[0] 
    dst[1] = src[1] 
    dst[2] = src[2] 
    dst[3] = src[3] 
  }

  static zero(){
    return [0,0,0,0]
  }

  static add(a,b,dst){
    dst[0] = a[0]+b[0]
    dst[1] = a[1]+b[1]
    dst[2] = a[2]+b[2]
    dst[3] = a[3]+b[3]
  }

  static divV(a,v,dst){
    dst[0] = a[0]/v
    dst[1] = a[1]/v
    dst[2] = a[2]/v
    dst[3] = a[3]/v
  }

  static mulV(a,v,dst){
    dst[0] = a[0]*v
    dst[1] = a[1]*v
    dst[2] = a[2]*v
    dst[3] = a[3]*v
  }

  static equals(a,b){
    return a[0] == b[0] &&
    a[1] == b[1] &&
    a[2] == b[2] &&
    a[3] == b[3]
  }

  static set(x,y,z,w,dst){
    dst[0] = x 
    dst[1] = y 
    dst[2] = z 
    dst[3] = w 
  }

  static clampV(src,v,dest){
    dest[0] = Math.min(src[0],v)
    dest[1] = Math.min(src[1],v)
    dest[2] = Math.min(src[2],v)
    dest[3] = Math.min(src[3],v)
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

  static clone(src){
    return [src[0],src[1],src[2]]
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

  static set(src,dst){
    dst[0] = src[0]
    dst[1] = src[1]
    dst[2] = src[0]
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

  static div(a,b,dst){
    dst[0] = a[0] / b[0]
    dst[1] = a[1] / b[1]
    dst[2] = a[2] / b[2]
  }

  static divV(a, v, dst){
    dst[0] = a[0] / v
    dst[1] = a[1] / v
    dst[2] = a[2] / v
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

  static distance2(a,b){
    return (a[0] - b[0]).pow(2) + (a[1] - b[1]).pow(2) + (a[2] - b[2]).pow(2)
  }

  static distance(a,b){
    return distance2(a,b).sqrt
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
  foreign ortho()
}

class Noise {
  foreign static seed(seed)
  foreign static perlin2d(x,y,freq,depth)
}