import "platform" for Application, Event, Mouse
import "2d" for SpriteBatch, Quad
import "graphics" for Renderer, Texture, Colors, TextureFilters, Shader, UniformType, RendererFeature
import "image" for Image
import "camera" for OrthograficCamera
import "memory" for ListUtil
import "data" for Queue
import "math" for Vec2
import "geometry" for AttributeType

class Shader8 is Shader {
  construct fromFiles(){
    super("./shaders/2d.vertex.glsl", "./shaders/2d.fragment8.glsl", {
      "attributes": {
        "vPosition": AttributeType.Position,
        "vTexcoord": AttributeType.Texcoord0,
        "vColor": AttributeType.Color
      },
      "uniforms": {
        "uTexture": UniformType.Texture0,
        "uProjection": UniformType.Projection,
        "uModel": UniformType.Model,
        "uView": UniformType.View,
        "uTextureSize": UniformType.TextureSize,
        "uPalette": UniformType.Texture1
      }
    })
    _txt = Texture.fromImage(Image.new(256,1), { "magFilter": TextureFilters.Nearest })
  }

  setPalette(img){
    _txt.copyImage(img, 0, 0)
    Renderer.setUniformTexture(UniformType.Texture1, 1, _txt)
  }

  enable(){
    Renderer.setUniformTexture(UniformType.Texture1, 1, _txt)
    Renderer.toggleFeature(RendererFeature.Blend, true)
    Renderer.toggleFeature(RendererFeature.CullFace, false)
    Renderer.toggleFeature(RendererFeature.DepthTest, false)
    Renderer.setShader(this)
  }
} 

class WritableTexture {
  
  texture { _texture }
  image { _img }
  
  construct new(w,h){
    _img = Image.new(w,h,1)
    _texture = Texture.fromImage(_img, { "magFilter": TextureFilters.Nearest })
  }

  update(){
    _texture.copyImage(_img, 0,0)
  }
}


Application.onLoad {|ev|
  Renderer.setBackgroundColor(0.1, 0, 0.2)
  var shader = Shader8.fromFiles()
  shader.enable()
  var cam = OrthograficCamera.new()
  var txt = WritableTexture.new(32,32)

  var magnify = 10
  var q = Quad.new(0,0,txt.image.width*magnify,txt.image.height*magnify)
  var pos = [0,0]
  var mouseDown = false

  var palette = Image.new(256,1)
  palette.setPixel(0,0,Colors.Green)
  palette.setPixel(1,0,Colors.Red)

  var palImg = Image.new(16,16,1)
  var p = [0]
  for(y in 0...16){
    for(x in 0...16){
      palImg.setPixel(x,y,p)
      p[0] = p[0]+1
    }
  }
  var palTxt = Texture.fromImage(palImg, { "magFilter": TextureFilters.Nearest})
  var batch2 = SpriteBatch.new(palTxt, 1)
  batch2.setSprite(0, Quad.new(0,0,16,16), Quad.new(512,0,256, 256))

  var batch = SpriteBatch.new(txt.texture, 1)
  batch.setSprite(0, Quad.new(0,0,txt.image.width, txt.image.height), q)


  Application.onUpdate{|ev|
    if(mouseDown && q.isInside(Mouse.position)){
      Vec2.sub(Mouse.position, q.a, pos)
      Vec2.divV(pos, magnify, pos)
      Vec2.floor(pos, pos)
      txt.image.setPixel(pos[0], pos[1], [1])
      txt.update()
    }
    shader.setPalette(palette)

    cam.enable()
    batch.draw()
    batch2.draw()
  }

  Application.on(Event.Mousebuttonup){|ev|
    mouseDown = false
  }

  Application.on(Event.Mousebuttondown){|ev|
    mouseDown = true
  }

}