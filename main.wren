import "PGL" for Game, Keyboard, Camera, File, Renderer, Window, Transform
import "gltf" for GLTF

//var gltf = GLTF.new("./assets/desert/scene2.gltf")
//var gltf2 = GLTF.new("./assets/game/bake.gltf")

var mesh = null
var g = 0
var rad = 10
//var rz = 1
var transform = null
var camera = null
var rx = 0
var ry = 0
var rz = 0

Game.onInit {
  Window.config(720,480,"WrenGame!")
}

Game.onLoad {
  var gltf = GLTF.load("./assets/desert/scene2.gltf")
  mesh = gltf.meshes[0]

  transform = Transform.new()
  camera = Transform.new()
}

Game.onUpdate {|delta|   
  
  if(Keyboard.isDown("w")){
    rz = rz + 0.02
    //camera.rotate(0,0, 0.02)
    rad = rad - 0.05
  } else if(Keyboard.isDown("s")) {
    //camera.rotate(0,0, -0.02)
    rz = rz - 0.02
    rad = rad + delta    
  }

  if(Keyboard.isDown("q")){
    //camera.rotate(0.02,0, 0)
    rad = rad - 0.05
    rx = rx - 0.02
  } else if(Keyboard.isDown("e")) {
    //camera.rotate(-0.02,0, 0)
    rad = rad + delta    
    rx = rx + 0.02
  }

  if(Keyboard.isDown("a")){
    //camera.rotate(0,0.02,0)
    ry = ry + 0.02
    g = g - 0.02
  } else if(Keyboard.isDown("d")) {
    //camera.rotate(0,-0.02,0)
    ry = ry - 0.02
    g = g + 0.02      
  }

  if(Keyboard.isDown("up")){
    System.print("up")
  }

  rad = rad - 0.01
  camera.reset()
  camera.rotate(0, ry, 0)
  camera.rotate(0, 0, rz)
  camera.rotate(rx, 0, 0)
  //Camera.orbit(rad, g)
  Camera.setTransform(camera)

  transform.reset()
  //transform.translate(0,10,0)
  //mesh.render()

  for (y in -4...4) {
    for (x in -4...4) {
      //System.print("x: %(x), y: %(y)")
      transform.reset()
      transform.translate(2*x,-1,2*y)        
      Renderer.setTransform(transform)
      mesh.render()    
    }      
  }  
}