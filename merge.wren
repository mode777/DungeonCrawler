import "platform" for Application, Keyboard, Window, Severity, Mouse
import "graphics" for Renderer, Geometry, Mesh, UniformType, Shader, DiffuseMaterial
import "geometry" for AttributeType, GeometryData
import "gltf" for Gltf
import "math" for Mat4, Vec2, Math
import "camera" for PointAtCamera, FlyCamera

var width = 1280
var height = 720

var mesh = null
var meshes = []

var up = [0,1,0]
var target = [0,0,0]
var cam = [1,2,3]

var camera

var mouse = [0,0]
var mouseLast = [0,0]
var mouseDelta = [0,0]

Application.onInit {
  Application.logLevel(Severity.Debug)
  Window.config(width,height,"My Game Engine!")
}

Application.onLoad {

  camera = FlyCamera.new()

  var gltf = Gltf.fromFile("./assets/blocks/stone1.gltf")
  var merged = GeometryData.merge(gltf.meshes[0].primitives)
  var toBeMerged = []
  var t = Mat4.new()
  for(y in 0...8){
    for(x in 0...8){
      t.identity()
      var clone = GeometryData.clone(merged)
      t.translate(y,0,x*0.5)
      clone.transform(AttributeType.Position, t)
      toBeMerged.add(clone) 
    }
  }
  merged = GeometryData.merge(toBeMerged)

  var geo = Geometry.new(merged)

  var texture = gltf.textures[0].toGraphicsTexture()
  var mat = DiffuseMaterial.new(texture)

  for(y in 0...8){
    for(x in 0...8){
      var mesh = Mesh.new(geo, mat)
      mesh.transform.translate(y*8,0,x*4)
      meshes.add(mesh) 
    }
  }


  Mouse.setPosition(width/2,height/2)
  Mouse.getPosition(mouse)
  Vec2.copy(mouse, mouseLast)
}

Application.onUpdate {|delta|

  if(Keyboard.isDown("w")){
    camera.moveForward(0.1)
  }
  if(Keyboard.isDown("s")) {
    camera.moveForward(-0.1)
  }

  if(Keyboard.isDown("a")){
    camera.moveRight(-0.1)
  }
  if(Keyboard.isDown("d")) {
    camera.moveRight(0.1)
  }

  if(Keyboard.isDown("up")){
    camera.pitch = camera.pitch + 1
  }
  if(Keyboard.isDown("down")){
    camera.pitch = camera.pitch - 1
  }
  if(Keyboard.isDown("left")){
    camera.yaw = camera.yaw - 1
  }
  if(Keyboard.isDown("right")){
    camera.yaw = camera.yaw + 1
  }
  
  camera.enable()
  for(mesh in meshes){
    mesh.draw()
  }
}