import "platform" for Application, Keyboard, Window, Severity, Mouse
import "graphics" for Renderer, Geometry, Mesh, UniformType, Shader, DiffuseMaterial, Colors, Texture
import "geometry" for AttributeType, GeometryData, GeometryWriter
import "gltf" for Gltf
import "math" for Mat4, Vec2, Math, Vec3, Vec4, Noise
import "camera" for PointAtCamera, FlyCamera, OrbitCamera
import "hexaglott" for Hexaglott, HexData
import "memory" for FloatVecAccessor, UShortAccessor, UByteVecAccessor, Buffer, BufferView, DataType, ListUtil
import "image" for Image
import "helpers" for CameraHelpers

var width = 1280
var height = 720

var meshes = []
var camera

var loadGeometry = Fn.new{|path|
 var gltf = Gltf.fromFile(path)
  //meshes = gltf.scenes[0].toGraphicsMeshes()
  var gds = ListUtil.selectMany(gltf.meshes){|m| m.primitives.map {|x| x.geometryData}.toList }.toList
  var material = gltf.meshes[0].primitives[0].material.toGraphicsMaterial()
  var merged = GeometryData.merge(gds)
  var geometry = Geometry.new(merged)
  return [geometry, material]
}

Application.onInit {
  Application.logLevel(Severity.Info)
  Window.config(width,height,"Light test!")
}

Application.onLoad {
  Renderer.setBackgroundColor(1.0,1.0,1.0)

  var p1 = loadGeometry.call("./assets/tiles/grass.glb")
  var p2 = loadGeometry.call("./assets/tiles/road1010.glb")

  for(y in -4...4){
    for(x in -4...4){
      var m = Mat4.new()
      m.translate(x*10,0,y*10)
      var mesh
      if(x != 0) {mesh = Mesh.new(p1[0], p1[1], m)} else {mesh = Mesh.new(p2[0], p2[1], m)}
      meshes.add(mesh)
    }
  }

  //meshes = gltf.nodes.map {|x| GeoTransform.new(x.mesh.primitives[0]).getMesh(x.transform)}.toList
  
  // for(y in 0...8){
  //   for(x in 0...8){
  //     var t = Mat4.new()
  //     t.translate(x*8, 0, y*8)
  //     var m = GeoTransform.new(gltf.mesh("Mesh.001").primitives[0]).getMesh(t)
  //     meshes.add(m)
  //   }
  // }

//  meshes = []
  camera = FlyCamera.new()
  //camera.radius = 50
  //camera.phi = 90
  //camera.pitch = 0
}

var t

Application.onUpdate {|d|
  if(t == null) t = 0 else t = t + d
  Renderer.setUniformFloat(UniformType.Time, t)
  
  //camera.moveForward(-0.01)
  CameraHelpers.FlyCameraKeyboardInput(camera, 0.8)
  camera.enable()

  for(m in meshes){
    //m.transform.rotateY(0.005)
    //m.transform.rotateX(0.01)
    m.draw()
  }

  //Renderer.checkErrors()
}