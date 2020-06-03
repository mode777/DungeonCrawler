import "platform" for Application, Keyboard, Window, Severity, Mouse
import "graphics" for Renderer, Geometry, Mesh, UniformType, Shader, DiffuseMaterial, Colors, Texture
import "geometry" for AttributeType, GeometryData, GeometryWriter
import "gltf" for Gltf
import "math" for Mat4, Vec2, Math, Vec3, Vec4, Noise
import "camera" for PointAtCamera, FlyCamera, OrbitCamera
import "hexaglott" for Hexaglott, HexData
import "memory" for FloatVecAccessor, UShortAccessor, UByteVecAccessor, Buffer, BufferView, DataType
import "image" for Image
import "helpers" for CameraHelpers

var width = 1280
var height = 720

var meshes = []
var camera

Application.onInit {
  Application.logLevel(Severity.Info)
  Window.config(width,height,"Light test!")
}

Application.onLoad {
  

  var gltf = Gltf.fromFile("assets/metacave3/metacave3.gltf")
  //meshes = gltf.scenes[0].toGraphicsMeshes()
  var gds = gltf.meshes[0].primitives.map {|x| x.geometryData}.toList
  var material = gltf.meshes[0].primitives[0].material.toGraphicsMaterial()
  var merged = GeometryData.merge(gds)
  var geometry = Geometry.new(merged)

  for(y in -4...4){
    for(x in -4...4){
      var m = Mat4.new()
      m.translate(x*10,0,y*10)
      var mesh = Mesh.new(geometry, material, m)
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
  camera = OrbitCamera.new()
  camera.radius = 50
  camera.phi = 90
  //camera.pitch = 0
}

Application.onUpdate {|d|
  //camera.moveForward(-0.01)
  CameraHelpers.OrbitCameraKeyboardInput(camera, 0.5)
  camera.enable()

  for(m in meshes){
    //m.transform.rotateY(0.005)
    //m.transform.rotateX(0.01)
    m.draw()
  }

  Renderer.checkErrors()
}