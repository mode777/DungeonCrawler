import "2d" for Tilemap, Tileset
import "camera" for OrthograficCamera
import "graphics" for Renderer, Texture
import "platform" for Application
import "image" for Image

var txt
var tileset
var tilemap
var cam

Application.onLoad{|ev|
  txt = Texture.fromFile("./game2d/terrain_atlas.png")
  tileset = Tileset.new(txt.width/32, txt.height/32, 32, 32)
  tilemap = Tilemap.new(txt, txt.width/32, txt.height/32, 32, 32)
  cam = OrthograficCamera.new()

  for(y in 0...txt.height/32){
    for(x in 0...txt.width/32){
      tilemap[x,y] = tileset[6,1]
    }
  }
}

Application.onUpdate{|ev|
  Renderer.set2d()
  cam.scale(1.001,1.001)
  cam.enable()
  tilemap.draw()
}

