import "platform" for Application, Keyboard, Window, Severity, Mouse
import "graphics" for Renderer, Geometry, Mesh, UniformType, Shader, DiffuseMaterial, Colors
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
var light = [1,2,1]

Application.onInit {
  Application.logLevel(Severity.Debug)
  Window.config(width,height,"My Game Engine!")
}

Application.onLoad {

  var shader = Hexaglott.createShader()
  Renderer.setShader(shader)

  var size = 0.125
  var w = 2 * size
  var h = 3.sqrt * size

  // var gd = HexData.new(256, size)
  // for(y in 0...16){
  //   for(x in 0...16){
  //     var z = (x.cos+1+y.sin+1)/4
  //     z = (z*16).floor / 16
  //     gd.addHexagon(x,y,z, [y*16,x*16,(x*y)%255,255])
  //   }
  // }

  var gltfTree = Gltf.fromFile("./assets/sphere.gltf")
  var gltfGround = Gltf.fromFile("./assets/ground.gltf")
  //var gd = gltf.meshes[0].primitives[0]

  var tree = Geometry.new(gltfTree.meshes[0].primitives[0])
  var ground = Geometry.new(gltfGround.meshes[0].primitives[0])

  var mat = Hexaglott.createMaterial()

  meshes.add(Mesh.new(tree, mat))
  meshes.add(Mesh.new(ground, mat))
  
  camera = FlyCamera.new()
  Mouse.setPosition(width/2,height/2)
}

Application.onUpdate {|delta|
  
  if(Keyboard.isDown("right")) camera.moveRight(0.1)
  if(Keyboard.isDown("left")) camera.moveRight(-0.1)
  if(Keyboard.isDown("up")) camera.moveForward(0.1)
  if(Keyboard.isDown("down")) camera.moveForward(-0.1)
  

  if(Keyboard.isDown("w")) camera.pitch(0.5) 
  if(Keyboard.isDown("a")) camera.yaw(-0.5)
  if(Keyboard.isDown("s")) camera.pitch(-0.5)
  if(Keyboard.isDown("d")) camera.yaw(0.5)
  
  camera.enable()
  Renderer.setUniformVec3(UniformType.Light0, light)
  for(mesh in meshes){
    mesh.draw()
  }
}