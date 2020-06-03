import "platform" for Application, Keyboard, Window, Severity, Mouse
import "graphics" for Renderer, Geometry, Mesh, UniformType, Shader, DiffuseMaterial, Colors, Texture, TextureFilters
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

Application.onInit {
  Application.logLevel(Severity.Info)
  Window.config(width,height,"2D Test!")
}

Application.onLoad {
  Renderer.set2d()
  
  Renderer.setBackgroundColor(1.0,1.0,1.0)
  var img = Image.fromFile("./assets/tileset.png")
  var txt = Texture.fromImage(img)
  txt.magFilter(TextureFilters.Nearest)
  var mat = DiffuseMaterial.new(txt)

  var gd = GeometryData.new({
    AttributeType.Position: FloatVecAccessor.new(4,2),
    AttributeType.Texcoord0: FloatVecAccessor.new(4,2)
  }, UShortAccessor.new(6))
  
  gd.positions[0] = [0,0]
  gd.positions[1] = [0,1]
  gd.positions[2] = [1,1]
  gd.positions[3] = [1,0]
  
  gd.texcoords[0] = [0,0]
  gd.texcoords[1] = [0,1]
  gd.texcoords[2] = [1,1]
  gd.texcoords[3] = [0,1]
  
  gd.indices[0] = 0
  gd.indices[1] = 1
  gd.indices[2] = 2

  gd.indices[3] = 0
  gd.indices[4] = 2
  gd.indices[5] = 3

  meshes.add(Mesh.new(Geometry.new(gd), mat))
}

Application.onUpdate {|d|
  for(m in meshes){
    //m.transform.rotateY(0.005)
    //m.transform.rotateX(0.01)
    m.draw()
  }

  Renderer.checkErrors()
}