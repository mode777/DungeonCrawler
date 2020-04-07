import "pgl" for Game, Keyboard, File, Renderer, Window, Transform, Camera
import "gltf" for GLTF

var mesh = null
var transform = null
var camera = null

Game.onInit {
  Window.config(800,480,"WrenGame!")
}

Game.onLoad {
  //var gltf = GLTF.load("./assets/desert/scene2.gltf")
  var gltf = GLTF.load("./assets/blocks/stone1.gltf")
  mesh = gltf.meshes[0]

  transform = Transform.new()
  camera = Camera.new()
}

Game.onUpdate {|delta|   
  
  if(Keyboard.isDown("w")){
    camera.rotate(0,0, 0.02)
  } else if(Keyboard.isDown("s")) {
    camera.rotate(0,0, -0.02)
  }

  if(Keyboard.isDown("q")){
    camera.rotate(0.02,0, 0)
  } else if(Keyboard.isDown("e")) {
    camera.rotate(-0.02,0, 0)
  }

  if(Keyboard.isDown("a")){
    camera.rotate(0,0.02,0)
  } else if(Keyboard.isDown("d")) {
    camera.rotate(0,-0.02,0)
  }

  if(Keyboard.isDown("up")){
    camera.move(0.02, 0, 0)
  } else if(Keyboard.isDown("down")) {
    camera.move(-0.02, 0, 0)
  }

  if(Keyboard.isDown("left")){
    camera.move(0,0,-0.02)
  } else if(Keyboard.isDown("right")) {
    camera.move(0,0,0.02)
  }

  if(Keyboard.isDown("o")){
    camera.move(0,-0.02,0)
  } else if(Keyboard.isDown("l")) {
    camera.move(0,0.02,0)
  }

  Renderer.setCamera(camera)

  for (y in -4...4) {
    for (x in -4...4) {
      //System.print("x: %(x), y: %(y)")
      transform.reset()
      transform.translate(x,-1,0.5*y)        
      Renderer.setTransform(transform)
      mesh.render()    
    }      
  }  
}