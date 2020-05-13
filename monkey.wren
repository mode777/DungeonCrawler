import "platform" for Application, Keyboard, Window, Severity, Mouse
import "graphics" for Renderer, Geometry, Mesh, UniformType, Shader, DiffuseMaterial
import "geometry" for AttributeType, GeometryData
import "gltf" for Gltf
import "math" for Mat4, Vec2, Math
import "camera" for PointAtCamera, FlyCamera

var width = 1280
var height = 720

var mesh
var camera
var modelIT

Application.onInit {
  Application.logLevel(Severity.Info)
  Window.config(width,height,"My Game Engine!")
}

Application.onLoad {
  var gltf = Gltf.fromFile("./assets/suzanne/suzanne.gltf")
  var merged = GeometryData.merge(gltf.meshes[0].primitives)
  var geo = Geometry.new(merged)

  var texture = gltf.textures[0].toGraphicsTexture()
  var mat = DiffuseMaterial.new(texture)

  camera = PointAtCamera.new()
  mesh = Mesh.new(geo, mat)
  mesh.transform.scale(0.5,0.5,0.5)

  Renderer.setUniformVec3(UniformType.Light0, [3,0,3])
  modelIT = Mat4.new()
}

Application.onUpdate {|delta|
  mesh.transform.rotateY(0.01)
  
  camera.enable()
  
  modelIT.copy(mesh.transform)
  modelIT.invert()
  modelIT.transpose()
  Renderer.setUniformMat4(UniformType.Normal, modelIT)

  mesh.draw()
}