import "platform" for Application, Keyboard, Window, Severity, Mouse
import "graphics" for Renderer, Geometry, Mesh, UniformType, Shader, DiffuseMaterial, Colors, Texture
import "geometry" for AttributeType, GeometryData, GeometryWriter
import "gltf" for Gltf
import "math" for Mat4, Vec2, Math, Vec3, Noise
import "camera" for PointAtCamera, FlyCamera
import "hexaglott" for Hexaglott, HexData
import "memory" for FloatVecAccessor, UShortAccessor, UByteVecAccessor, Buffer, BufferView, DataType
import "image" for Image

var width = 1280
var height = 720

var meshes = []
var camera
var light = [1,1,1]
var texture

Application.onInit {
  Application.logLevel(Severity.Debug)
  Window.config(width,height,"My Game Engine!")
}

Application.onLoad {

  var shader = Hexaglott.createShader()
  Renderer.setShader(shader)

  var gltf = Gltf.fromFile("./assets/three.gltf")
  meshes = gltf.scene("Scene").toGraphicsMeshes()
  texture = Texture.fromFile("./assets/palette.png")
  
  camera = PointAtCamera.new()
  camera.setPosition(5, 2, 0)
  camera.setTarget(0, 1, 0)
}

Application.onUpdate {|delta|
  camera.enable()
  Renderer.setUniformVec3(UniformType.Light0, light)
  for(mesh in meshes){
    mesh.draw()
  }
}