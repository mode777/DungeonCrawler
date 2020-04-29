import "platform" for Application, Keyboard, Window, Severity, Mouse
import "graphics" for Transform, Camera, Renderer, Geometry, Mesh
import "geometry" for AttributeType, GeometryData
import "gltf" for Gltf

var mesh = null
var single = null
var singleTransform = null
var texture = null
var transform = null
var camera = null

Application.onInit {
  Application.logLevel(Severity.Warning)
  Window.config(640,400,"WrenGame!")
}

Application.onLoad {
  //var gltf = GLTF.load("./assets/desert/scene2.gltf")
  var gltf = Gltf.fromFile("./assets/blocks/stone1.gltf")
  //mesh = gltf.meshes[0].toGraphicsMesh()
  var merged = GeometryData.merge(gltf.meshes[0].primitives)
  
  single = Mesh.new([Geometry.new(merged)])
  singleTransform = Transform.new() 
  
  var geos = []
  
  transform = Transform.new()
  for (y in -4...4) {
    for (x in -4...4) {
      transform.reset()
      transform.translate(x,-1,0.5*y)
      var geo = GeometryData.clone(merged)
      geo.transform(AttributeType.Position, transform)        
      geos.add(geo)    
    }      
  }
  merged = GeometryData.merge(geos)

  mesh = Mesh.new([Geometry.new(merged)])
  
  texture = gltf.textures[0].toGraphicsTexture()
  
  camera = Camera.new()
  camera.move(-3,1,0)
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
    camera.move(0,0.02,0)
  } else if(Keyboard.isDown("l")) {
    camera.move(0,-0.02,0)
  }

  Renderer.setCamera(camera)

  var mouse = Mouse.position
  var v3 = [mouse[0],mouse[1], -0.01]
  //var v3 = [0,0,0]
  //Renderer.worldToScreen(v3)
  Renderer.screenToWorld(v3)
  System.print(v3)
  singleTransform.translate(v3[0], v3[1], v3[2])
  Renderer.setTransform(singleTransform)
  single.draw()
  singleTransform.reset()
  Renderer.setTransform(singleTransform)

  mesh.draw()
  // for (y in -4...4) {
  //   for (x in -4...4) {
  //     //System.print("x: %(x), y: %(y)")
  //     transform.reset()
  //     transform.translate(x,-1,0.5*y)        
  //     Renderer.setTransform(transform)
  //     mesh.draw()    
  //     Renderer.checkErrors()
  //   }      
  // }  
}