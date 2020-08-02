import "platform" for Application, Keyboard, Window, Severity, Mouse, Event
import "graphics" for Renderer, Geometry, Mesh, UniformType, Shader, DiffuseMaterial, Colors, Texture, Node
import "geometry" for AttributeType, GeometryData, GeometryWriter
import "gltf" for Gltf
import "math" for Mat4, Vec2, Math, Vec3, Vec4, Noise
import "camera" for PointAtCamera, FlyCamera, OrbitCamera
import "hexaglott" for Hexaglott, HexData
import "memory" for FloatVecAccessor, UShortAccessor, UByteVecAccessor, Buffer, BufferView, DataType, ListUtil, Grid
import "image" for Image
import "helpers" for CameraHelpers
import "wfc" for Wfc

var width = 1280
var height = 720

var meshes = {}
var camera
var grid

var loadGeometry = Fn.new{|path|
 var gltf = Gltf.fromFile(path)
  var gds = ListUtil.selectMany(gltf.meshes){|m| m.primitives.map {|x| x.geometryData}.toList }.toList
  var material = gltf.meshes[0].primitives[0].material.toGraphicsMaterial()
  var merged = GeometryData.merge(gds)
  var geometry = Geometry.new(merged)
  return Mesh.new(geometry, material)
}

Application.on(Event.Load) {|args|
  Renderer.setBackgroundColor(1.0,1.0,1.0)

  meshes = {
    "0000": loadGeometry.call("./assets/tiles/grass.glb"),
    "1010": loadGeometry.call("./assets/tiles/road1010.glb"), 
    "0101": loadGeometry.call("./assets/tiles/road0101.glb"), 
    "1001": loadGeometry.call("./assets/tiles/road1001.glb"), 
    "1100": loadGeometry.call("./assets/tiles/road1100.glb"), 
    "0110": loadGeometry.call("./assets/tiles/road0110.glb"), 
    "0011": loadGeometry.call("./assets/tiles/road0011.glb"), 
  }

  grid = Grid.new(8,8)

  grid.fill {|x,y|
    var m = Mat4.new()
    m.translate(x*10,0,y*10)
    return Node.new(null,m)
  }

  camera = OrbitCamera.new()
  camera.radius = 20
  camera.phi = 45
  camera.theta = 45
  var x = 0
  var y = 0
  var setTarget = Fn.new {
    camera.setTarget(x*10,0,y*10)
  }

  setTarget.call()

  Application.on("[wfc]pos"){|args|
    x = args[0]
    y = args[1]
    setTarget.call()
  }

  Application.on("[wfc]set"){|args|
    grid[args[0],args[1]].mesh = meshes[args[2]]
  }

  CameraHelpers.OrbitCameraMouseInput(camera, 0.8)
}

var t

Application.on(Event.Update) {|args|
  Renderer.set3d()

  if(t == null) t = 0 else t = t + args[1]
  Renderer.setUniformFloat(UniformType.Time, t)
  
  camera.enable()

  for(n in grid){
    n.draw()
  }
}