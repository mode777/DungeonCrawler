import "platform" for Application, Keyboard, Window, Severity
import "graphics" for Transform, Camera, Renderer
import "gltf" for Gltf

var mesh = null
var texture = null
var transform = null
var camera = null

Application.onInit {
  Application.logLevel(Severity.Debug)
  Window.config(800,480,"WrenGame!")
}

Application.onLoad {
  System.print("LOAD!!!!")
  //var gltf = GLTF.load("./assets/desert/scene2.gltf")
  var gltf = Gltf.fromFile("./assets/blocks/stone1.gltf")
  mesh = gltf.meshes[0].toGraphicsMesh()
  texture = gltf.textures[0].toGraphicsTexture()
  transform = Transform.new()
  camera = Camera.new()
}

Application.onUpdate {|delta|   
  
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
      mesh.draw()    
      Renderer.checkErrors()
    }      
  }  
}